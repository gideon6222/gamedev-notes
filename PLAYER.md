# PLAYER.md - who the games are for, and how he works

Everything here is drawn from `playtests/*.md`, which is the evidence. When the evidence
changes, `/digest` changes this file. Read this before designing anything, because the
same six faults recur across different games and every one of them is listed below.

## How he plays a new build

- **He opens the menus first**, then plays the opening. The shop, the pause screen, the
  upgrade list and the first sixty seconds are what get judged. Deep content has never been
  reported on in any game. Weight the effort there.
- **He plays on the phone**, holding it in portrait, with his thumb over the bottom of the
  screen. He has no dev console. A build stamp and version in the pause menu is how he tells
  which build he is on, and he asked for that himself.
- "It looks good" or "runs great" means nothing obviously broke. It is not praise of feel.
  The one unprompted design compliment in six games was for texture on the blocks in
  Coreward, and he turned it into a mechanic suggestion in the same sentence.
- He sends several asks per message (six in one paragraph is normal) and expects every one
  handled or explicitly answered. Number them back to him when you report.

## The recurring complaints, in his words

1. **The shop or menu is wrong, and it is the first thing he opens.** "make it look more like
   a separate upgrade screen, like an actual shop or building." "make it look like a full
   room where upgrades have a physical model." And the blocker: "it won't scroll down so I
   can't see all of the upgrades or close out of the menu." A shop is a place, not a panel or
   a list. Every scrolling panel is tested with a finger, and the primary button is pinned.
2. **Nothing is at stake.** "it feels free." "I can afford upgrades pretty early on for fuel
   and cooling so neither is a risk." "there isn't really a risk or reward yet." "the fishing
   mechanic is too easy." Doing nothing must lose, the greedy option must be genuinely
   better and genuinely near the edge, and a scripted do-nothing bot must score badly.
3. **The controls or motion feel wrong.** "feel more like it is free to fly not on a grid."
   "very bouncy when you change direction or stop." "the driving controls almost feel
   backward." "flies out too much but also feels like it doesnt have enough momentum." "The
   button icons don't line up with where you need to press ... about .5 inches too high."
   Velocity and collision, exponential smoothing, controls anchored to the real viewport, and
   an NDC test for handedness.
4. **He cannot see the thing that matters.** "difficult to judge the price of the different
   blocks." "it doesnt seem very obvious that there is a distinct line." "my thumb will be
   blocking the gauge I am looking at." "i dont see any gauges and after it says tap in the
   green ... I cant recast or anything." Every state names a visible action, every gauge sits
   where the thumb is not, and a screenshot of every screen is looked at before shipping.
5. **An animation does the physically wrong thing.** "it looks like it is just fast
   forwarding." "The ship should turn to face the direction it is digging in." "the rod
   should pull up and back when preparing to cast but it pushes down and flings up." He gives
   the correct motion in order. Build exactly that motion and film it before sending.
6. **A rendering artefact survives several rounds, or the look regresses.** "it is still
   doing it." "it looks like it is happening worse now than it was and I liked the art style
   before better." "the game looks a little cartoonie. can you update the graphics to look
   more realistic and detailed?" Attribute an artefact to a layer before fixing it. A fix
   that dims every scene equally is a dimmer switch. Never trade away a look he liked to fix
   a bug.
7. **He wants the game to be about something.** "think about a larger point to the game, or
   secondary objective." "add additional creative upgrades like a bomb ... a laser beam."
   Every plan has a meta-goal, a collection or progression that does not decay, and a reason
   to come back in five minutes.

The only outright dislike ever recorded: "The music has random higher pitch beeps that I
dont like." A fast attack on a high sine reads as a notification sound. Music needs a
written theme with repetition, a cadence and a pulse, not random notes over a drone.

## How he wants to work with Claude

- **Research first, and say so.** "research how other fishing games handle this mechanic."
  "use other games as reference." "research where the best place to get [assets] from and how
  to install them all on your end." He asks for this repeatedly, so do it without being asked.
- **Match the reference first, then improve.** "I want the base of the game to be like the
  one she is talking about, then we can upgrade it from there." When there is a reference,
  read its strategy guide for the verbs, find the longest playthrough video, magnify the
  screenshots before modelling anything.
- **Free rein inside a brief.** "You have free reign to make improvements that you think will
  be fun or accurate." "fill in any missing details." He wants the idea expanded, not
  narrowed. He asked for a full design document up front for Stillwater and liked it.
- **One gate.** He approves the plan, then he wants a playable build, not questions. If a
  decision genuinely cannot be made, make the reversible choice, write it in `NOTES.md`, and
  mention it in the ship report.
- **Numbers have to be real.** "is the memory limit something you have set or a built-in
  standard?" "Are we still stuck to seventy draw calls? What is preventing that from being a
  higher possible number." Measure before quoting a limit. The seventy draw-call figure was
  wrong by thirty times.
- **He sets acceptance criteria and expects them honoured.** "I would only want to do it if
  it has very little impact on the game running and is actually helpful."
- **He does not want realism for its own sake.** "it doesnt need to be realistic fishing
  mechanics. it can just be a fun challenging mini game feel."
- **He reads the reasoning on a no.** A reasoned no on an asset was welcomed. A silent
  absence is not.
- **He reads screenshots he sends you closely and expects the same.** "Did you see the areas
  I circled in my picture?" Look at every image he sends before answering.
- **He corrects process misdiagnoses.** "Another Claude code chat was running tests on the
  Coreward game ... If that was causing test issues, don't write those off as broken." Other
  sessions are running. A flaky suite is more likely a port or a shared file than a bug.
- **He was right about the mechanism every time it was checked.** Six sessions, six
  mechanisms proposed, six correct. Believe the symptom AND the cause.

## Preferences that carry into every game

- Portrait, one thumb, playable within ten seconds of opening, no menu to wade through.
- A version number and patch notes reachable from the pause screen.
- Real 3D by default. He likes texture, lighting and a lived-in look over flat colour, and
  he will say "cartoony" when a scene is under-lit or under-textured rather than because of
  the model style.
- A game keeps growing. Plan the second month's content in the first plan, even if it is
  not built.
