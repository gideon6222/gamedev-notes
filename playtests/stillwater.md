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
