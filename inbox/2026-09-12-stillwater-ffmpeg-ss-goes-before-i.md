# `ffmpeg -ss` goes BEFORE `-i`, or a trimmed OGG decodes to silence with the right duration

**Game:** stillwater  **Date:** 2026-09-12  **Belongs in:** ASSETS.md / Audio specifically

## What happened
Two sounds in Stillwater genuinely could not be generated - an oar in a rowlock and a dawn
chorus - so 9.6 MB of CC0 field recording was trimmed and normalised down to 240 KB. The
trim was written as `ffmpeg -i in.ogg -ss 12 -t 4 out.ogg`, with `-ss` after the input. Every
output file had exactly the right duration, imported cleanly, played in the editor and was
completely silent. `ffmpeg -af volumedetect` read them at -91 dB, which is digital zero.
Output-side `-ss` on a Vorbis stream discarded the decoded frames instead of seeking the
input, so what got encoded was the gap. The tell was there before any measurement: a 6 KB
file for 24 seconds of audio is not audio. Moving `-ss` before `-i` fixed it in one run.

## The rule
Put `-ss` (and `-t`/`-to`) before `-i` when trimming, so ffmpeg seeks the input rather than
dropping decoded output frames. After any audio trim, check the level - `ffmpeg -i out.ogg
-af volumedetect -f null -` - and check the file SIZE against the duration: a few KB for
several seconds means the encoder was handed silence, whatever the duration says.

## Replaces or contradicts
nothing. ASSETS.md's audio section has the formats and the generate-at-build-time rule but no trim recipe at all.
