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

# Phrases used by the games (Speech.extras in lib/services/speech.dart).
EXTRAS = ["Can you find"]

# What the puppy says: greetings and rewards (Speech.mascot in lib/services/speech.dart).
# These use a livelier, child-like voice and are saved in assets/audio/puppy/.
MASCOT_LINES = [
    "Great job!",
    "Well done!",
    "Great job! Now pick your sticker.",
    "Woof woof! You did it!",
    "Yay! You found it!",
    "Try again!",
    "Hi! How are you?",
    "This is fun!",
]
# Recorded directly: at normal speed this voice doesn't add the "uh" at the start, and it doesn't
# pause after a lead-in, so the lead-in trick isn't used (or needed) for it.
MASCOT_VOICE = "af_nova"
MASCOT_SPEED = 1.0
MASCOT_SEMITONES = 4  # higher pitch, so it sounds like a child
MASCOT_FILTER = f"rubberband=pitch={2 ** (MASCOT_SEMITONES / 12):.4f}:formant=shifted,loudnorm=I=-22:TP=-1.5:LRA=11"  # about as loud as the teacher voice
MASCOT_OUT = OUT / "puppy"


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
    texts = [*EXTRAS]
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


def to_mp3(samples, rate, path, audio_filter="anull"):
    with tempfile.NamedTemporaryFile(suffix=".wav") as wav:
        sf.write(wav.name, samples, rate)
        subprocess.run(
            ["ffmpeg", "-loglevel", "error", "-y", "-i", wav.name, "-af", audio_filter, "-ar", str(rate), "-ac", "1",
             "-b:a", "48k", str(path)],
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
    """A short, soft 'pop' for taps: a quick burst of noise with a falling 'thump'."""
    rng = np.random.default_rng(7)
    t = np.arange(int(rate * 0.12)) / rate
    noise = rng.standard_normal(len(t)) * np.exp(-t * 80)
    thump = np.sin(2 * np.pi * (500 - 1800 * t) * t) * np.exp(-t * 35)
    out = noise * 0.35 + thump
    return (0.5 * out / np.abs(out).max()).astype(np.float32)


def hand_clap(rng, rate=24000):
    """One hand clap: a short burst of noise around 1-3 kHz with a fast decay."""
    n = int(rate * 0.08)
    t = np.arange(n) / rate
    centre = (rng.uniform(700, 1100) + rng.uniform(2200, 3200)) / 2 * rng.uniform(0.9, 1.3)
    spec = np.fft.rfft(rng.standard_normal(n))
    spec *= np.exp(-((np.log(np.fft.rfftfreq(n, 1 / rate) + 1) - np.log(centre)) ** 2) / (2 * 0.45**2))
    # Real claps have a few tiny hits in the first 10 ms.
    env = np.exp(-t * rng.uniform(45, 70))
    for delay in (0.0, rng.uniform(0.002, 0.004), rng.uniform(0.006, 0.009)):
        env += 0.5 * np.exp(-np.maximum(t - delay, 0) * 300) * (t >= delay)
    return np.fft.irfft(spec, n) * env


def applause(rate=24000, length=3.5, clappers=20):
    """A classroom applauding: each clapper claps at their own speed."""
    rng = np.random.default_rng(3)
    out = np.zeros(int(rate * length))
    for _ in range(clappers):
        t, speed = rng.uniform(0, 0.3), rng.uniform(3.5, 6.5)
        while t < length - 0.1:
            c = hand_clap(rng, rate) * rng.uniform(0.3, 1.0)
            i = int(t * rate)
            out[i : i + len(c)] += c[: len(out) - i]
            t += 1 / speed + rng.uniform(-0.04, 0.04)
    return out / np.abs(out).max()


# Children cheering "Yaaay!" together over the applause: (voice, semitones up), pitched up
# to sound like kids.
CHEERS = [("af_nova", 4), ("af_sky", 5), ("af_bella", 5), ("am_puck", 7), ("af_jessica", 5),
          ("af_heart", 5), ("am_echo", 8), ("af_nicole", 5), ("af_river", 5), ("am_liam", 8)]
CHEER_FILTER = "aecho=0.8:0.6:40|70:0.25|0.15,loudnorm=I=-18:TP=-1.5:LRA=11"  # a little room echo


def pitch_up(samples, rate, semitones):
    """Raises the pitch (and voice size) with ffmpeg's rubberband, keeping the speed."""
    with tempfile.NamedTemporaryFile(suffix=".wav") as src, tempfile.NamedTemporaryFile(suffix=".wav") as dst:
        sf.write(src.name, samples, rate)
        subprocess.run(
            ["ffmpeg", "-loglevel", "error", "-y", "-i", src.name, "-af",
             f"rubberband=pitch={2 ** (semitones / 12):.4f}:formant=shifted", dst.name],
            check=True,
        )
        return sf.read(dst.name, dtype="float32")[0]


def cheer_sound(tts, rate=24000):
    """About 3.5 seconds of a classroom applauding, with the children shouting "Yaaay!"."""
    rng = np.random.default_rng(5)
    kids = np.zeros(int(rate * 1.6))
    for voice, semitones in CHEERS:
        # Kokoro sometimes returns no audio for a short word: try small variations.
        for text in ("Yaaay!", "Yaaay.", "Yay!"):
            raw = trim(tts.create(text, voice=voice, speed=0.75, lang="en-us")[0])
            if len(raw):
                break
        else:
            raise SystemExit(f"could not record the cheer ({voice})")
        shout = pitch_up(raw, rate, semitones + rng.uniform(-0.5, 0.5))
        i = int(rng.uniform(0, 0.12) * rate)  # all together, not one after another
        n = min(len(shout), len(kids) - i)
        kids[i : i + n] += shout[:n] / max(np.abs(shout).max(), 1e-6) * rng.uniform(0.6, 1.0)
    out = np.zeros(int(rate * 3.6))
    out[: len(kids)] += kids / np.abs(kids).max() * 0.8
    claps = applause(rate)
    start = int(rate * 0.15)
    out[start : start + len(claps)] += claps[: len(out) - start] * 0.6
    fade = np.linspace(1, 0, int(rate * 1.0))
    out[-len(fade) :] *= fade
    return (0.7 * out / np.abs(out).max()).astype(np.float32)


def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--model", required=True)
    ap.add_argument("--voices-dir", required=True)
    ap.add_argument("--voice", default="af_heart")
    ap.add_argument("--speed", type=float, default=0.75, help="below 1 is slower; 0.75 suits young children")
    ap.add_argument("--force", action="store_true", help="regenerate clips that already exist")
    args = ap.parse_args()

    from kokoro_onnx import Kokoro

    def load(name):
        return np.fromfile(Path(args.voices_dir) / f"{name}.bin", dtype=np.float32).reshape(-1, 1, 256)

    with tempfile.NamedTemporaryFile(suffix=".npz") as voices:
        names = {args.voice, MASCOT_VOICE, *(c[0] for c in CHEERS)}
        np.savez(voices.name, **{name: load(name) for name in names})
        tts = Kokoro(args.model, voices.name)

    OUT.mkdir(parents=True, exist_ok=True)
    (OUT / "effects").mkdir(exist_ok=True)
    to_mp3(chime(), 24000, OUT / "effects" / "chime.mp3")
    to_mp3(pop_sound(), 24000, OUT / "effects" / "pop.mp3")
    to_mp3(cheer_sound(tts), 24000, OUT / "effects" / "cheer.mp3", CHEER_FILTER)

    def record(text, voice=args.voice, speed=args.speed):
        """Records [text] without the extra "uh" at the start (see LEAD_INS)."""
        # Without closing punctuation Kokoro sometimes returns no audio at all.
        spoken = text if text[-1] in ".!?" else f"{text}."
        for variant in (spoken, spoken[:-1] + "!", spoken[:-1] + "."):
            solo, rate = tts.create(variant, voice=voice, speed=speed, lang="en-us")
            if len(trim(solo)):
                break
        else:
            raise SystemExit(f"could not record {text!r} on its own")
        for lead_in in LEAD_INS:
            samples, rate = tts.create(f"{lead_in} {spoken}", voice=voice, speed=speed, lang="en-us")
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

    # The puppy's lines, in its own voice.
    MASCOT_OUT.mkdir(exist_ok=True)
    for text in MASCOT_LINES:
        path = MASCOT_OUT / f"{clip_name(text)}.mp3"
        if path.exists() and not args.force:
            continue
        spoken = text if text[-1] in ".!?" else f"{text}."
        samples, rate = tts.create(spoken, voice=MASCOT_VOICE, speed=MASCOT_SPEED, lang="en-us")
        samples = drop_onset_hum(trim(samples))
        if not len(samples):
            raise SystemExit(f"could not record {text!r} for the puppy")
        to_mp3(samples, rate, path, MASCOT_FILTER)
        print(f"puppy/{path.name}: {text}")

    for folder, keep in ((OUT, wanted), (MASCOT_OUT, {clip_name(t) for t in MASCOT_LINES})):
        for stale in folder.glob("*.mp3"):
            if stale.stem not in keep:
                stale.unlink()
                print(f"removed unused {stale.relative_to(OUT)}")


if __name__ == "__main__":
    main()
