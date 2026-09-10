# Audit of CRAFT.md and PLAYTESTS.md

Files audited: `/mnt/user-data/uploads/dev/gamedev-notes/CRAFT.md` (2,258 lines, 27,284 words, 156 KB) and `/mnt/user-data/uploads/dev/gamedev-notes/PLAYTESTS.md` (811 lines, 9,009 words, 50 KB). Date of audit: 2026-09-10. Everything below is from a full read of both files; line numbers refer to the files as they are today.

---

## 1. CRAFT.md structure

### Heading inventory

Every `#`, `##` and `###` heading in file order. "Bold lead-ins" counts paragraphs that begin with a bold rule sentence, which is the file's unit of "one lesson".

| Lines | Words | Bold lead-ins | Heading |
|---|---|---|---|
| 1–14 | 94 | 1 | `# CRAFT.md` (preamble: "Organised by topic, not by date") |
| 15–34 | 179 | 1 | `## Recording: do it when you learn it` |
| 35–88 | 617 | 9 | `## The loop` |
| 89–173 | 1,017 | 12 | `## Progression` |
| 174–319 | 1,859 | 20 | `## Tension` |
| 320–348 | 315 | 1 | `### One difficulty knob that swamps the others is a design bug, not a tuning problem` |
| 349–528 | 2,182 | 29 | `## Legibility` |
| 529–733 | 2,564 | 32 | `## Feel` |
| 734–1392 | **8,525** | **96** | `## Graphics that carry on a phone` |
| 1393–1436 | 453 | 6 | `## Audio design` |
| 1437–1473 | 346 | 1 | `## Feel is layered, and the layers are ORDERED` |
| 1474–1487 | 122 | 0 | `## An action with no affordance is an action that does not exist` |
| 1488–1849 | 4,606 | 45 | `## Testing design, not just code` |
| 1850–2000 | 1,777 | 22 | `## Traps that have cost time more than once` |
| 2001–2025 | 247 | 6 | `## Working with Gideon` |
| 2026–2053 | 317 | 3 | `## Build the meta-game and you will find out what the economy actually does` |
| 2054–2065 | 121 | 0 | `### Measure a progression by PLAYING it, not by dividing` |
| 2066–2076 | 107 | 0 | `### Keep the money in the units of the game you are copying` |
| 2077–2098 | 258 | 1 | `## A rewrite is the right call when a game keeps inheriting a shape it never wanted` |
| 2099–2117 | 189 | 1 | `## "Unavailable" and "not a control" must not look the same` |
| 2118–2146 | 304 | 0 | `## Vertex-displaced water: displace the swell, normal-map the chop` |
| 2147–2166 | 185 | 0 | `## Post-processing is the cheapest mood tool there is, and the last one reached for` |
| 2167–2196 | 328 | 1 | `## Making an artefact less visible is not fixing it, and it costs you everywhere else` |
| 2197–2228 | 342 | 0 | `## Ambient particles must be anchored in the world, not to the camera or the player` |
| 2229–2259 | 312 | 1 | `## A test that asserts a literal instead of the property fails for the wrong reason` |

Roughly 290 bold-led lessons in total. Game mentions by name: Coreward 56, Stillwater 26, Candle Gift 19, Wrecking Crew 15, Captain Run 11, Wick 9.

### Verdict: topic labels on top, chronology underneath

The file claims (line 3) to be "Organised by topic, not by date". That is true of the first nine `##` headings as *labels*, and false of the content in three distinct ways:

**(a) The section bodies are appended in session order.** Within every topical section the paragraphs run Coreward → Captain Run → Wick → Candle Gift → Wrecking Crew → Stillwater, which is exactly the chronology of PLAYTESTS.md. `## Tension` is the clearest case: it opens with Coreward (tremors, zones), moves to Wick (water/heat), then Candle Gift (trailing tray), then four paragraphs on Wrecking Crew's ball and chain (lines 250–319) — which are about pendulum physics, not tension — and closes with a Stillwater H3 on difficulty knobs. `## Feel` opens with five Stillwater paragraphs about fishing-fight *design* (threshold fights, rhythm, wear clock — lines 531–560), which are difficulty/balance lessons, before it reaches anything about feel. `## Legibility` ends with 140 lines of Wrecking Crew (boom, counterweight, lean gauge) that were clearly written in one sitting and dropped at the end of the nearest section.

**(b) `## Graphics that carry on a phone` is a catch-all, not a topic.** At 8,525 words it is 31% of the file and contains 96 lessons, of which perhaps a third are about graphics performance. The rest cover: the entire Coreward propagated-lighting technique (lines 763–923, ~1,600 words); DOM gauges in SVG (950–964); HUD material and pressed-button styling (966–980); three.js rotation order (990–1002); post-processing vs CSS skies (1004–1018); PBR/metal/toon material notes (1020–1064); portrait FOV (1066–1076); Stillwater's sun, fog and boat (1078–1101); the Godot `draw` visibility latch (1150–1170); Candle Gift's end-of-run camera, ROTATE wall, starting-with-one-candle, monetisation copying, liquid feel, reference-video research, HUD-as-claim, and magnifying screenshots (1175–1277); shop-as-room design (1286–1329); the Wrecking Crew dial and Stillwater's thumb-over-gauge (1335–1389). None of the last six groups is graphics. It is the section a session appended to when nothing else fit.

**(c) Everything after `## Working with Gideon` (line 2001 onward, ~2,700 words) is pure chronological accretion.** Ten `##` headings, each a single essay from a single session, each named as a full sentence rather than a topic: economy, rewrite-vs-revise, unavailable-vs-not-a-control, water shader, post-processing, dimmer-switch fixes, dust particles, literal-vs-property tests. Every one of these has a home in an earlier section (economy → Progression; dimmer-switch → the "note that survives a fix" lesson already in Graphics; literal-vs-property → Testing; water/post/particles → Graphics). They were not filed; they were appended. Two more mid-file sections have the same shape: `## Feel is layered, and the layers are ORDERED` and `## An action with no affordance…` (lines 1437–1487) are Stillwater-session essays wedged between Audio and Testing.

The heading style itself records the drift: early headings are nouns ("The loop", "Feel"), later ones are sentences ("Making an artefact less visible is not fixing it, and it costs you everywhere else"). The preamble's own history ("This used to be a chronological log. It grew to nine hundred lines") is now repeating at 2,258 lines.

---

## 2. Duplicated or overlapping lessons

Clusters where the same point is made in two or more places. Headings quoted are the bold lead-ins of the paragraphs involved.

