# Generated audio: synthesising SFX and music instead of shipping files

**Game:** Coreward, Captain Run, Wick (Web Audio at runtime); Candle Gift, Wrecking Crew, Stillwater (Godot, WAVs generated offline) · **Status:** shipped on every game; the one outright "I don't like" on Coreward was the music · **Read when:** adding sound or music to a game; a generated bed that sounds like beeps or like dread; a score that has to follow game state; deciding whether to ship a WAV

Every game here has generated its own audio rather than importing it - first at runtime
through Web Audio on the web stack, then as `AudioStreamWAV`s built at boot or as WAVs
written offline by a headless script and committed, once GDScript turned out to be too slow
to synthesise four music beds on a phone's CPU. The reasons were practical (no licensing, no
files, the CC0 audio libraries are not reachable unattended) and then turned out to be
musical: a sound that is a function can take arguments, and a set of twenty sounds generated
from one key and one family of envelopes is coherent by construction. This file keeps the
technical findings (22050 Hz mono is enough; a 4 MB library was +3% APK not +14%;
round-robin players; alarm routing; fade times) and the composition lessons (a written theme
beats random notes; a drone is dread, a cadence and a pulse are cheerful; a mood arc is a
crossfade on a gameplay number).

**Generalisable takeaways**

- **Generate, then import only if the generated version has been tried and is not good
  enough.** A sound that is a function can be pitched by game state; an asset pack gives you
  twenty sounds that belong to twenty other games.
- **Composition, not fidelity, is what the player hears.** Randomness cannot substitute for
  melody; a fast attack on a high sine is a notification sound; a root-fifth-octave swell is
  dread; a progression with a cadence, movement on the quaver and a pulse on the beat is
  happy. Randomise pitch and filter on repeats.
- **Layer vertically, crossfade on a gameplay quantity, and assert the arc.** One tempo, one
  key, one scheduler; fades that do not match (places arrive slowly, alarms snap in and leave
  lazily); the alarm routed past whatever muffles the rest.

---

## Design

**Generative beats a loop.** A chord bed of detuned oscillators through a lowpass, a written theme
rather than random notes, and a delay for space. Randomness cannot substitute for melody: without
repetition there is no phrase for the ear to hold, so isolated notes register as UI noise. A fast
attack on a high sine is literally the shape of a notification sound.

**Randomise pitch and filter cutoff on repeated sounds**, or an identical sound fired twice a
second becomes a machine.

**A texture reads as ambience; only a rhythm reads as movement.** Coreward's unstable-band layer
is scheduled thuds off the downbeat — on the beat they would read as part of the score rather than
as something else in the room.

**Sound is one of the three feedback channels.** An action with no sound reads as not having
happened, however good the particles are.

### The Coreward fix, for the record

The score picked melody notes at random from a pentatonic scale, and the note was "The music
has random higher pitch beeps that I dont like." From `PLAYTESTS.md`, 2026-09-06:

The score picked melody notes at random from a pentatonic scale. Musically valid, and it
still sounded like beeps. Lesson: randomness cannot substitute for melody. Without repetition
there is no phrase for the ear to latch onto, so isolated notes register as UI noise rather
than music. Also, a fast attack on a high sine is literally the shape of a notification
sound, which is exactly what he was hearing.

Fixed by writing an actual 32-beat theme in A minor over i - VI - III - VII, playing it only
every other cycle, giving every note a 0.3s attack and a long release, dropping it into a
register below where it gets shrill, and running it through a delay. The ambient bed was
thickened underneath with a continuous low drone and filtered air.

### Kenney has no music loops, and a drone is how you write dread

(From `ASSETS.md`.)

Worth recording both halves because the second one is not an asset problem at all.

Kenney's audio packs - the CC0 library this stack reaches for - are Interface Sounds, Impact
Sounds, UI Audio, Digital, RPG, Casino, and **Music Jingles**, which is stingers. There is no
upbeat background loop to take. Generating one remains the answer.

And when a generated bed was described by the player as "creepy", the fault was **composition,
not fidelity**. It was a root, a fifth and an octave under a slow swell - a drone. Three changes,
none of them about sample quality:

- a **major progression with a cadence** (I-V-vi-IV)
- **movement** - a plucked arpeggio on the quaver, so something happens eight times a bar
- a **pulse** - a soft kick on the beat

A loop with no rhythm floats. What makes music sound happy rather than ambient is a tempo you
can nod to.

**Sample where a sample is better, synthesise where the sound must answer the game.** Kenney's
interface and impact sounds beat a sine blip for a tap or a knock. But a dip pitched by how many
colours the candle already wears turns four pools into a rising figure, and no fixed sample does
that without a folder of variants.

### A mood arc is a crossfade on a gameplay quantity

**A MOOD ARC IS A CROSSFADE ON A GAMEPLAY QUANTITY, NEVER A PLAYLIST.** Stillwater is meant
to go from pleasant to unpleasant over hours. The version that works runs four beds
continuously from the first second to the last - all one key, all one loop length - and
changes only their levels. A game that switches to Creepy Track 2 at forty metres has told
the player it is trying to frighten them, and being told is the end of it.

Two things make it work, and both are worth copying:

- **Drive it off a number the game already has**, not a story flag or an act counter.
  Stillwater uses DEPTH, which is what the whole game is about. The immediate reward is that
  the arc runs BACKWARDS for free: go and fish the shallows after the deep water and the
  cheerful layer comes back, and discovering it still exists is a stranger feeling than
  losing it was. No flag-based system gives you that, because a flag only counts forwards.
- **The layer that LEAVES does more work than any layer that arrives.** The bells are most of
  the first hour and gone by the halfway point, and nothing replaces them. An absence is the
  loudest thing you can put in a score, and it costs no assets.

