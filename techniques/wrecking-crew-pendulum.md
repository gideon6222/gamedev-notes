# Wrecking Crew: the ball-and-chain pendulum and the tracked rig that drives it

**Game:** Wrecking Crew (Godot / native Android) · **Status:** shipped, three playtest sessions · **Read when:** any tool the player drives indirectly (a pendulum, a trailer, a charge-up); a vehicle under a fixed camera; a physics feel constant that has to be tuned rather than real

Wrecking Crew hangs a wrecking ball on a boom on a tracked rig. The player slews the boom and
drives the rig; the ball is a damped pendulum on a moving pivot, so the only thing the player
ever controls is the pivot's acceleration and the ball arrives roughly a quarter of a swing
period later. This file collects the arithmetic of that pendulum (the constraint, the
restoring force, the feel-tuned period, the quarter- versus half-period load), the vehicle
model underneath it (velocity lerp rather than position lerp, the alignment cone, the
throttle floor, tank-control mismatch under a fixed camera), the controls that made the lag
readable, and the tests that turned out to be wrong before the physics was.

**Generalisable takeaways**

- **A constraint must remove only the component it constrains.** Project the position and
  leave velocity alone and you inject energy; derive velocity from displacement and you kill
  momentum. Zero the radial component of velocity relative to the anchor and leave the
  tangential component untouched. A restoring force must be proportional to displacement or
  the thing has no period.
- **A lag the player must anticipate is a feel constant, not physics.** Set the period from
  what a thumb can anticipate (about a second) and solve the physics constant for it; then
  sweep the manoeuvre rather than reasoning about its timing, and assert the peak over a
  window rather than the end state.
- **The control frame must match the camera frame, and a one-dimensional quantity wants a
  one-dimensional control** with the lagging thing drawn on it. A tracked vehicle is one
  constant away from a car: the cone it must face within before any throttle applies.

---

## Driving the tool from acceleration

**Drive a tool from the player's ACCELERATION and you get indirect control for free.**
Wrecking Crew's ball hangs on a boom and is a damped pendulum on a moving pivot: the only
term the player controls is the pivot's lateral acceleration, so pushing the rig right
throws the ball left and it arrives on the right about a quarter of a swing period later.
The player never places the tool, they only ever push it. That single change turns "steer
into the thing" into "decide now where the thing will be in a second", which is the skill
every runner claims to have and almost none actually implements.

Two things make it work rather than merely frustrate. **The lag has to be a feel constant,
not physics.** Real gravity on a five-metre chain is a 4.5-second period, which is majestic
and unplayable; the number is set from what a thumb can anticipate - about a second - and
`sqrt(g/L)` is then solved for `g`. And **the correct technique has to be discoverable by
accident**: a sloppy single swerve still just barely connects, while the timed version -
load away from the target for a HALF period, then turn back - reaches 60% further. The
beginner gets contact, the expert gets twice the contact.

**If a tool is driven by acceleration, the rig that drives it cannot use a position lerp.**
An exponential lerp on position has an acceleration that spikes on the frame the input
changes and is zero for the rest of the move, so the tool gets kicked once and then hangs.
Approach a target VELOCITY exponentially instead: the acceleration is smooth, bounded, and
lasts as long as the drag is held, which is what lets a swing build. The cost is that `vx`
lags its target, so the object overshoots slightly - 4% in the first build - and the fix is a
faster velocity rate rather than a spring term.

**A speed ladder outruns any tool whose lag is measured in seconds.** Speed compounding at 5%
a street is invisible for four streets and then quietly removes the game: the window a target
is aimable in shrinks by the same fraction every level while the swing takes exactly as long
as it always did. By street 10 a building passed faster than the ball could be swung at it,
and by street 20 at half that. A design test caught it - `window > lag`, at levels 1, 5, 10
and 20 - and the fix was to cap speed and make later streets harder by growing the *targets*
instead. **Any game with a charge time, a wind-up, a reload or a lag should assert that
relationship at the top of its ladder, not just at the bottom.**