| # | Point | Where it appears |
|---|---|---|
| D1 | A system that applies itself to everything is not a mechanic (Candle Gift stations, identical value across four play styles) | Tension: "Put the resource ON THE GROUND…" + "if a system applies itself to everything you own, it is not a mechanic" (227–238); Testing: "If a system applies itself, the player is not playing it" (1624–1630). Same game, same measurement, told twice. |
| D2 | Delete the stand-in when the real system arrives | Graphics: "When you replace the reason for a workaround, delete the workaround in the same commit" (908); "When a lighting model lands, audit everything that emits light" + "A fake put in before the real system exists does not announce itself" (917–923); "Delete the fake when the real thing arrives" (931). Three consecutive-ish paragraphs, one rule. |
| D3 | A complaint that survives a correct fix is about something else / stop tuning, start measuring | Graphics: "A note that survives a correct fix is a note about something else" (824–827); "when a symptom survives two correct fixes, stop fixing and start measuring" (905); whole section `## Making an artefact less visible is not fixing it` (2167–2196); Traps: "If adjusting the obvious parameter changes nothing at all, stop adjusting it" (1902); Working with Gideon (2009). PLAYTESTS also states it twice. |
| D4 | Surface light vs air light are two lights | Graphics: "Light on surfaces and light in the air are two different lights" (811–822); the shadow-fan far-corner paragraph (829–836); the "Making an artefact less visible" section's mechanism paragraph (2188–2193). |
| D5 | Fire visual + audio + camera (+ haptics) together | Feel: "Layer three feedback channels on every action" (566); Audio: "Sound is one of the three feedback channels" (1409); Feel-is-layered: "Fire the channels together… four channels" (1464). Three statements; the count disagrees (three vs four). |
| D6 | Hit-stop | Feel: "Hit-stop is the highest value per line of code… 35–80 ms" (562); Feel-is-layered: "Hit-stop freezes the PICTURE, never the rules" (1470). Complementary, should be one bullet. |
| D7 | Portrait horizontal FOV is tiny; compute the visible width at the object's distance | Graphics: "Portrait's HORIZONTAL cone is tiny" (Stillwater, 58° → ~28°, 1066–1076); "Lay a 3D shop out for the aspect ratio you actually have" (Coreward, 46° → ~22°, 1325–1329); "A 3D shop still needs labels… ~3.5 world units across 375 CSS pixels" (1296–1302). Same arithmetic three times. |
| D8 | Metal needs an environment map and the env map needs `colorSpace` | Graphics: "A metal with no environment map has no diffuse term" + "And set `colorSpace` on it… about four times too bright" (1028–1039); Traps: "A metal gets its colour almost entirely from its environment map… about two and a half times too bright" (1898–1904). Same lesson, and the two numbers disagree. |
| D9 | Don't light the player vehicle with the gameplay lamp | Graphics: "Do not light the player's vehicle with the gameplay light" (1041); Traps: "`Object3D.layers` does not stop a light…" + "Excluding a light from an object means a second render pass" (1886–1896); related "Put the source glow BEHIND the character" (937). |
| D10 | Single source of truth: derive the picture and the score from one state | Legibility: "Derive the silhouette from the state, never store it alongside" (448); Feel: "Derive the interaction from the collision, not alongside it" (579); Graphics: "Show the REAL object in the shop, not a preview" (1318), "Drive it from the same source the world uses" (1342); Feel-is-layered: generate GLSL from one GDScript array (1456); Affordance: caption "DERIVED from the state by the same function that performs it" (1482); Legibility: lean gauge "direct reading of the same number the building is drawn leaning by" (504). Seven instances of one principle. Note the surface contradiction with Feel: "Store the fact; never re-derive it" (604) — that one is about not reconstructing from rounded continuous values, and the two need to be stated together or they read as opposites. |
| D11 | The shop must be a place, not a panel | Graphics: "A panel over the game is a pop-up however you style it" (1286); "And a list is a list however you style it" (1290); "if the player is meant to feel they are somewhere, the somewhere has to be geometry" (1293). The first is the superseded fix; the second is the fix that stuck. |
| D12 | Constants that must agree need a test, not a comment | Tension: "Couple numbers that must agree with a test" (202); Testing: "CONSTANTS THAT SHARE A FORMULA MOVE TOGETHER, and a test on the DERIVED quantity is what catches it" (1584–1597); "Two gates on one thing means one of them is decoration" test (121). |
| D13 | Test the case where two rules actually differ | Feel: "Store progress as a share… assert that the two interpretations actually *differ*" (608–612); Testing: "A test of a PRIORITY has to use the case where the priorities disagree" (1668–1675, cross-references the first). |
| D14 | Tests that cannot fail | Testing: "Every fixture agreeing on a convenient value is how a whole suite misses a bug" (1642); "Snapshot the pure functions… then make the snapshots fail" (1677); section `## A test that asserts a literal instead of the property` (2229–2259, "a construct that cannot fail is not safe, it is untested"); Traps: "A test that hard-codes a layout it did not choose" (1873). |
| D15 | Look at the screen, not the assertions | Graphics: "assert that a thing is ON SCREEN, not merely configured" + "Screenshot the SHORT states, deliberately" (1161–1170); Unavailable section: "Take a picture of every screen you build, once, and look at it" (2110–2114). |
| D16 | Bots need human faults, and a bot that beats everything proves nothing | Testing: "A PERFECT BOT WINNING IS NOT EVIDENCE ABOUT DIFFICULTY" (1534), "The fix is a bot with human faults, and it has to have MEMORY" (1544), "MODEL THE INPUT DEVICE, NOT JUST THE DECISION" (1560), "And when the model needs memory, every caller has to hold it" (1577). Four paragraphs (~700 words) that are one lesson deepened three times. |
| D17 | One definition of "playing well", shared by bots and tests | Testing: "A bot is a definition of 'playing well', so it has to live in the repo" (1742); "A test helper that plays the game is a second, worse player" (1825). |
| D18 | Ambient light is the enemy of a lamp-in-a-hole look | Graphics: "ambient has to fall away much faster" (1020–1026); "Cel shading… turn the ambient down — it is the one light that reaches every surface equally" (1054–1058); "Make the framing an upgrade, then make the darkness justify it" (1108); "Three stops in a vignette" (1112). |
| D19 | Draw-call cost and instancing | Graphics: "Instancing is the whole game" (736), "Instance the body parts" (751), "Instance the bolt-on hardware too" (756), "Frustum culling will not save you from something dead ahead" (1203), "Decorative meshes that are not instanced cost the same as the thing they decorate" (1279). Five paragraphs; two general rules. |
| D20 | The visible thing must be the reward, hazards in one family | Legibility: "The most valuable thing on screen must be the brightest" (411), "A hazard must not resemble a reward" (393), "Every hazard in one colour family" (1268 in Graphics), "Silhouette carries more than colour" (387). |
| D21 | Announce the threshold / align the boundary / test the alignment | Tension: "Announce a zone before charging for it" (194), "A threshold the player cannot see is not a mechanic" (197), "Couple numbers that must agree with a test" (202) — three paragraphs on one Coreward fix. |
| D22 | Discovery and surprise | The loop: "Discovery moments stop routine work going stale" (57) and "Aim a surprise at the current bottleneck" (61). |
| D23 | Control and readout: dial vs slider | Feel: "Give a one-dimensional quantity a one-dimensional control" + "put the lagging thing on the control next to the thing being controlled" (700–710); Graphics: "Draw the control as the thing it controls" (dial, 1335–1347). The dial paragraph describes a control that was replaced by the slider; both paragraphs make the same "the gap is the lag" point. |
| D24 | Bot-vs-design ambiguity | Testing: "If the policy that reads the level loses to the policy that ignores it, the bot is wrong before the game is" (1764) vs "When two policies score the same, that IS the finding" (1804). The text admits the first "was right once on this game and wrong the next time"; the resolution ("Sweep the bot's parameter before touching the game's") is what should survive. |
| D25 | He plays the opening / plays the menus first | Working with Gideon: "He plays the opening" (2012); PLAYTESTS repeats this at 2026-09-07 (three times) and adds "the first thing he does with a new build is open the menus". |

---

## 3. Contradictions and stale rules

### 3a. Rules that only make sense for the web/PWA (three.js/DOM) stack

These are correct lessons about three.js/WebGL/DOM and mostly have no Godot 4 equivalent — or have a *different* equivalent, which makes them actively misleading when read by a Godot session. Together they are roughly 3,000 words (~11% of the file).

