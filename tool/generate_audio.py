"""Generates the app's voice clips and sound effects into assets/audio/.

Uses the free Kokoro-82M text-to-speech model (Apache-2.0) through the
kokoro-onnx package. The sentences follow the same rules as
lib/services/speech.dart; test/speech_test.dart checks that every sentence
the app can say has a clip.

Setup (once):
  python3 -m venv .venv && .venv/bin/pip install kokoro-onnx soundfile numpy
  npm pack kokoro-fp16-shards@1.0.4 kokoro-js@1.2.1   # model weights + voices
  # join kokoro-fp16.part0.bin ... part9.bin (in order) into kokoro-fp16.onnx

Run:
  .venv/bin/python tool/generate_audio.py --model kokoro-fp16.onnx \
      --voices-dir <kokoro-js>/package/voices [--voice af_heart] [--force]

Needs ffmpeg on the PATH.
"""

import argparse
import json
import re
import subprocess
import tempfile
from pathlib import Path

import numpy as np
import soundfile as sf

ROOT = Path(__file__).resolve().parent.parent
CONTENT = ROOT / "assets" / "content" / "content.json"
OUT = ROOT / "assets" / "audio"

# Kokoro adds a short "uh" sound at the very start of a recording, which made
# single words sound like "a horse". So each clip is recorded after a lead-in,
# which is cut off at the pause that follows it. Kokoro occasionally returns no
# audio for a sentence, so the next lead-in is tried if that happens.
LEAD_INS = ["Okay...", "Okay…", "Now...", "Yes..."]
FRAME = 480  # 20 ms at 24 kHz

GREAT_JOB = "Great job!"
WELL_DONE = "Well done!"
# Phrases used by the games and rewards (Speech.extras in lib/services/speech.dart).
EXTRAS = [
    "Great job! Now pick your sticker.",
    "Woof woof! You did it!",
    "Can you find",
    "Pop the",
    "Yay! You found it!",
    "Try again!",
]
NUMBER_WORDS = ["One", "Two", "Three", "Four", "Five", "Six", "Seven", "Eight", "Nine", "Ten"]


def clip_name(text):
    return re.sub(r"^_+|_+$", "", re.sub(r"[^a-z0-9]+", "_", text.lower()))


def item_speech(item):
    if item.get("speak"):
        return item["speak"]
    if item.get("opposite"):
        return f"{item['label']}. {item['opposite']['label']}."
    if item.get("subtitle"):
        return f"{item['label']}. {item['subtitle']}"
    return item["label"]


def trace_speech(ch):
    if ch.isdigit():
        return f"Trace the number {ch}."
    return f"Trace the letter {ch.upper()}."


# Silence between the two words of an opposite pair ("Big. ... Small.").
PAIR_PAUSE = 0.8


def opposite_parts(content):
    """Maps each opposite pair's sentence to its two words, which are recorded
    separately and joined with a pause."""
    return {
        item_speech(i): [f"{i['label']}.", f"{i['opposite']['label']}."]
        for c in content["categories"]
        for i in c.get("items", [])
        if i.get("opposite")
    }


def all_speech(content):
    texts = [GREAT_JOB, WELL_DONE, *EXTRAS, *NUMBER_WORDS]
    for c in content["categories"]:
        texts.append(c["title"])
        texts += [item_speech(i) for i in c.get("items", [])]
        for g in c.get("groups", []):
            if c["layout"] == "tracing":
                texts += [trace_speech(i["label"]) for i in g["items"]]
            else:
                texts.append(g["label"])
                texts += [item_speech(i) for i in g["items"]]
    return list(dict.fromkeys(texts))


def to_mp3(samples, rate, path):
    with tempfile.NamedTemporaryFile(suffix=".wav") as wav:
        sf.write(wav.name, samples, rate)
        subprocess.run(
            ["ffmpeg", "-loglevel", "error", "-y", "-i", wav.name, "-ac", "1", "-b:a", "48k", str(path)],
            check=True,
        )


def trim(samples, rate=24000):
    """Trims to the speech plus a little padding."""
    loud = np.flatnonzero(np.abs(samples) > 0.01)
    if not loud.size:
        return samples[:0]
    pad = int(rate * 0.05)
    return samples[max(loud[0] - pad, 0) : loud[-1] + pad]


def cut_lead_in(samples, solo_length):
    """Returns the audio after the first pause, which follows the lead-in.

    [solo_length] is the length of the phrase recorded on its own; the result
    must be close to it, which catches a cut in the wrong place.
    """
    n = len(samples) // FRAME
    rms = np.sqrt(np.mean(samples[: n * FRAME].reshape(n, FRAME) ** 2, axis=1))
    speaking = np.flatnonzero(rms > 0.005)
    if not speaking.size:
        raise ValueError("no speech")
    quiet = 0
    for i in range(speaking[0], n - 1):
        quiet = quiet + 1 if rms[i] < 0.005 else 0
        # Gaps inside "Okay" are under 60 ms; the "..." pause is 200-400 ms.
        if quiet >= 6 and rms[i + 1] >= 0.005:
            rest = trim(samples[(i - 2) * FRAME :])  # keep 60 ms of the pause
            # The solo recording includes the extra "uh" (up to ~0.3 s), so it can
            # be noticeably longer than a correct cut.
            if min(0.75 * solo_length, solo_length - 0.35 * 24000) < len(rest) < 1.5 * solo_length + 0.3 * 24000:
                return rest
            raise ValueError("cut in the wrong place")
    raise ValueError("no pause after the lead-in")