## The chain: constraint and restoring force

**Solving a constraint by moving a thing and not touching its velocity injects energy;
solving it by overwriting the velocity destroys momentum. Neither is the answer.** Wrecking
Crew's chain went through both. The first version projected the ball back onto the circle and
left its velocity alone - which adds energy on every taut frame and compounds, measured at
216 m/s on a machine that cannot exceed 9.5. The obvious fix, deriving the velocity from how
far the ball actually moved, is stable and *kills the swing*: a taut chain clamps the ball to
a circle, so its per-frame displacement is small, so the derived velocity is small. The player's
words for those two faults sitting on top of each other were **"it flies out too much but also
feels like it doesn't have enough momentum"**.

The correct constraint **zeroes the RADIAL component of the ball's velocity relative to the
anchor, and leaves the tangential component completely alone.** Tangential is the momentum, so
it carries. Radial is the stretch, so it cannot. It cannot inject energy either, because it
only ever removes a component - which is what makes it stable without needing the displacement
trick at all.

**A restoring force has to be proportional to the displacement, or the thing has no period.**
The same chain pulled toward its anchor with a constant magnitude, which does not care how far
out the weight is - so once it was out, it stayed out. `g * offset / length` is one line, and
a period is what makes a swing read as a swing rather than as a weight being dragged on a
string.

**Every improvement to how hard a hit lands is a change to how long a level takes.** Fixing
the chain roughly doubled the damage a pass delivers, and a room that had been a minute's work
went down in eight seconds. The two numbers are one decision and have to be re-balanced
together, or the level loses its middle.

## What the pendulum turned out to be as a mechanic

**A condition with no middle setting is not a mechanic, whichever way it lands.** Wrecking
Crew's ball rises as it swings out, so the obvious rule was that it can only damage a
building it is not sailing over - a big swing takes the tops off towers, a gentle one is
needed to finish a stump. It sounded like the best idea in the design and it has exactly two
behaviours. With buildings two floors and up it never fired once: a hidden condition that is
always true, which is strictly worse than no condition, because it costs code and comprehension
and buys nothing. With one-floor shopfronts in the mix it fired on nearly all of them, and the
whole of the first street - the part that actually gets played - became immune to the only tool
in the game. Measured: the aiming bot felled two floors in thirty seconds.

The test for this before building it: **name the setting where the condition fires about half
the time.** If the answer needs the rest of the game to be tuned around it, it is a wall
wearing a decision's clothes. The choice it was meant to create was real and worth having -
how hard to swing, not just when - but it has to be a cost rather than a gate, and it has to
be on the HUD.

**A dominant strategy with no cost attached is not a mechanic, however good it feels.**
Wrecking Crew's ball reaches further the faster it is swinging, and nothing anywhere charges
for swinging flat out - so maximum swing is never wrong, and a bot that ignores the street
entirely and waves the crane on the ball's own period scores level with one that reads the
street and picks targets. The tell is not that the game is easy; it is that two completely
different intentions produce the same number.

**Check for it by asking what a wild version of the input costs**, and if the honest answer
is "nothing", the mechanic is a rhythm rather than a decision. The fixes are all forms of
making the sweep selective: targets worth different amounts, a cost per swing, a cap on
contacts, or a reward that scales with how square the hit was. Density is NOT one of them -
thinning the content made the aiming bot *worse*, because it started committing to things
that were not there yet, and the waving bot's advantage grew.

**Do not paper over one of these with a test that enshrines it.** Assert the thing that IS
true and valuable, write the problem down where the next session will read it, and leave the
assertion for when the fix lands.

**The best version of a greed mechanic is one where greed genuinely pays, right up until it
does not.** Wrecking Crew's collapse used to be measured by "does leaving earn more than
staying" - and once the driving was fixed, it stopped being true: the policy that ignores the
collapse puts twice the columns down and banks more rubble before the ceiling lands on it.
That is not a broken mechanic, it is the correct one, and the assertion was what needed
changing. **The claim is not "the safe option scores higher". It is "the reckless option
never actually works."** If a player who ignores the threat can still finish, the threat is
scenery; if the safe option simply scores more, there was never a decision.

