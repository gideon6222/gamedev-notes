# Playtests — Stillwater

Gideon's words, dated, verbatim. **Append only.** New entries go at the end under a `## YYYY-MM-DD` heading. Interpretation and lessons go in the topic files, not here.

---

A fishing game. Starts calm at dawn and gets creepier; **depth is time**, and the line upgrade
is the story progression. Asked for as a full design plan first, then built in milestones.

## 2026-09-09 - how it was asked for

"I want to make a fishing game. It should be 3d and start simple and light hearted but get
more intense and creepy as you go. You start on a boat in a calm lake catching small fish.
This section teaches thr mechanics, how to sell and upgrade equipment and the boat... I want
you to full map this game out. Create an interesting, intriguing story that has creepy and
thought provoking twists... Can you create a full plan, flesh out the info I gave you and fill
in any missing details."

- Worth noting the shape of the ask: a **whole design document up front**, not a prototype. He
  named the tonal arc, the teaching section, the progression axes and the art direction, and
  then explicitly handed over the gaps. That is a different working mode from the other games,
  where he reacted to builds - and it means the brief is the artefact to get right first.

## 2026-09-09 - M1, the first playable fight

"As far as the fishing mechanic, it is too easy and I don't like that my thumb will be
blocking the gauge I am looking at. Can you try a different mechanic that will require more
risk, skill, or awareness? Can you research how other fishing games handle this mechanic and
make a version that fits with the theme of our game?"

- **Two faults, one root, and the root was mine.** I built a threshold fight - hold the tension
  inside a moving band - and put the band on a control on the right-hand side. So the thing he
  had to watch every frame was underneath the thumb that set it.
- The occlusion note generalises and is now in CRAFT: **a readout that must be watched
  continuously cannot live under the thumb that operates it.** Wrecking Crew's crane dial got
  away with exactly this arrangement because you GLANCE at a dial; a tension meter is read
  every frame. Same shape, opposite outcome, and I copied the shape without checking which one
  it was.
- "Too easy" was **already in the probe output a day earlier** and I did not read it that way:
  the scripted angler landed 6.83 fish and lost zero. I noted it in NOTES.md as "the number to
  watch" and shipped anyway. It was not a number to watch, it was the answer.
- He asked for research rather than assuming I would. It paid: Dredge's minigame turns out to
  have **no failure state at all** (missing a check only slows the reel), which is the opposite
  of what he wanted and would have been the obvious thing to copy.

Third time now that a note of his has been a correct structural diagnosis rather than a matter
of degree, and the first time one of them was already sitting in a table I had generated,
written down, and misread.

## 2026-09-09 - M1 again, the second fight

"im sure we can work on it later but the rod bends back then flicks forward which isnt how it
should work. the rod should be straight initially lift the rod up and back, then swing it
forward. once the fish bites, the rod should bend forward since it is now under pressure."

- A precise description of a real bug, including the fix. One variable drove both motions, so
  `charge` fed the same bend the fight uses. Note the shape again: he described what the object
  should DO, in order, and that was the implementation.

"as far as the fishing mechanics, it is not very intuitive to tell what you are supposed to do.
it doesnt need to be realistic fishing mechanics. it can just be a fun challenging mini game
feel, like tapping to keep the pressure on without breaking the line. or a combination of two
different mini games, like one to hook the fish and one to reel it in. in either case, I think
having visual on screen queues or gauges would be a good addition"

- **The most useful correction so far, because it corrects the previous correction.** His note
  on the FIRST fight was that his thumb covered the gauge; I deleted the gauge. This says that
  went too far — the answer to a readout in the wrong place is to move it, not remove it.
- "it doesnt need to be realistic" is worth keeping as a standing permission. The second fight
  was pump / give / hold-steady because that is what fishing actually is, and the realism bought
  nothing except three things to infer from a bent stick.
- He proposed the mechanism twice over: tapping to hold pressure, and two minigames. Built as
  described. **Five sessions now, and every time he has proposed a mechanism it has been the
  right one.**
- Worth noting he opened with "im sure we can work on it later" about the rod — he flags what he
  considers low priority. The rod was a ten-minute fix and the mechanic was a rewrite, so the
  ordering he offered was correct.

## 2026-09-09 - M1, the third fight, and three bugs in one screenshot

"something doesn't seem right. i dont see any gauges and after it says tap in the green, it
pulls the rod back slightly then I cant recast or anything. also the rod should pull up and
back when preparing to cast but it pushes down and flings up when you let go."

- Three separate faults in one sentence, all correctly described, and he sent two screenshots
  that between them showed the state I needed.
- **The gauges were never visible at all.** `visible` was set inside the `draw` callback, which
  is a latch - a hidden Control never gets `draw` again. Every property a check would look at
  was right; the thing was simply not on screen. The smoke test had five assertions about those
  bars and not one of them was `visible`.