**Assert the arc.** "The music changes" is a design claim, and a mix built by ear satisfies it
on the day and silently stops satisfying it the next time a level is nudged - a soundtrack
that quietly stopped changing is an inaudible regression. Drive the mixer at the depths the
game actually produces and assert monotonicity AND a real span at each end; monotonic alone
passes for an arc that moves half a decibel.

## Web Audio (runtime synthesis)

(From `ASSETS.md`.)

**Everything so far has been synthesised at runtime with Web Audio, and it has been the
right call.** No files, no loading, no licensing, no precache entries, and the score can
respond to game state in ways a recording cannot — Coreward's music has layers that mix in
by depth, danger and zone off one scheduler.

Import audio only when a synthesised version has actually been tried and is not good enough.
If it comes to that: Kenney's audio packs are CC0, and freesound.org is a large mixed-licence
library that needs an API key.

Things worth knowing about Web Audio, learned rather than looked up:

- Chrome **refuses to create an `AudioContext` outside a user gesture**. Build the graph on
  first touch, and build it atomically — publish the whole graph or none of it, so one null
  check narrows everything.
- **Vertical layering needs one tempo, one key and one harmony.** A procedurally generated
  score gets that free, since it all comes off one scheduler.
- **Fade times should not match.** Places arrive slowly, about a second and a half. Alarms
  snap in over a quarter second and leave lazily — late is useless for an alarm, and one
  that vanishes the instant you fix the problem teaches nothing about how close it was.
- **Route an alarm past whatever is muffling everything else.** If a lowpass closes with
  depth, the danger layer has to bypass it, because the moment it needs to be heard is
  exactly the moment everything else is being darkened.

## Godot: generate at build time and commit the WAVs

**On Godot, generate at BUILD time and commit the WAVs.** The web stack synthesises at
runtime because Web Audio does the arithmetic in C++; GDScript does it in GDScript, at about
a million samples a second. Stillwater's four music beds alone are four million samples,
which is four seconds of a black screen on the phone. A `SceneTree` script that writes
16-bit mono WAVs by hand is thirty lines, runs headless, and is deterministic - same seed,
same bytes - so re-running it and getting a diff means something actually changed.

Two measurements from doing it:

- **22050 Hz mono is enough** for water, wind, wood and low sine tones, and it halves a
  library that would otherwise be most of the APK. Nineteen sounds, including three
  eight-second ambience loops and four sixteen-second music beds, came to 4.0 MB.
- **That 4 MB cost +3% APK, not +14%.** Godot compresses WAVs on export: 27.80 MB against a
  26.98 MB budget, inside tolerance without a re-record. Do not pre-emptively downsample or
  trim loops to protect a size budget that is not actually under threat.

### Why generate rather than download

### Audio is still the gap, and the answer is probably to GENERATE it

Checked again on 2026-09-08: **Kenney's asset URLs are not guessable** (every
attempt 404s; the site needs a browser session), and **freesound still requires
an API key**. So the two CC0 audio libraries worth having are both unavailable
unattended.

For a Godot game the web stack's answer - synthesise at runtime through Web
Audio - does not carry over cleanly, and writing a synth against
`AudioStreamGenerator` in GDScript is real work for a phone's CPU. **The better
route is to generate the WAVs offline with a short Python script and commit
them**: a concrete impact is a filtered noise burst with a fast attack over a
low thump, rubble is layered short grains, a collapse is a descending rumble.
Deterministic, no licensing, no runtime cost, and the pitch jitter that stops a
repeated sound becoming a machine happens at playback.

**Generated also beats downloaded on COHERENCE, which is the argument that matters.** A
fishing game needs about twenty sounds that belong to each other - the reel click and the
drag buzz are the same mechanism, the calm pad and the deep pad are the same chord - and an
asset pack gives you twenty that belong to twenty other games. Generated, the whole set
shares one key, one sample rate and one family of envelopes and is coherent by construction.
It also turns the brief into a parameter: "happy but eerie, then worse" is a detune value
rather than a second shopping trip.

### Short sounds as `AudioStreamWAV` with arguments

(From `PIPELINE.md`.)

Eight percussive blips as `AudioStreamWAV`s built from sine waves at boot: no folder to keep in
step with the code that names them, and a rename that misses one is silence, which nothing
reports.

The real return is that **a sound that is a function can take arguments.** A dip pitched by how
many colours the candle already wears turns weaving through four pools into a rising figure
rather than four identical clicks - not something a fixed sample does without a folder of
variants.

Build them as `AudioStreamWAV` rather than pushing an `AudioStreamGenerator` every frame: the
generator wants a filled buffer on a deadline and drops out when a frame runs long, which on a
phone is exactly when the interesting things are happening. Use a round-robin pool of players,
or one restarted player cuts its own tail off every time two things happen at once.

**Give the settings panel nothing to switch that does not exist.** A switch for a feature that
is not there is worse than one fewer switch: the player turns it off, nothing changes, and now
they do not trust the other one either. If there is a music toggle, there has to be music.

### Start playback from `_ready`

- **Start audio playback from `_ready`, never `_enter_tree` or straight after `add_child`.**
  A node added during `SceneTree._initialize` reports `is_inside_tree()` as true immediately,
  so guarding on that flag looks correct and still produces one "Playback can only happen
  when a node is inside the scene tree" error per player per run. The flag is set before the
  tree is actually running; `_ready` is deferred to the first PROCESSED frame, which is what
  playback really requires. It also hands the headless tests what they want for free - they
  process no frames, so nothing plays, while the mixer is still fully built and its levels
  still assertable.