## Making the lag visible

**A control the player cannot see themselves using is a control they cannot learn.** Wrecking
Crew's first build drove the ball from the rig's lateral acceleration: aiming was the entire
game and the only feedback on your aim was whether you hit something. Gideon's note after one
session was to make the crane rotate instead - the same lag, the same lead, but with a boom
visibly pointing where he had dragged. **Indirect control needs a visible intermediary**: the
thing the input moves directly has to be on screen, so the lag reads as the tool trailing
rather than as the game not responding.

Two things make that work rather than merely look nicer. **Draw the intermediary and the
trailing thing as separate objects** - the gap between the boom and the ball IS the lag, drawn,
and it is the whole tutorial. And **give the machine a part that reads its own orientation from
behind**: a counterweight opposite the boom is the only thing that says which way the turret is
facing when the boom points away from the camera.

**When the tool's dimensions change, every framing decision calibrated on the old ones is
wrong.** Shortening the boom to a third of its length - which the design required, because "at
rest the tool falls just short of the target" was the load-bearing number - compressed the whole
machine toward the camera and put a two-metre ball across a quarter of a portrait screen. The
camera had to go back nearly half as far again. Re-shoot after any change to a length.

The dial below was replaced by a slider one build later at Gideon's request (see the
one-dimensional-control paragraph further down); it is kept because the point it makes -
draw the lagging thing on the control - survived the change of shape.

**Draw the control as the thing it controls.** Wrecking Crew's crane dial is a top-down picture
of the machine: the tracks, the turret, a boom pointing where you have dragged, and - the part
that earns it - a dot for the ball at its ACTUAL bearing, which is not where the boom is
pointing. The gap between the two is the lag the whole game is built on, and putting it on the
control means the player can read their own aim without looking up at the crane. A generic
stick would have shown the input; this shows the *state*.

Drive it from the same source the world uses (`sim.yaw`), never from the drawn object's
transform, so the control and the thing it controls cannot disagree.

**And an on-screen control should be absolute, not relative.** A relative mapping lets the
thumb and the dial drift apart until the picture no longer says where the machine is pointing,
which defeats the entire point of drawing it.

## The rig underneath: steering, camera frame, throttle

**A fixed camera and vehicle-relative controls are tank controls, and players feel it before
they can name it.** Wrecking Crew's machine took a throttle and a steer while the camera held
a fixed orientation - so whenever the machine faced back toward the lens, forward on the stick
drove it DOWN the screen and right turned it left. Gideon's report was "the driving controls
almost feel backward but not sure if that is the main issue", which is exactly what a control
scheme that is correct half the time produces: not a clear complaint, a nagging one.

**The rule: the frame the CONTROL speaks in must match the frame the CAMERA speaks in.** A
camera that turns with the vehicle can take vehicle-relative input. A fixed or world-aligned
camera needs world-relative input - push the stick where you want to go, and let the vehicle
work out its own heading. Mixing them is the bug, and it is invisible in any test that drives
the input seam directly, because at the seam both schemes look identical.

**Give a one-dimensional quantity a one-dimensional control.** The boom only slews, and it
had a dial - so the thumb had to be placed precisely on a circle to say something a line
could say, and the vertical half of every drag was thrown away. Gideon: *"the controls don't
need to be a dial look. since we are only controlling the turning, it could just be a left
and right joystick or slider."* A wide slider also buys precision for free, because width is
pixels per radian.

**And put the lagging thing on the control next to the thing being controlled.** The slider
carries the boom's knob AND a small mark where the ball actually is. The gap between them is
the lag the whole game is about, and it can be read without tracking two objects in the 3D
view at once.