- **"I cant recast or anything"** was a way-out bug of a kind worth naming: `reel_in()` existed,
  was tested, passed - and nothing in the renderer called it. A public method with no caller is
  a missing feature wearing full test coverage.
- **The rod signs were inverted**, both of them, and he described the symptom exactly: "it
  pushes down and flings up when you let go".
- The uncomfortable part: I had taken a screenshot of this build and it looked fine, because it
  froze mid-fight - the one state in which none of the three show. `shot.gd` takes a state name
  to stop at now.

Second time in two sessions that he has reported something the probe or a screenshot had
already had the chance to tell me. **The instrument keeps being the thing that is wrong.**

## 2026-09-09 - the nibble, and four fixes in one message

"can you make the initial hook portion of the mini game just watching the rod or bobber pull
down. make it look like a fish is nibbling on the bait and pulling on the line. try to use
other games as reference for it. the first tap sets the hook, then it pulls up the bar to tap
and reel in the fish. can you make the taps move the bar in smaller increments as well? when
you cast the rod should pull back, then fling forward but still be angled up. when you cast
currently, it pulls back a little then angles all the way into the water before returning."

- **The most useful of the four is the first, and it is a design principle rather than a
  request.** The sweep bar was a perfectly good arcade mechanic and completely abstract: a
  float being pulled under IS the timing cue, so drawing an invented representation of it above
  the horizon asked him to learn a symbol for something already in front of him. Now in CRAFT
  as *do not invent a symbol for something you can show*.
- "try to use other games as reference for it" - he asks for research explicitly now, second
  time running. Animal Crossing was the right one: teases before the take, which makes it a
  judgement rather than a reaction test.
- "it can just be a fun challenging mini game feel" from the previous round and "make it look
  like a fish is nibbling" here are the same instinct twice: **he wants the fiction and the
  mechanic to be the same object.**
- The cast note is the third precise animation description he has given, and the third that was
  directly implementable. "still be angled up" became a constant.

Six sessions now. Every mechanism he has proposed has been the right one, and the last three
notes have each named a fault I could not see in my own screenshot.

## 2026-09-09 - the whole game: movement, feel, and "not that one boat in that one spot"

> "There are a few things that I have been having trouble getting right with this game. The
> movement has felt odd and I feel like things kept getting missed. I think you may have the
> correct tools to fix those now. Can you make the boat rock much less, in the water? Make the
> physics work better. The rod and the fishing line don't react to movement and don't feel
> great. I want the looking, casting, and fishing mechanics to be much smoother. Can you also
> look over the whole plan from start to finish and expand on it? Make the story and
> progression fleshed out. Update all of the models, textures, sounds, graphics in general.
> Look into ways to make the fishing game more fun and interactive. Go through every aspect of
> the game, expand and research it and make sure each part moves smoothly into the next. I
> don't want the whole game to take place in that one boat and in that one spot."

Eight asks, and the second sentence is the important one.

- **"I feel like things kept getting missed"** is a process complaint, not a bug report, and it
  is the fourth time in six sessions he has named a fault a screenshot had already had the
  chance to show me. He is right about the cause too: **"I think you may have the correct tools
  to fix those now"** - he is pointing at the film and replay tools that landed this morning
  and telling me to go and LOOK at the game in motion before touching it. A still frame cannot
  show rocking, reaction or smoothness; all three of his feel complaints are motion complaints,
  and until today there was no instrument for motion.
- **"The rod and the fishing line don't react to movement"** is the same instinct as the nibble
  note: he wants the fiction and the mechanic to be one object. A rod that ignores the boat it
  is standing in is two separate models of the same world.
- **"I don't want the whole game to take place in that one boat and in that one spot"** does not
  contradict pillar 3 ("it stays the same lake"), and it is worth being careful about that,
  because the pillar is load-bearing. He is not asking for a second location, he is asking for
  the lake to be a PLACE - to get out of the boat, to have the bank and the shed and the gate
  be somewhere you go, and for the six bands to look like six different waters rather than one
  spot with a different number on the depth readout.
- **"Update all of the models, textures, sounds, graphics in general"** is the first time he has
  asked for an across-the-board art pass rather than naming a thing that looked wrong.

Answered in: PLAN.md, rewritten, and the milestones under it.

## 2026-09-10 - the boat as a place you are sitting in, and the three rooms as objects

