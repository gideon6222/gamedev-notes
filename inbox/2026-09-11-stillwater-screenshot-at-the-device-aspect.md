# A screenshot at the wrong aspect ratio hides anything near the edge of the frame

**Stillwater, 2026-09-11.** The fifth fight puts three of its four readouts on the fishing
rod - the bend, the shake, and the line going red - plus a new reeling animation on the reel
handle. All of it was invisible on the phone. The rod's mount put the reel **more than a
full viewport width off the left edge** at the device's real 19.5:9.

It survived a screenshot review because the shot was taken without a resolution flag, so it
came out roughly square, and at square the rod butt was just in shot and looked fine. The
repo's own `shot.gd` header said to pass `--resolution 460x996`. I had not read it.

**Two things to take from it:**

1. **Screenshot at the device's aspect or do not screenshot.** A portrait phone is not
   nearly square, and an "expand" stretch mode means the canvas the game renders into is the
   DEVICE's. Every check at a different shape is a check about a screen nobody owns.
2. **A screenshot is not the instrument for "is this on screen".** Build the measurement:
   `probe_rod.gd` prints each part's position as a fraction of the viewport, with anything
   outside 0..1 marked OFF. That turned a subjective look at a picture into five numbers per
   run, and turning the mount into a measured sweep then took three runs.

Screen position near the eye is also violently non-linear - the rod butt is half a metre
away, so a centimetre of mount moved it a third of a screen, and two of the three sweeps
overshot straight past the frame to the other side. Not a thing to eyeball.

The guard that now protects it projects by hand rather than calling `unproject_position` -
see [[headless-harness-has-no-global-transform]].

Related: [[a-screenshot-proves-one-state]]