def drop_onset_hum(samples):
    """Removes a hum of up to 80 ms before a "b", "d", "g" or "w" when a dip
    follows it, since it can sound like a faint "uh"."""
    n = len(samples) // FRAME
    rms = np.sqrt(np.mean(samples[: n * FRAME].reshape(n, FRAME) ** 2, axis=1))
    # One letter per 20 ms: " " silent, "." quiet, "v" loud.
    shape = "".join(" " if r < 0.005 else "." if r < 0.035 else "v" for r in rms)
    match = re.match(r" *\.?v{1,3}(?=[. ]{2})", shape)
    cut = match.end() if match else None
    if cut is None:
        # Or: up to 3 frames of sound, a dip (1-2 frames) to under half that, then
        # much louder speech.
        start = int(np.argmax(rms > 0.005))
        for k in (1, 2, 3):
            for gap in (2, 1):
                hum, dip = rms[start : start + k], rms[start + k : start + k + gap]
                after = rms[start + k + gap : start + k + gap + 4]
                if len(after) and hum.max() >= 0.02 and dip.max() < 0.5 * hum.max() and after.max() > 2 * hum.max():
                    cut = start + k
                    break
            if cut is not None:
                break
    if cut is None:
        return samples
    rest = samples[cut * FRAME :].copy()
    fade = FRAME // 2  # 10 ms, so the cut does not click
    rest[:fade] *= np.linspace(0, 1, fade, dtype=rest.dtype)
    return rest


def chime(rate=24000):
    """A short, bright three-note arpeggio (C6-E6-G6), made from sine waves."""
    notes, dur = [1046.5, 1318.5, 1568.0], 0.14
    t = np.arange(int(rate * 0.6)) / rate
    out = np.zeros_like(t)
    for n, f in enumerate(notes):
        start = n * dur
        tt = np.clip(t - start, 0, None)
        env = np.where(t >= start, np.exp(-tt * 7), 0)
        out += env * (np.sin(2 * np.pi * f * tt) + 0.3 * np.sin(4 * np.pi * f * tt))
    return (0.35 * out / np.abs(out).max()).astype(np.float32)


def pop_sound(rate=24000):
    """A short balloon pop: a burst of noise that fades fast, with a falling 'thump'."""
    rng = np.random.default_rng(7)
    t = np.arange(int(rate * 0.18)) / rate
    noise = rng.standard_normal(len(t)) * np.exp(-t * 60)
    thump = np.sin(2 * np.pi * (220 - 600 * t) * t) * np.exp(-t * 25)
    out = noise * 0.6 + thump * 0.8
    return (0.6 * out / np.abs(out).max()).astype(np.float32)


def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--model", required=True)
    ap.add_argument("--voices-dir", required=True)
    ap.add_argument("--voice", default="af_heart")
    ap.add_argument("--speed", type=float, default=0.75, help="below 1 is slower; 0.75 suits young children")
    ap.add_argument("--force", action="store_true", help="regenerate clips that already exist")
    args = ap.parse_args()

    from kokoro_onnx import Kokoro

    voice = np.fromfile(Path(args.voices_dir) / f"{args.voice}.bin", dtype=np.float32).reshape(-1, 1, 256)
    with tempfile.NamedTemporaryFile(suffix=".npz") as voices:
        np.savez(voices.name, **{args.voice: voice})
        tts = Kokoro(args.model, voices.name)

    OUT.mkdir(parents=True, exist_ok=True)
    (OUT / "effects").mkdir(exist_ok=True)
    to_mp3(chime(), 24000, OUT / "effects" / "chime.mp3")
    to_mp3(pop_sound(), 24000, OUT / "effects" / "pop.mp3")

    def record(text):
        """Records [text] without the extra "uh" at the start (see LEAD_INS)."""
        # Without closing punctuation Kokoro sometimes returns no audio at all.
        spoken = text if text[-1] in ".!?" else f"{text}."
        for variant in (spoken, spoken[:-1] + "!", spoken[:-1] + "."):
            solo, rate = tts.create(variant, voice=args.voice, speed=args.speed, lang="en-us")
            if len(trim(solo)):
                break
        else:
            raise SystemExit(f"could not record {text!r} on its own")
        for lead_in in LEAD_INS:
            samples, rate = tts.create(f"{lead_in} {spoken}", voice=args.voice, speed=args.speed, lang="en-us")
            try:
                samples = drop_onset_hum(cut_lead_in(samples, len(trim(solo))))
                break
            except ValueError:
                continue
        else:
            raise SystemExit(f"could not record {text!r}")
        return samples, rate

    content = json.loads(CONTENT.read_text())
    texts = all_speech(content)
    pairs = opposite_parts(content)
    wanted = {clip_name(t) for t in texts}
    for i, text in enumerate(texts, 1):
        path = OUT / f"{clip_name(text)}.mp3"
        if path.exists() and not args.force:
            continue
        if text in pairs:
            (first, rate), (second, _) = (record(t) for t in pairs[text])
            samples = np.concatenate([first, np.zeros(int(rate * PAIR_PAUSE), dtype=first.dtype), second])
        else:
            samples, rate = record(text)
        to_mp3(samples, rate, path)
        print(f"[{i}/{len(texts)}] {path.name}: {text}")

    for stale in OUT.glob("*.mp3"):
        if stale.stem not in wanted:
            stale.unlink()
            print(f"removed unused {stale.name}")


if __name__ == "__main__":
    main()
