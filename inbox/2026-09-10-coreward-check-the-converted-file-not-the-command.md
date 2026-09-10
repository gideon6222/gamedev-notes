# Check the converted file, not the exit code of the tool that made it

**What happened.** Coreward's asset pipeline was blocked for a round because `sharp-cli`
turned a 342 KB JPEG into a 342-byte WebP - a valid file, correct header, exit code zero, and
a solid colour. It was caught only because the number looked absurd. A 4 KB output would have
shipped.

The replacement (Python Pillow, which is already on this machine) works, and the pipeline now
**checks every conversion before wiring it in**:

```python
from PIL import Image, ImageStat
st = ImageStat.Stat(Image.open(dst).convert('L'))
assert st.stddev[0] > 3, 'flat - conversion produced no image'
```

That check earned itself on its first run. ambientCG `Metal038`, picked for a ship hull,
converted to 462 bytes with a standard deviation of 0.4. Not a broken conversion this time -
a real file from a source with almost no relief, which is the WRONG PICK. Without the check
it would have shipped as an invisible improvement, which is the worst kind of change: it looks
done, it is in the credits, and nothing is different.

**The rule.** An asset conversion has no exit code worth trusting. Verify the artefact:
dimensions, byte size against a known-good baseline, and a variance measure that distinguishes
an image from a fill. Do it in the same script that does the conversion so it cannot be
skipped, and keep the baseline number in the notes so "38 KB for a 384 px normal map" is
something to compare against rather than something to feel.

**The wider version.** Three separate failures in two days had the same shape: a tool returning
success while producing nothing usable - a search that reported an empty library as an absent
one, a probe that mined outside the world and reported it as a poor one, and this. In every
case the tool was fine and the CHECK was missing. Anything whose output feeds a decision needs
an assertion about that output, not about whether it ran.

**Where it belongs.** `ASSETS.md`, as the verified conversion command plus the variance check,
with the 384 px / ~38 KB baseline. The general form belongs in `TESTING.md` next to the note
about tools that cannot report failure.