| Lines | Rule | Why it is stack-bound |
|---|---|---|
| 736–761 | `InstancedMesh` per body part, `count` as the lever | Godot: `MultiMeshInstance3D`; the principle (draw count independent of content count) survives, the API does not. |
| 742–749 | "5.0 microseconds per call… about 3,200 calls… high hundreds at worst on a phone" | Measured in WebGL on a **desktop**; the phone figure is inferred ("at worst"). Godot's Vulkan/GLES3 costs are different and unmeasured here. |
| 950–964 | SVG `pathLength="100"` gauges, generated tick marks | DOM-only. Godot draws gauges with `_draw()` / `TextureProgressBar`. |
| 966–976 | 64 px canvas grain texture built at boot from a deterministic hash | Canvas API; Godot would use a NoiseTexture2D or a shader. |
| 982–988 | `setColorAt`; per-instance data cannot fade across a boundary | three.js API; second half generalises. |
| 990–1002 | `rotation.order = 'ZYX'` | three.js Euler convention. Godot's `Node3D.rotation_order` exists but defaults differ (YXZ). The general lesson (check compose order when a second rotation is added) survives. |
| 1004–1018 | Fake bloom with additive sprites; CSS gradient sky vs `EffectComposer`/`UnrealBloomPass`/`OutputPass` | Entirely three.js. Godot has built-in glow in `Environment`, so "post-processing bloom costs a library and a pass" is false there. |
| 1020–1039, 1898–1904 | Lambert → `MeshStandardMaterial`; `PMREMGenerator`; `CanvasTexture` `NoColorSpace` | three.js. Godot's sky/reflection probes handle the env map; "data textures must not be sRGB-decoded" is the transferable half. |
| 1054–1064 | `MeshToonMaterial.gradientMap`, inverted-hull outline scaled per axis | three.js API; Godot has toon shading in the material and outline via shader. |
| 1103–1106 | `FogExp2` is camera-distance; use a point light | The observation transfers; the API does not. |
| 1122–1125 | `vNormalMapUv` override in vertex shader | three.js internals. |
| 1138–1148 | `PlaneGeometry` faces +z, `FrontSide` culling | three.js defaults; Godot's `PlaneMesh` faces +y. |
| 1172–1173 | "Gradient skies for free. Render with `alpha: true`… CSS gradient" | Contradicted by 1008–1018 (see 3c) and irrelevant in Godot. |
| 1331–1333 | "One scroll region per screen" (`overflow-y` in a flex column) | DOM. Godot `ScrollContainer` has its own failure modes. |
| 1859–1871 | Missing GLSL uniform is silent; test by reading `gl.getShaderSource` | Godot shader uniforms have declared defaults and are inspectable differently. The general rule ("half a feature working is the worst symptom") survives. |
| 1886–1896 | "`Object3D.layers` does not stop a light from reaching an object… second render pass" | **Backwards in Godot**: `Light3D.light_cull_mask` and `VisualInstance3D.layers` do exactly this. A Godot session reading this rule would build a needless second pass. |
| 1906–1922 | `onBeforeCompile` chaining, `Material.clone()` losing it | three.js only. |
| 1924–1947 | Chase camera looking along +z mirrors x; NDC test | Camera-space sign convention is three.js-specific (Godot's camera looks along −z by default, so the trap is inverted). The **test** ("drive real pointer events and assert where the avatar is in the frame") is the keeper. |
| 1949–1953 | `updateMatrixWorld(true)` before a raycast | three.js. |
| 1955–1960 | Second `Scene` does not inherit layers/lights/background | three.js scene model. |
| 1962–1965 | `requestAnimationFrame` to draw, never to undo; `setTimeout(20)` | Browser scheduling. |
| 1967–1970 | Headless tick seam behind `?debug` | Browser; Godot equivalent is a headless `--script` run, already in use (`shot.gd`). |
| 1972–1974 | `localStorage.clear()` + `visibilitychange` | Browser. |
| 1710–1711 | `Math.imul` for 32-bit multiply | JavaScript double arithmetic; GDScript ints are 64-bit. |
| 2019–2024 | "Ship, then check. Push to `main`… Do not gate on a preview or poll the live site." | GitHub Pages deploy loop. With native Android the ship step is an APK build/install; the *spirit* (don't wait for permission, let him test on the phone) survives. |

Note that `## Traps that have cost time more than once` (1850–2000) is about 80% three.js/browser traps by word count.

### 3b. Rules from an era when Claude could not run code or push binaries

- PLAYTESTS 2026-09-07: "the GitHub connector cannot push binary, so on the five-file stack those assets are unreachable until a game earns a build step" — this is why CRAFT's asset stance ("Answered with a font and a reasoned no on the 3D models") exists. That constraint is gone; the surviving rule from Wick ("the candle's shape is gameplay state; no imported mesh can do that") is the generalisable one, and it is in PLAYTESTS, not CRAFT.
- Feel, line 618: "Fixing that lerp could have changed how the camera feels, which is the one thing a desktop cannot verify." Written when there was no device loop; still true-ish but the framing is dated.
- "Fake bloom with additive sprite halos" (1004) and "Post-processing is the cheapest mood tool there is, and the last one reached for" (2147) are written from opposite eras: the first avoids post because on the web stack it broke the CSS sky; the second (Godot) embraces it. The file does not say the first is obsolete.

### 3c. Rules that contradict each other

| Rule A | Rule B | Notes |
|---|---|---|
| "Gradient skies for free. Render with `alpha: true` and no scene background, then put a CSS gradient behind the canvas." (1172) | "A gradient sky in CSS and real post-processing are mutually exclusive… put the sky in the scene from the start" (1008–1018) | A survived after B was learned. A should be deleted. |
| "Depth is a currency that cannot be farmed… it should be *shown*, not hidden: a row that says 'Sealed until 90 m'… A hidden row is nothing at all." (97–100) | "Show the NEXT locked thing, not all of them. Corrected on 2026-09-09… everything unlocked, plus exactly one teaser" (102–119) | The correction is well written but the original rule still sits above it, unedited, as a rule. |
| "Draw the control as the thing it controls… a top-down picture of the machine… a dot for the ball" (1335–1347); "an on-screen control should be absolute, not relative" | "Give a one-dimensional quantity a one-dimensional control… it could just be a left and right joystick or slider" (700–706) | The dial was replaced by a slider at Gideon's request one build later (PLAYTESTS 2026-09-09). The dial paragraph now describes a superseded control as a model. |
| "A panel over the game is a pop-up… Hide the game entirely, give the screen a window… put the exit at the bottom where a door would be." (1286) | "And a list is a list however you style it. That fix was still a scrolling list… make it a room." (1290) | The first is a failed intermediate fix presented as a rule. |
| "Believe the symptom, then go and find the cause yourself. He is reliably right that something is wrong and not always right about why." (2009) | PLAYTESTS: "when he proposes a mechanism, build that mechanism" (635); "He was right about the mechanism, and I was not" (764); "Six sessions now. Every mechanism he has proposed has been the right one" (810); CRAFT 2188: "Players describe mechanism, not just symptoms, and they are often right" | The `## Working with Gideon` section is stale relative to the evidence file it summarises. It undersells him and the newer, stronger rule lives only in PLAYTESTS. |
| "Layer three feedback channels" (566, 1409) | "four channels" including haptics (1464) | Trivial but a rewrite should pick one. |
| Env map "about four times too bright" (1037) | "about two and a half times too bright" (1901) | Same fact, two numbers. |
| "the draw-call guideline was off by more than an order of magnitude… do not let it talk you out of a feature" (742–749) | "took the worst case from 55 draw calls to 67 against a budget of 70 — three from failing CI" (756–758); "Frustum culling… twelve draw calls where the peak is" (1203); "gave back twelve calls" (1279) | Three later paragraphs still treat a budget of ~70 as the thing to protect, after the file itself says that budget is a regression detector, not a limit. |
| "If the policy that reads the level loses to the policy that ignores it, the bot is wrong before the game is… Fix it before touching a single constant" (1764–1774) | "When two policies score the same, that IS the finding — do not go looking for a third explanation first… which was right once on this game and wrong the next time" (1804–1809) | The file acknowledges the contradiction; only the sweep rule should survive. |
| "Derive… never store it alongside" (448) | "Store the fact; never re-derive it" (604) | Not a real contradiction (canonical state vs rounded reconstruction) but reads as one; needs to be stated as one rule with both halves. |

### 3d. Rules that read as guesses, cautions or literature rather than measurements

- "Three distinct resources is about the ceiling for comprehension and the floor for a real decision." (45) — asserted.
- "Rare enough that you cannot plan around it, or it becomes a resource." (59) — no number.
- "Keep stack limits small, price the consumable… above the first level of the upgrade… make a full kit cost more than several rungs" (130–134) — design assertion, Coreward consumables; no measurement recorded and PLAYTESTS never mentions him using them.
- "Scale full-height to roughly 1.5–2x the top threshold" (165) — rule of thumb.
- "Hit-stop… 35–80 ms" (563) — standard literature range, not measured on these games; nor has Gideon ever commented on hit-stop.
- "Keep it medium… Two degrees of shake decaying in a third of a second, not ten" (1467) — from Kao's study, not from these games.
- "latency… research puts consistent performance inside ~50 ms" (1525) — literature.
- "300 ms reaction time, a tell it misreads about one time in six, a thumb that wobbles ±0.055" (1545) — chosen constants for the human bot; they produce plausible numbers but were never calibrated against Gideon's actual play.
- "Fill rate is the real cost on a phone" (746) — inferred from a desktop PBR measurement (0.098 ms/frame); no phone frame-time measurement appears anywhere in the file.
- "Grain wants to be felt, not seen… three times too strong" (975), "Three stops in a vignette" (1112), "Ripples are centimetres… 6.5 and up" (2131), "Dust you can see needs a dark room and a beam" (2224) — eyeballed on one game each.
- "Spline flight beats stepping between waypoints" (650) — correct but the evidence is one Coreward complaint.
- "Exponential everywhere… top speed in about a fifth of a second and coasts about three quarters of a cell" (645–648) — these are the tuned values, not a measured preference; Gideon's only comment was "bouncy" on a *different* build.

### 3e. Rules derived from games Gideon never played

PLAYTESTS records that **Captain Run** ("first build, NOT YET PLAYED") and **Wick** ("first build, NOT YET PLAYED") were redirected into Candle Gift before he gave any gameplay feedback on either. Every CRAFT rule sourced solely from those two games is therefore bot-measured or reasoned, not playtested:

- Captain Run: "Give the run-scoped resource and the persistent one different jobs" (37), "Cap a visible resource at exactly the number you can render" (167), "Two upside gates beat a good gate and a bad gate" (142), "Where a fight resolves matters more than how long it takes" (206), "A marching grid reads better than a scatter" (477), "Instance the body parts" (751), "Kill rate, not damage" (1714), "Whatever the game tells the player to fight, the auto-attack must target" (1721). Worse: the hash bug (1697–1712) means the gates and brutes those rules describe "had never once run" in the shipped game.
- Wick: "Make a quality bonus a multiplier" (147), "Keep the price spread… narrow" (154), "hazard becoming the answer to another" (211), "If code has to judge whether two colours look different" (396), "Derive the silhouette from the state" (448), "Let damage reveal history" (454), "bands not shells" (459), "A hazard outside the steerable band is not a hazard" (1981), "Check the hitbox against the band" (1988).

Several of these are good design reasoning and worth keeping, but a rewrite should mark them as *unplayed* rather than as learned.

### 3f. Rules written so specifically to one game that they do not generalise

- The Coreward propagated-lighting stack, lines 763–923 (~1,600 words): flood fill, octile vs Euclidean, 15×36 `DataTexture`, ray-fan DDA with 512 texels, far side of the wall, far corner of the cell, `SURFACE = flood × falloff × beam / AIR = … × shadow`, `max()` not product, square the multiplier for sRGB, 3×3 texels per cell, `smoothstep(0.5, 0.98, mask)`, `NearestFilter` diagnosis. This is a superb technique write-up for a 2.5D grid miner and belongs in Coreward's own notes or a `TECHNIQUES.md`, with three or four general bullets left in CRAFT.
- Wrecking Crew's pendulum: radial/tangential constraint, `g * offset / length`, `sqrt(g/L)` solved for g, quarter- vs half-period load (4.19 vs 6.76), 45% throttle floor, alignment cone (284–309, 654–730, 1782–1846).
- Stillwater's fight constants: tease 0.34 vs take 1.0 depth, 0.26 s vs 0.4–0.85 s, `SAFE_HI * decay / pull`, 46 s wear clock, 0.42 s tell vs 0.30 s reaction, `decay × tension / kick`, 96% → 54% landing rate.
- Candle Gift's reference research: money 540 vs 18,000, par 39,134 vs 64,606, dodge-bot 18,158 vs 1,350, "no upgrade screen at all", `imageSmoothingEnabled = false` at 4×.
- Coreward HUD pixels: "Seven pixels of nineteen" (437); tremor "~27 seconds past 85 m" (186); "26 crew" (167); "within 30 m of its unlock depth" (122).
- Wick: road 7.6 wide, thumb crosses 5.0, blade sweep 1.29 of 1.5 half-band (1981–1992).

---

## 4. The generalisable craft knowledge, condensed

Roughly 110 bullets. Numbers are kept only where the file records them as measured (M) or as a tuned value that was accepted in play (T); literature values are marked (L). Everything else is a design rule that has been confirmed at least once by a playtest note.

### Feel / juice
- Before any polish, ask what the player controls *continuously*; if the answer is "nothing", juice will not fix it (Stillwater: "clunky" with a working sim and a film grade).
- Feel is layered in order: physicality (what moves) → amplification (juice) → support (invisible forgiveness); polish on top of no first layer looks good in screenshots and feels the same in the hand.
- Hit-stop is the highest value per line of code: freeze the *presentation* for ~35–80 ms (L) scaled to the event; never freeze the simulation clock, so golden tests stay valid.
- Fire visual, audio, camera and haptic channels as one event; any one alone reads as cheap.
- Keep juice medium (L): a couple of degrees of shake decaying in about a third of a second, not ten.
- An idle world reads as a screenshot; float the vehicle on the same wave function the water shader uses, generated from one source so they cannot drift.
- Movement on a cell timer reads as a spreadsheet; a velocity and a collision box was the largest single feel change in Coreward.
- Fly *along* the grid, not on it or off it: free travel on the pushed axis, continuous pull onto the centre line of the other; assert momentum, acceleration and coast distance in tests.
- Reach top speed in about a fifth of a second and coast under a cell (T); on a thumb, momentum reads as latency.
- Use `1 − exp(−rate·dt)`, never `min(1, dt·rate)`; when converting, translate tuned constants to the equivalent per-frame fraction so feel does not move.
- Apply corrections as a *velocity* through the normal collision path, never as a position write, or they are invisible to collision and tests.
- A smoothing term must be *assigned*, not added to an existing velocity, or it is an undamped spring ("bouncy").
- Never correct anything while the player is coasting; snap on the next input ("don't align until you change direction").
- High speed alone reads as fast-forward; a spline with ease-in/out and heading following velocity reads as piloted.
- Indirect control (a tool driven by acceleration or lag) needs the lag set as a feel constant (~1 s for a thumb, T) and the correct technique discoverable by accident, with the expert version reaching noticeably further.
- If a tool is driven by acceleration, approach a target *velocity* exponentially, never a target position, or the tool gets one kick and hangs.
- Any game with a wind-up, reload or lag must assert `window > lag` at the *top* of its speed ladder; 5% compounding per level quietly removes the game around level 10 (M, Wrecking Crew).
- A saturating value is only a mechanic in the range it moves through; cap where it rarely reaches, and measure how often the cap binds.
- Two motions sharing one variable will eventually be shown doing each other's job (a rod that bends on the cast).

### Controls / touch
- The frame the control speaks in must match the frame the camera speaks in; a fixed camera with vehicle-relative input is tank controls, and the report is "almost feels backward but not sure".
- A one-dimensional quantity gets a one-dimensional control (a slider, not a dial); width is precision for free.
- Put the lagging thing on the control next to the thing being controlled, driven from the simulation's own state, so the player reads their aim without looking up.
- On-screen controls are absolute, not relative, or the picture stops saying where the machine is pointing.
- A readout glanced at can sit under the thumb; a readout watched continuously cannot — separate them, and if they fight for space change the verb (a tap has no position) rather than the layout.
- Indirect control needs a visible intermediary on screen (the boom, not just the ball), and the machine needs a part that shows its facing from behind.
- One finger, three verbs, discriminated by movement not time: drag looks, still-hold charges, tap taps.
- A verb hidden behind a gesture that already means something else is not a verb the player has; the action button's caption must be derived by the same function that performs the action.
- "It drifts" usually means the *path* curves (a throttle floor through a turn), not that the physics slide; check the path before the integrator.
- A tracked vehicle is one constant from a car: an alignment cone outside which it only rotates, plus a turn rate fast at rest and slow at speed.
- Lay out touch controls against the *real* viewport, not the project's base size, and test the hit region against the drawn control on a tall phone.
- Test steering by driving real pointer events and asserting where the avatar lands *in the frame* (NDC); world-coordinate tests pass on inverted controls (Captain Run shipped inverted for its whole life).

### Onboarding / first minute
- He plays the first sixty metres and opens the menus first; the shallow part and the screens are what get played, so weight effort there.
- A forgiving tutorial must still charge *time* for ignoring a mechanic, or it trains the player to ignore it and the next area punishes the habit.
- A station or pickup whose lowest tier is a no-op teaches the player to stop reading signs; floor every station at its first real effect.
- A transformation big enough to divide a level into before and after must be a wall that cannot be missed, not an optional station.
- Every state must name a visible action, and pressing the one visible control must always lead back to playing (no dead time); a way out only the simulation knows about is not a way out.
- Show version number and patch notes in the pause screen from the first build.

### Difficulty & balance
- Split *frequency* from *severity*: how often the dangerous thing happens teaches it, how much it hurts punishes it; tutorial = often and weak, endgame = rarer and strong.
- One knob that swamps the others is a design bug (Stillwater: `win ≈ 1.06 − 1.15 × run_chance`, M).
- A new knob must be a dial, not a cliff; give it an arithmetic ceiling and assert it.
- A "threshold fight" (hold the needle in the band) collapses to one sustained input; make gaining ground require a *rhythm* and assert that holding any constant value gains nothing.
- Give the player a risk dial they hold themselves: the greedy option is genuinely better and genuinely near the edge.
- Doing nothing must lose; a wear clock (~46 s, T) makes caution a cost.
- A sudden event should hit hardest at its start (surge decaying over ~0.3 s) so reading the warning beats reacting to it; this took a fish from 96% to 54% landed (M).
- A tell longer than human reaction time (~0.3 s, L) makes a mechanic free.
- Never let a hazard take the run: bound the worst case (re-run the pathfinder after a collapse, revert if home is unreachable) and test the bound.
- A moving obstacle needs a provably reachable gap: write down amplitude + half-width + tolerance against the steerable width before tuning frequency (Candle Gift's sweeper covered 61% at every point, M).
- A hazard outside the steerable band is not a hazard; route all placement through one lane helper and test its range; and check the *hitbox* against the band, by measuring loss while dodging vs standing still.
- A budget (swings, fuel) must be derived from the content, never set as a rate over it, and asserted sufficient at every level.
- Every improvement to how hard a hit lands changes how long a level takes; rebalance both together.
- A greed mechanic's claim is "the reckless option never actually works", not "the safe option scores higher".
- A dominant strategy with no cost is not a mechanic: ask what a wild version of the input costs, and if the answer is "nothing", add selectivity (targets worth different amounts, a cost per action, a cap) — thinning density makes it worse.
- Name the setting where a condition fires about half the time before building it; if none exists it is a wall wearing a decision's clothes.
- Difficulty is usually the product of two fields; assert the content table is a monotonic ladder in the order it is written.
- Measure per item, never as one mean; one mean over a ladder describes none of its rungs.
- Calibrate against five or six procedural seeds, never one; single-level numbers swing 25% on layout luck (M).
- Removing an obstacle kind removes its share of the danger; do not backfill the slot, and re-measure the system that competes for the same seconds.

### Economy / progression
- Run-scoped and persistent resources get different jobs; leftover run resource converts at the end.
- One resource that all converts to the same number is a difficulty slider in a resource system's clothes; three distinct resources is about the ceiling and the floor.
- A secondary objective must be a thing you *keep* (a collection), not a number that will look small next week; make the best reward missable.
- Rare surprises aimed at the current bottleneck stop routine work going stale; rare enough that they cannot be planned around.
- Gate an upgrade behind a *place*, not a price: the counter to a threat costs a material found inside the threat.
- Depth (or any unfarmable record) is the cheapest structural gate; show it.
- Show everything unlocked plus exactly one teaser, the shallowest thing still out of reach; assert at most one sealed row and never zero while something is gated.
- A rule about how much to show is a rule about a ratio and silently expires when the content count changes; re-derive it when a list doubles.
- Two gates on one thing means one is decoration; assert the gating material lives near the unlock depth.
- A weight or slot cap is what turns "which is worth more" into a decision.
- Consumables and permanent upgrades sit on different axes; small stacks, priced above the first upgrade rung.
- Quality is a *multiplier* on quantity, never an amount added, so both axes stay alive at every scale.
- Keep the price spread on a premium resource under ~2× (M, bots) or material value swamps every design bonus; any system meant to compete with raw quantity must be tested at equal quantity.
- If the player can pass the thing they are meant to destroy or gather, it is optional and the game has no stakes; ask what happens if they ignore it entirely.
- Cap a visible resource at the number you can render; overflow converts to currency with a visible popup.
- Three reasons to buy one upgrade beats three upgrades with one reason each; an upgrade you cannot see is bought on trust (make it change the framing, the beam, the finder).
- Build the shop early: a price next to an income is the first thing that shows the income is wrong.
- A hyper-inflationary value curve (1.55× per level, M) makes any price list meaningless; fix the curve upstream.
- Measure a progression by simulating play/bank/buy/next-level and reporting the level each thing is reached at; dividing a late price by early income measures a player who never got better.
- Keep money in the units of the reference so its prices remain usable calibration; one constant at one point.
- Contaminated-state bugs (bank counted as earnings) need an *invariance* test — same level, different starting bank, same reward.

### Camera
- Portrait's horizontal cone is tiny (58° vertical → ~28° horizontal; 46° → ~22°); compute visible width at the distance a thing sits before placing it, and rack shops vertically.
- Horizontal detail wants a low camera; vertical detail wants a high one; the angle is part of the art.
- Seat a first-person camera at seated height and draw the vehicle as an edge (gunwales), not a surface.
- A tight frame reads as "camera too close" unless darkness justifies it; make framing an upgrade and let the light's reach explain it.
- Any end-of-run camera move is a second placement pass over everything near the finish; put the camera behind the subject.
- Re-shoot after any change to a length; framing calibrated on old dimensions is wrong.
- A chase camera's handedness must be checked with the NDC test, and the axis convention chosen so no sign flip sits near the input.

### Visual legibility & art direction
- Do not invent a symbol for something you can show; a bar is right only when the quantity has no physical form.
- A cue that teases before it commits is a judgement; a cue that fires once is a reaction test; draw the difference in two dimensions (depth *and* duration) and vary the count.
- Silhouette carries more than colour; a hazard must not resemble a reward; separate play space from background by *lightness*, not hue, and test the gap.
- The most valuable thing on screen is the brightest; the hazard only has to be unmistakable.
- Every hazard in one colour family; variety goes in silhouette and behaviour.
- Contrast checks must weigh lightness as well as hue.
- A sphere reads as a bubble at any size; prisms with hard corners catch light on one face and not the next.
- When a change must be noticed from memory, change the amount (3× the sparks) not the shade.
- Give each pressure its own channel; a number beats a bar when the player needs causation (`HULL −3.4/s`).
- Put the gauge on the thing it eats without covering it; put a modifier where the thing is already named; draw the player's own goal into the world (frozen at run start, faded once passed).
- Derive the picture and the score from one state so they cannot disagree; let damage reveal history (shaved layers).
- When the accurate model and the readable model disagree, build the readable one (bands, not shells).
- A formation needs per-unit state and more than one unit wide to be readable; rows with offset alternate rows beat a scatter.
- Make failure a *shape* (lean over a neighbour) rather than a number, with something visible to fail onto, painted lighter than the target.
- A transformation is worth ten multipliers: the screenshot before and after a station must be obviously different pictures; show the die, and give containers a rim.
- A liquid is motion and answers (scrolling surface, entry rings, a tool that follows), not a texture.
- A HUD is a claim about what the player should think about; the reference shows three things — do not keep adding readouts.
- A prop that occludes the thing the game is about is a bug; a chain of short boxes reads as debris — sweep a mesh along the path.
- "Unavailable" and "not a control" are two booleans; only refusal is grey.
- Enabled/disabled says it three ways (colour, text, value), and ordering matters: sealed beats affordable, maxed beats affordable, name the missing material before the money.

### Lighting
- A point light does not know the geometry is there; light through a grid must propagate through open cells (flood fill), with distance falloff in the shader and the field uploaded as a small texture.
- Surface light and air light are two lights; a corner shadow belongs only to the air term; they want different ambient floors.
- Combine beam and bounce with `max()`, never by multiplying two floors, or anywhere that is both goes black.
- A lighting multiplier is linear and then sRGB-encoded, so its dark end lifts (6% displays at ~⅓); square it.
- Dim emissive things on a gentler curve than surfaces, or discovery mechanics switch off in the dark.
- Ambient is the one light that reaches every surface equally, which is the opposite of a lamp in a hole; make it fall away fast (squared).
- Do not light the player's vehicle with the gameplay light (its range is an upgrade); give the vehicle its own key light and exclude the world's.
- Put the sun *ahead* of the camera for anything wet; a specular streak is sun → surface → eye.
- Any effect applied by distance hits the background hardest; check the sky first when tuning fog (Godot `fog_sky_affect` ≈ 0.2, T).
- Keep light fields at several texels per cell and keep brightness and shape in separate channels; the one-toggle diagnosis is switching to nearest filtering.
- A metal with nothing to reflect is black plus hotspots; data textures (normal, roughness) must not be sRGB-decoded.
- A normal map is how photographed texture enters a stylised game (drop the colour map); sample by world position and expect a much higher strength than usual, judged under a moving lamp.
- Ambient particles must be anchored in the world and wrapped around the player, lit by the world's light model on a harder curve, drawn behind terrain, and faded out wherever the beam is not the light.
- Post-processing (vignette in three stops, animated mid-tone grain, a touch of aberration, blacks lifted toward the scene colour) is the cheapest mood tool; put it under the HUD.

### Audio / music
- Generative beats a loop, but a written theme beats random notes: without repetition there is no phrase, and a fast attack on a high sine is a notification sound (his only outright "I don't like").
- Randomise pitch and filter on repeated sounds.
- A texture reads as ambience; only a rhythm reads as movement (off-beat thuds read as "something in the room").
- A mood arc is a crossfade on a gameplay quantity (depth), never a playlist; the layer that leaves does more than any that arrives; assert monotonicity and a real span.

### UI / HUD
- Where a readout sits matters more than how it looks; the top of the screen is where nobody looks — put gauges by the thumb, or opposite the thumb if watched continuously.
- A gauge checked under pressure must not move for unrelated reasons.
- A pressed control reads as pushed in, not lit up.
- Give a needle mass, damped to what it shows; a HUD on a textured world needs its own material, with grain felt not seen.
- Labels in a 3D scene are sized by the pixels they occupy; measure before choosing words (six characters on a 70 px plate).
- A shop the player is meant to be *in* has to be geometry (a room with the real object in it), not a panel and not a list; hide the game entirely behind it.
- Pin the primary button (START) to the bottom of a scrolling sheet.
- A screen you invented is invisible to you; list what the reference does *not* have.
- Do not copy a monetisation mechanic (a multiplier wheel) into a game with no monetisation.

### Level design
- Put the reward on the ground with extent, give the player a formation with lag, and let the geometry make the decision (weaving measured 2.6× over straight, M).
- The thing you protect should trail along your path, not cluster around you, so size costs agility; obstacles must test every unit.
- Starting with one of the collectible instead of eight makes the first pickup the most valuable object in the game; cap flat damage as a fraction and expect defensive play to lose its value.
- An obstacle anchored to the track edge guarantees its own gap and its hitbox derives from the drawing.
- Attrition asks one question ("leave sooner"); a rhythmic announced event makes depth a bet (tremor every ~27 s past 85 m, T).
- Announce a zone before charging for it, and make several things land on the same metre; a threshold the player cannot see is not a mechanic.
- Look for one hazard being the answer to another before adding a third.
- Interruption is a feature: let the player stop a commitment and keep the partial progress.
- Every content band must be reachable in both directions; test it.
- Read a reference's strategy guide for the *verbs*, search for the longest playthrough video, magnify screenshots 4× before modelling.

### Testing feel and design
- Measure a claim in the part of the game the claim is about; a harness that can only start from the beginning tests five tutorial fish.
- A perfect bot winning is not evidence about difficulty; the bot needs human faults *with memory* (reaction ~0.3 s, occasional misreads, a wandering hand) and, for tap inputs, a *rate* it corrects a few times a second — otherwise timing mechanics look free.
- Tune the game so the human bot struggles; never tune the bot so the game looks hard.
- Measure a mechanic across a bad run and a good run; if the number does not move, the mechanic is scenery.
- Make every scripted policy fail for a different reason, and the table describes what the game rewards; the pair that proves a decision exists must differ in exactly one thing.
- A bot that loses to a dumber bot might be a bug in the bot: sweep its one free parameter across a range before touching a game constant.
- A bot that only optimises dies; give it the survival job too.
- One definition of "playing well" lives in the repo and drives both the bots and the tests; name it beside the constant it calibrated and pin the ratings.
- Any A/B over a procedural world must reset everything the seed is keyed on.
- Test intent, not values ("a hazard breaks faster than the rock around it"); assert the property the message states, not a literal.
- Put the test on the derived quantity the player feels, and grep every formula a constant appears in before changing it.
- Assert that a thing is *on screen*, screenshot the short states deliberately, and look at every screen once.
- Every "there is always a way out" test drives the input handler's seam, not the method.
- A construct that cannot fail (modulo, `|| fallback`, clamp) is untested, not safe; a safety clamp that fires in normal play signals nothing.
- Assert saturation, not a hand-derived ceiling, for physical stability.
- Fixtures that all share a convenient value miss the bug; add the awkward one and say why.
- Test the random source itself (range, distribution) and that each mechanic occurs in an actual run; a condition that can never be true fails as absence.
- Extract clocks into pure reducers; put collision in a pure module and test the five failures (tunnelling, corners, creeping, wedging, frame-rate).
- Telemetry reports rates and ratios with meaningful denominators and says "never used" out loud.
- Freeze the world before adding to it and assert the category of legal change; new world features roll on their own seed offset.
- Five feel assertions that earned their place: affordance, dead time, latency (≤2 frames), liveness, gesture discrimination.

### Process
- Write the lesson in the same commit as the change that taught it; several games run at once.
- A note that survives a correct fix is a note about something else; when a symptom survives two fixes, stop fixing and measure (hide a layer, read a pixel, print the buffer).
- A fix that improves every scene equally is a dimmer switch, not a fix.
- Delete the stand-in in the same commit as the real thing, and audit everything else that does the same job.
- Two bugs can hide each other; when a fix makes a different test fail, suspect a mask.
- If adjusting the obvious parameter changes nothing, a constant term is drowning it; measure.
- Half a feature working is the worst symptom because it reads as tuning.
- When the player restates a request from scratch rather than refining it, the model is wrong, not the tuning.
- A rewrite beats revision when the fault is an inheritance (shape) rather than a decision; keep research in its own file so a rewrite is cheap.
- Separate means separate, not delete; the answer to a gauge in the wrong place is to move the gauge.
- Measure numbers before quoting them as limits; he will ask.

---

## 5. PLAYTESTS.md: what Gideon actually says

The file covers 2026-09-06 to 2026-09-09 across Coreward, Captain Run, Wick, Candle Gift, Wrecking Crew and Stillwater. Two entries are out of chronological order (the Coreward lighting rounds of 2026-09-08 are filed after Stillwater's 2026-09-09 notes, at line 735), and the Wrecking Crew 2026-09-08 and 2026-09-09 entries repeat the same three quotes.

### Recurring complaints

**1. The menus and shop are wrong, and they are the first thing he opens.**
- "can you update the shop to look more like a separate upgrade screen, like an actual shop or building?" — Coreward, 2026-09-07
- "can you make the shop an actually different screen instead of a pop up screen and make it look more like a space station shop?" — Coreward, 2026-09-07
- "make it look like a full room where upgrades have a physical model associated with it instead of a list of upgrades" — Coreward, 2026-09-08
- "When I get to the upgrade screen, it won't scroll down so I can't see all of the upgrades or close out of the menu to continue" — Candle Gift, 2026-09-07 (a blocker)

**2. Nothing is at stake / it is too easy / it feels free.**
- "I can afford upgrades pretty early on for fuel and cooling so neither is a risk." — Coreward, 2026-09-06
- "Right now it doesnt say it costs anything, so it feels free." — Coreward, 2026-09-06
- "there isn't really a risk or reward yet… I want to focus on the breaking part and don't know if this forward lane style game is the best option." — Wrecking Crew, 2026-09-08
- "As far as the fishing mechanic, it is too easy" — Stillwater, 2026-09-09

**3. The controls or motion feel wrong (grid-locked, bouncy, backward, drifting, misaligned).**
- "can you make the ship feel more like it is free to fly not on a grid?" — Coreward, 2026-09-07
- "The ship looks very bouncy when you change direction or stop… I want it to ease into a stop." — Coreward, 2026-09-07
- "the driving controls almost feel backward but not sure if that is the main issue." — Wrecking Crew, 2026-09-09
- "it flies out too much but also feels like it doesnt have enough momentum." — Wrecking Crew, 2026-09-09
- "it doesnt seem locked to move forward and backward. it seems to drift." — Wrecking Crew, 2026-09-09
- "The button icons don't line up with where you need to press on the screen. The icons are about .5 inches too high." — Wrecking Crew, 2026-09-08

**4. He cannot see or read the thing that matters (thresholds, costs, gauges, what to do).**
- "It is difficult to judge the price of the different blocks you are mining." — Coreward, 2026-09-06
- "right now it doesnt seem very obvious that there is a distinct line." — Coreward (heat), 2026-09-06
- "can you also make the light upgrade more important? I can see all of the blocks on screen, so it doesnt seem very beneficial." — Coreward, 2026-09-07
- "I don't like that my thumb will be blocking the gauge I am looking at." — Stillwater, 2026-09-09
- "it is not very intuitive to tell what you are supposed to do… I think having visual on screen queues or gauges would be a good addition" — Stillwater, 2026-09-09
- "i dont see any gauges and after it says tap in the green… I cant recast or anything." — Stillwater, 2026-09-09

**5. An animation or motion is doing the physically wrong thing.**
- "it looks like it is just fast forwarding." — Coreward autopilot, 2026-09-06
- "The ship should turn to face the direction it is digging in." — Coreward, 2026-09-06
- "the rod bends back then flicks forward which isnt how it should work." — Stillwater, 2026-09-09
- "the rod should pull up and back when preparing to cast but it pushes down and flings up when you let go." — Stillwater, 2026-09-09

**6. A lighting or rendering artefact persists across rounds, and the game does not look as good as the reference.**
- "each block shows that angled shadow. that should only show on actual branched off tunnels." — Coreward, 2026-09-08
- "it is still doing it but I think it will be hard to see from your tests since it only happens when approaching a branching path." — Coreward, 2026-09-08 (fourth round)
- "it looks like it is happening worse now than it was and I liked the art style before better." — Coreward, 2026-09-08
- "the game looks a little cartoonie. can you update the graphics to look more realistic and detailed?… change the ship to look less bubbly and cartoonish." — Coreward, 2026-09-08
- "I like the improvements but it looks like we are atill pretty far off from the original game" — Candle Gift, 2026-09-07

**7. Wants the game to be *about* something more (a point, more mechanics, more upgrades).**
- "can you also think about a larger point to the game, or secondary objective?" — Coreward, 2026-09-07
- "can you add additional creative upgrades like a bomb… a laser beam…" — Coreward, 2026-09-07
- "I think it is good for now and will be a good mechanic when more gets added." — Coreward, 2026-09-06

One-off but flagged as the only outright dislike: "The music has random higher pitch beeps that I dont like." — Coreward, 2026-09-06.

### What he has praised

Praise is sparse and almost entirely about stability rather than design:
- "the game looks like it runs great" (Coreward, 09-06); "It all looks good. It runs smoothly and I don't see any issues." (09-06); "I just tested it… and it looks good." (09-06); "I tested it and it looked good." (09-07)
- "I like the sections of texture you added to the regular blocks" (Coreward, 09-07) — the one unprompted design compliment, and he immediately turned it into a mechanic suggestion.
- "that looks very close to what I want but a couple of issues" (Coreward lighting, 09-08)
- "I like the improvements but…" (Candle Gift, 09-07)
- "I liked the art style before better" (Coreward, 09-08) — praise of a *previous* state after a regression.
- "I think it is good for now and will be a good mechanic when more gets added" (heat, 09-06).

The file's own reading is correct: "It looks good" means nothing obviously broke, not that the feel is right.

### Stated preferences about working with Claude

- **Research before building, explicitly and repeatedly.** "Can you research how other fishing games handle this mechanic" (09-09); "try to use other games as reference for it" (09-09); "please research this actual game to see how other levels look and feel" (09-07); "research were the best place to get [assets] from and how to install them all on your end" (09-07).
- **Match the reference first, then improve.** "I want the base of the game to be like the one she is talking about, then we can upgrade it from there" (09-07); "I want it to start out very similar" (09-07).
- **Free rein within a brief.** "You have free reign to make improvements that you think will be fun or accurate" (09-07); for Stillwater he asked for a full design document up front and "fill in any missing details" (09-09).
- **Wants numbers he is told to be real, and asks when they sound arbitrary.** "is the memory limit something you have set or a build in standard for html or chrome?" (09-07); "Are we still stuck to seventy draw calls? What is preventing that from being a higher possible number" (09-08).
- **Sets acceptance criteria himself and expects them honoured.** "I would only want to do it if it has very little impact on the game running and is actually helpful." (09-07)
- **Flags his own priorities.** "im sure we can work on it later but…" (09-09) — and the file notes his ordering was correct.
- **Does not want realism for its own sake.** "it doesnt need to be realistic fishing mechanics. it can just be a fun challenging mini game feel" (09-09).
- **Expects screenshots to be read.** "Did you see the areas I circled in my picture? The position of the ship won't cause the issue that you have it at currently." (09-08)
- **Sends several asks per message and expects all of them handled** (five in one paragraph on 09-08; four on 09-09; six on 09-07).
- **Expects the reasoning when the answer is no.** The file records twice that a "reasoned no" on assets was given "rather than leaving the absence silent".
- **Corrects process misdiagnoses.** "Another Claude code chat was running tests on the Coreward game… If that was causing test issues, don't write those off as broken." (09-07)
- **Wants a version number and patch notes in the pause screen** so he can tell which build he is on (09-07).
- **Tests on his phone, plays the opening, opens the menus first**, and has never reported on deep content in any game.
- The file's own escalating rule: "Believe the symptom" (early) → "when he proposes a mechanism, build that mechanism" (09-09) → "Every mechanism he has proposed has been the right one" (09-09).

---

## 6. Other notable things

### Rules Claude wrote about its own process failures

A large share of CRAFT.md is not craft knowledge but Claude telling future Claude what it got wrong. They cluster into a few kinds:

**Misreading the instrument (the most repeated).**
- "A PERFECT BOT WINNING IS NOT EVIDENCE ABOUT DIFFICULTY… the probe printed the answer a full day before the player said it out loud and it was read as good news." (1534)
- "The instrument keeps being the thing that is wrong." (PLAYTESTS 733)
- "MEASURE A CLAIM IN THE PART OF THE GAME THE CLAIM IS ABOUT." (1490)
- "Screenshot the SHORT states, deliberately… A screenshot at '24.5 seconds' is a screenshot of whatever happened to be true then." (1166)
- "assert that a thing is ON SCREEN, not merely configured" (1161); "Take a picture of every screen you build, once, and look at it." (2114)
- "Every 'there is always a way out' test has to drive the call the INPUT HANDLER makes" (1657)
- "Every fixture agreeing on a convenient value is how a whole suite misses a bug." (1642)

**Tuning when it should have been measuring.**
- "A note that survives a correct fix is a note about something else." (827)
- "when a symptom survives two correct fixes, stop fixing and start measuring. Printing fifteen numbers out of the buffer ended a three-round hunt in one call." (905)
- "What finally worked was hiding one layer and re-rendering… That should have been the first move, not the fifth." (PLAYTESTS 775)
- "A fix that improves every scene equally is usually a dimmer switch." (2182)
- "If adjusting the obvious parameter changes nothing at all, stop adjusting it." (1902)
- "Sweep the bot's parameter before touching the game's." (1809)
- "Sweep a manoeuvre rather than reasoning about its timing." (1782)

**Not hearing the player.**
- "He was not explaining it wrong. He had been describing two lights since the first message; I had been building one." (PLAYTESTS 218)
- "when he restates a request from scratch rather than refining it, that is the signal that the model is wrong, not the tuning." (PLAYTESTS 225)
- "Read the mechanism half of a report as seriously as the symptom half. Twice now he has supplied the cause and I have treated it as a description of the symptom." (PLAYTESTS 783)
- "SEPARATE means separate, not DELETE — and the next note said so." (1363)
- "read the guide for the verbs, not the nouns" (PLAYTESTS 490); "Absence is the hardest thing to observe" (1247); "Magnify the reference before you model from it" (1259).
- "I kept setting up test scenes with the ship AT the junction, which is the one place the artefact cannot appear, and he had to say so twice." (PLAYTESTS 768)

**Leaving debris behind.**
- "When you replace the reason for a workaround, delete the workaround in the same commit." (908)
- "A fake put in before the real system exists does not announce itself when the real system arrives." (923)
- "Do not paper over one of these with a test that enshrines it." (280)
- "Do not 'fix' it later by flipping something else as well." (1939)
- "Round before clamping… exactly the kind of diff that trains you to re-record without reading." (1976)
- "`localStorage.clear()`… Three sessions, three times." (1972)

**Housekeeping.**
- "Write the lesson in the same commit as the change that taught it." (17)
- "Before changing a constant, grep for every formula it appears in." (1592); "Grep for the call sites the moment a policy gains state." (1582)
- "Re-shoot after any change to a length." (499)
- "Ports are now per-game." (PLAYTESTS 434)
- "the numbers should be measured before he does" (PLAYTESTS 516)
- "Ship, then check." (2019)

### Which of those are worth keeping as one-liners

Twelve that have each been paid for more than once and are stack-independent:

1. Write the lesson in the same commit that taught it; other games are running now.
2. A complaint that survives a correct fix is about something else — stop tuning, start measuring (hide a layer, read a pixel, print the buffer).
3. A fix that improves every scene equally is a dimmer switch, not a fix.
4. When he restates from scratch instead of refining, the model is wrong, not the numbers; when he names a mechanism, build that mechanism.
5. A perfect bot proves nothing; a human bot needs memory; sweep the bot's parameter before touching the game's.
6. Measure a claim where the claim holds, per item, across several seeds — never one mean, one level, or the tutorial.
7. Assert it is on screen, screenshot the short states, and look at every screen once; tests that passed on invisible gauges have happened twice.
8. A way out the input handler never calls is a missing feature with full coverage.
9. Delete the stand-in in the same commit as the real thing, and audit everything else doing the same job.
10. Grep every formula a constant appears in before changing it; test the derived quantity the player feels.
11. A construct that cannot fail (modulo, fallback, clamp, a rich fixture, a literal) is untested, not safe.
12. Measure a number before quoting it as a limit; he will ask, and "50–100 draw calls" was wrong by 30×.

### Structural observations for the rewrite

- The `## Working with Gideon` section (247 words) is the most out-of-date section relative to its evidence; PLAYTESTS has strengthened every one of its claims and added several (opens menus first, asks for research, sets acceptance criteria, wants the reasoning on a no, gives animation specs in order). It should be rewritten from PLAYTESTS, not from itself.
- The `## Recording` section's own test ("would this have saved time if I had known it at the start of today?") is good and has not been applied to the file's contents: the Coreward lighting stack, the three.js trap list, and the pendulum maths would not save time at the start of a new Godot game and should move to per-game notes or a techniques appendix.
- PLAYTESTS.md is append-only as designed, but the two out-of-order entries (Coreward lighting 09-08 at line 735; duplicated Wrecking Crew quotes at 524–635) suggest sessions are appending to the end rather than to the game's section. A per-game file, or a strict "one dated entry per session, in file order" rule, would fix it without violating append-only.
- The dates span four days (2026-09-06 to 09-09). Six games, ~290 lessons in four days means most lessons were written within hours of being learned and have never been revisited; the "corrected on 2026-09-09" paragraph on show-the-next-locked-thing is the only rule in the file that records having been re-examined.
