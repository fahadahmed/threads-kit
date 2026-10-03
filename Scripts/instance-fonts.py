#!/usr/bin/env python3
"""Cuts the bundled static fonts from the upstream variable fonts (all SIL Open Font License).

SwiftUI can't set a variable font's axes at runtime, so each face used by a type role is instanced once
here and shipped as a static TTF.

    python3 -m venv .venv && .venv/bin/pip install fonttools
    # download the variable fonts and their OFL.txt files from github.com/google/fonts (ofl/fraunces,
    # ofl/hankengrotesk, ofl/jetbrainsmono) into a folder, then:
    .venv/bin/python Scripts/instance-fonts.py <folder with the variable fonts> Sources/ThreadsTokens/Resources/Fonts

Settings: Fraunces at wght 500, opsz 36, SOFT 60, WONK 1 (roman and italic); Hanken Grotesk at wght 400 and
600; JetBrains Mono at wght 500. opsz 36 sits in the middle of the display sizes (28 / 34 / 38 pt), since
"opsz auto" can't be reproduced in a static font.
"""
import sys
from pathlib import Path
from fontTools.ttLib import TTFont
from fontTools.varLib import instancer


def make(src: Path, axes: dict, family: str, style: str, postscript: str, out: Path) -> None:
    font = instancer.instantiateVariableFont(TTFont(src), axes, inplace=False)
    name = font["name"]
    for record in list(name.names):
        if record.nameID in (16, 17, 21, 22, 25):
            name.removeNames(nameID=record.nameID)
    for platform, encoding, language in ((3, 1, 0x409), (1, 0, 0)):
        name.setName(family, 1, platform, encoding, language)
        name.setName(style, 2, platform, encoding, language)
        name.setName(f"{postscript};threads", 3, platform, encoding, language)
        name.setName(f"{family} {style}", 4, platform, encoding, language)
        name.setName(postscript, 6, platform, encoding, language)
    font.save(out)
    assert "fvar" not in font, f"{out} is still variable"
    print("wrote", out)


def main(source: Path, target: Path) -> None:
    target.mkdir(parents=True, exist_ok=True)
    display = {"wght": 500, "opsz": 36, "SOFT": 60, "WONK": 1}
    make(source / "Fraunces[SOFT,WONK,opsz,wght].ttf", display, "Fraunces Display", "Regular", "FrauncesDisplay-Regular", target / "FrauncesDisplay-Regular.ttf")
    make(source / "Fraunces-Italic[SOFT,WONK,opsz,wght].ttf", display, "Fraunces Display", "Italic", "FrauncesDisplay-Italic", target / "FrauncesDisplay-Italic.ttf")
    make(source / "HankenGrotesk[wght].ttf", {"wght": 400}, "Hanken Grotesk", "Regular", "HankenGrotesk-Regular", target / "HankenGrotesk-Regular.ttf")
    make(source / "HankenGrotesk[wght].ttf", {"wght": 600}, "Hanken Grotesk", "SemiBold", "HankenGrotesk-SemiBold", target / "HankenGrotesk-SemiBold.ttf")
    make(source / "JetBrainsMono[wght].ttf", {"wght": 500}, "JetBrains Mono", "Medium", "JetBrainsMono-Medium", target / "JetBrainsMono-Medium.ttf")


if __name__ == "__main__":
    main(Path(sys.argv[1]), Path(sys.argv[2]))