> "Can you make the water calmer in general? It still rocks a bit too much and the bobber
> comes all the way out of the water, or goes completely below the wave, even when a fish
> isn't biting. Can you calm the waves down and also have the bobber and line react better
> with the water? You can still turn by swiping the screen, I only want to be able to turn by
> using the virtual thumb stick. You are too far back in the boat so it doesn't look like a
> person is actually sitting in it. Can you make it so it feels like you are in first person,
> holding an actual fishing rod and sitting in the boat? When you look at the log book and hit
> the interact button, can you make it so that you actually pick up and view the log book. You
> fish count and any other relevant stats are shown there, and you physically swipe the pages
> to read through it, rather than a scroll page. Can you also make your equipment menu a
> tackle box that you look at and click to view. This should open the tackle box and show all
> of your current equitable equipment. When the shop is available, there should be a shop
> button but the camera pans over to a separate room that is a full 3d room of some kind, like
> a shed or old bait shop where you can buy items. Can you expand on all of these ideas, plan
> them out and how they will fit into the game and story, and implement them? I also like the
> rest of your plan. The steps 4-8 that still need to be completed look good to me. Can you
> plan this whole thing out and start working on it?"

The plan gate is PASSED - "the steps 4-8 that still need to be completed look good to me" -
so phases W, P, G, S and T are approved as written. Seven new asks on top of it.

- **"The bobber comes all the way out of the water, or goes completely below the wave"** is
  the most valuable line in the message, because it names a bug I had looked straight at in a
  contact sheet and not seen. The float is placed at a fixed height in cast space. The WATER
  moves, under a shader driven by the same wave sum, and the float does not read it at all.
  Two models of one surface, which is the fault this game's notes name most often, and this
  time the two models are the water and the thing floating on it.
- **"It still rocks a bit too much"** after a measured 18x reduction in camera rotation. Worth
  recording precisely because the numbers were right and the answer is still yes: 1.1 degrees
  of camera pitch is calm, and the WAVES themselves are what he is looking at now. The
  complaint moved from the camera to the water, which means the first fix worked and exposed
  the next thing.
- **"So it doesn't look like a person is actually sitting in it"** - the seat is at z = -1.90,
  well aft, and the rod is a stick in the middle distance rather than something held. He is
  asking for the body the first-person view implies.
- **Three asks are one ask.** The logbook you pick up, the tackle box you open, and the shop
  as a room the camera moves into are the same principle three times: **a menu should be a
  thing in the world you look at and use.** He has now asked for this pattern in every screen
  the game has, having seen it work exactly once, on the logbook. That is the strongest
  possible signal that 11.9 was the right direction and should be finished everywhere.
- **"Physically swipe the pages"** - the book paginates and a tap turns it, but the page swaps
  rather than turning. Already on the plan as 11.9d and now confirmed as something he can see.

Answered in: PLAN.md phase B (the body), phase R (the rooms), and W1 for the water.

## 2026-09-10 - on the phone: menus clip, no way out, and the fight needs a button

> "a couple of issues. the menus clip through the physical objects, i cant see the log book on
> the ground. I cant swipe the pages on the log book when I pick it up. instead of clicking
> outside the menu to close it, i want an X or back button to prevent accidentally closing out
> of the menue. since the text is small I want arrow keys and confirm button to navigate the
> menues. for the fishing game, you still tap on the screen to fight the fish, there is no
> dedicated button to fill the bar. I want a button instead of just tapping the screen. it is
> also not obvious that the fish will pull back and add pressure to the bar. can you research
> how other games make this feel like a risk/reward system, how they make it feel smooth and
> intuitive, plan it out and implement it? I want an obvious mechanic change, that uses the
> same principle but implements it in a better way."

Three screenshots, taken on the phone, and the first playtest of the rooms.

- **Every one of the first five is a consequence of the rooms landing.** He asked for objects
  instead of panels, got them, and immediately found what a panel had been doing for free:
  panels do not intersect geometry, always have a close button, and are never behind anything.
  Making a menu physical means re-earning all three, and none of them was in the plan.
- **"The menus clip through the physical objects"** is visible in both shots. The tackle box's
  panel passes through the floorboards and the logbook's page passes through the tackle box.
  A SubViewport quad is ordinary geometry and depth-tests like any other.
- **"I cant see the log book on the ground"** while the prompt in the same frame reads "The
  keeper's logbook - 2 of 5 hands". So the crosshair is ON it and the eye cannot find it. That
  is the third time this exact fault has been reported about this object.
- **"Instead of clicking outside the menu to close it"** - tap-to-dismiss was written down as
  "what a reader expects from a thing they picked up". It is what a reader expects and it is
  also how you lose a page by brushing the screen. He is right and the note was wrong.
- **"Since the text is small I want arrow keys and confirm"** - the first accessibility note he
  has given, and it applies to every room, not just the ones built so far.
- **The fight asks are the substantial half.** A dedicated button rather than tapping anywhere,
  and: "it is also not obvious that the fish will pull back and add pressure to the bar." The
  run IS the mechanic the whole fight is built on, it has a tell, a wake and a jolt, and after
  all that the player does not know it is coming. He asks for research and for "an obvious
  mechanic change, that uses the same principle but implements it in a better way" - which is
  permission to replace the presentation of the run, not the idea of it.

Answered in: PLAN.md phase R (the rooms' three debts) and a rebuilt phase F for the fight.