**"It feels like it drifts" usually means the PATH curves, not that the physics slide.**
Wrecking Crew's machine has never had a lateral term - every step's displacement lies along
its own heading, and there is a test asserting it. What it had was a throttle floor of 45%
that applied through even a 180-degree correction, so every change of direction came out as a
long arc. Under a camera that holds a fixed orientation, a vehicle sweeping a curve reads as
a vehicle sliding. **Check the path before you check the integration**: the player is
describing the shape they see, not the term you are looking for.

**A tracked vehicle is one constant away from a car: the cone it must be facing within before
any throttle is applied.** Outside it, counter-rotate and do nothing else; inside, ramp the
throttle in as the nose comes round. That is the whole difference, and it is what "hold right
and it turns to face right, then moves" actually is. Pair it with a turn rate that is fast at
a standstill and much slower at speed, or the machine carves out of every turn anyway.

**A displacement test has to exclude the frames where something legitimately teleports the
object.** The "moves only along its heading" test failed immediately on the wall clamp, which
writes position directly and is a correct sideways displacement - the alternative being to
drive through concrete. Skip those frames and say why in the test, or the next person deletes
a true assertion.

## Do not build a gameplay pendulum out of the physics server

(From `PIPELINE.md`.)

The obvious way to hang a wrecking ball in Godot is a `RigidBody3D` on a `PinJoint3D`. That
puts the outcome of every run inside the physics server, at the mercy of its tick rate and
its solver, and ends any possibility of a whole-run golden. Thirty lines of arithmetic -
`L*theta'' = -g*sin(theta) - a_pivot*cos(theta) - c*L*theta'` - is deterministic, runs
headlessly, and is testable at 120 fps against 60. **Physics is for debris, which decides
nothing.** The same reasoning applies to any engine feature that would own a number the game
is scored on.

## Measuring the manoeuvre and testing the physics

**Sweep a manoeuvre rather than reasoning about its timing.** "Turn back when the tool reaches
its extreme" is the intuitive rule for a pendulum and it is wrong: it ignores that the vehicle
has to travel too, and the vehicle's own trip is most of the amplitude. Swept across load
times, a quarter-period load peaked at 4.19 and a half-period load at 6.76 - a 60% difference
that no amount of thinking about pendulums produced. Ten lines of throwaway script, and the
numbers went into the test's comment so the next person does not re-derive them.

**A test that samples one instant is testing its own timing.** The first version of that
assertion read the tool's position after the manoeuvre, found it 2.6 metres the wrong way, and
looked exactly like the physics being inverted. It had simply arrived half a swing late. The
thing being asserted was only true for a moment - and that moment is the whole game - so the
assertion has to be on the peak over the window, not on the end state.

**A saturating value stops being a consequence and becomes a constant.** Wrecking Crew's ball
swings further out the faster it travels, which is what makes reach a result of how hard you
swung. With the gain set high and the cap low, the radius sat PINNED at its cap for most of
every sweep - so the ball blanketed a band twice the width of the street, could not miss, and
the mechanic silently became "the ball is always at maximum reach". **Any value clamped at the
top of its range is only a mechanic in the part of the range it actually moves through**, so
put the cap somewhere the value rarely gets to, and measure what fraction of the time it is
binding rather than assuming.

**A hand-derived ceiling is the wrong test for "is this physics stable".** Wrecking Crew's
energy test computed a bound from the machine's top speed and its rotation rates and asserted
the ball never exceeded it. It failed - correctly, and for entirely the wrong reason: driving
a pendulum near its own period PUMPS it, so the speed legitimately climbs well past anything
one push can produce. That is resonance, not a leak.

**Assert SATURATION instead.** Drive adversarially for a minute, take the worst speed in the
first half and the worst in the second, and require the second to be within a few percent of
the first. Real damping settles to a steady state; an energy leak grows without bound. The
test then says the thing you actually mean, and it stops firing on legitimate play.

**A safety clamp that fires in normal play cannot signal anything.** The same game capped ball
speed at a number ordinary hard driving reached, so the clamp was on much of the time and the
runaway it existed to catch would have been indistinguishable from a good swing. Set a guard
ABOVE anything legitimate, and assert in the tests that it never fires.
