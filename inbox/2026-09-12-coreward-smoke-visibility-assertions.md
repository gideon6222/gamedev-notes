# A class named `hidden` is a claim and the screen is the fact, so a smoke test asserts visibility (computed style, `toBeHidden`, `toBeVisible`) never the class, and when a feature is deleted, grep for every selector its CSS carried and check who else still sets that class before removing the rule.

**Game:** coreward  **Date:** 2026-09-12  **Belongs in:** TESTING.md / Rules for the suites (see also WEB.md / Rules that were paid for)

## What happened
Two first-hour bugs shipped in Coreward (a web game, three.js, Playwright smoke tests) with a green suite, and both were the same fault. (1) The intro's SKIP button is toggled with a `hidden` class for a first run, and the stylesheet never had a `#introSkip.hidden{display:none}` rule, so every first run since the button arrived showed the skip the player had asked to withhold. The e2e test asserted `toHaveClass(/hidden/)` and passed the whole time. (2) When the crossing feature was deleted in W9, its CSS went with it, including the `body.crossing #hud ... {display:none}` rule that the title screen and the intro still relied on, so the released 0.31.0 drew the whole HUD (d-pad, gauges, five buttons) over the space flight. No test looked at the stylesheet. Both were found by a filmstrip of the intro, not by the suite. The fix in both cases was a CSS rule plus an e2e assertion on computed style (`getComputedStyle(el).display !== 'none'` or Playwright's `toBeHidden()` / `toBeVisible()`), and the new tests were verified by running them against the unfixed build first (they failed) and then the fixed build (they passed).

## The rule
A smoke test for a web build must assert visibility by computed style (`toBeHidden()`, `toBeVisible()`, or `getComputedStyle().display`), never by the presence or absence of a class like `hidden`. When a feature is deleted, grep for every CSS selector it carried and check who else still sets that class before removing the rule.

## Replaces or contradicts
nothing
