"""Checks that no voice clip sounds plural when its text is not ("Banana" heard as "Bananas").

For each clip, the PocketSphinx speech recognizer (its English model comes with the package)
chooses between the text as written and the text with "s" added to the last word. Any clip it
hears as plural is listed; re-record it with another take (see PREFERRED_TAKE in generate_audio.py).

Setup (once):  .venv/bin/pip install pocketsphinx
Run:           .venv/bin/python tool/check_plurals.py
"""

import json
import re
import subprocess
import sys
import warnings
from pathlib import Path

from pocketsphinx import Decoder, get_model_path

import generate_audio as g

warnings.filterwarnings("ignore")
MODEL = Path(get_model_path()) / "en-us"
DICT = MODEL / "cmudict-en-us.dict"
# Words the recognizer's dictionary does not have.
EXTRA = {
    "dragonfly": "D R AE G AH N F L AY",
    "playtime": "P L EY T AY M",
    "dickory": "D IH K ER IY",
    "woodcutter": "W UH D K AH T ER",
    "beast's": "B IY S T S",
    "beanstalk": "B IY N S T AO K",
}

PRONOUNCE = dict(EXTRA)
for line in DICT.read_text().splitlines():
    word, *phones = line.split()
    PRONOUNCE.setdefault(word, " ".join(phones))


def words(text):
    return [w.lower() for w in re.findall(r"[A-Za-z']+", text.replace("-", " "))]


def plural(word):
    phones = PRONOUNCE[word]
    last = phones.split()[-1]
    if last in ("S", "Z", "SH", "ZH", "CH", "JH"):
        return word + "es", phones + " IH Z"
    return word + "s", phones + (" S" if last in ("P", "T", "K", "F", "TH") else " Z")


def heard(path, text):
    """Returns (what the recognizer chose, the plural version), or None if a word is unknown."""
    ws = words(text)
    if not ws or any(w not in PRONOUNCE for w in ws):
        return None
    plural_word, plural_phones = plural(ws[-1])
    decoder = Decoder(hmm=str(MODEL / "en-us"), dict=str(DICT), lm=None, logfn="/dev/null")
    for w in ws:
        if w in EXTRA:
            decoder.add_word(w, EXTRA[w], False)
    if plural_word not in PRONOUNCE:  # e.g. "happys": built from the word's own sounds
        decoder.add_word(plural_word, plural_phones, True)
    singular, plural_text = " ".join(ws), " ".join(ws[:-1] + [plural_word])
    decoder.add_jsgf_string("x", f"#JSGF V1.0; grammar x; public <s> = ({singular}) | ({plural_text});")
    decoder.activate_search("x")
    audio = subprocess.run(
        ["ffmpeg", "-loglevel", "error", "-i", str(path), "-ac", "1", "-ar", "16000", "-f", "s16le", "-"],
        capture_output=True,
        check=True,
    ).stdout
    decoder.start_utt()
    decoder.process_raw(audio, full_utt=True)
    decoder.end_utt()
    hyp = decoder.hyp()
    return (hyp.hypstr if hyp else ""), plural_text


def main():
    content = json.loads(g.CONTENT.read_text())
    clips = [(g.OUT / f"{g.clip_name(t)}.mp3", t) for t in g.all_speech(content)]
    clips += [(g.MASCOT_OUT / f"{g.clip_name(t)}.mp3", t) for t in g.MASCOT_LINES]
    bad, unknown = [], []
    for path, text in clips:
        result = heard(path, text)
        if result is None:
            unknown.append(text)
        elif result[0] == result[1]:
            bad.append(text)
    print(f"checked {len(clips) - len(unknown)} clips; {len(bad)} sound plural")
    for text in bad:
        print("  plural:", text.replace("\n", " "))
    for text in unknown:
        print("  not checked (unknown word):", text.replace("\n", " "))
    sys.exit(1 if bad else 0)


if __name__ == "__main__":
    main()
