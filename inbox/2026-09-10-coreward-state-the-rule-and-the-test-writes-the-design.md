# State the rule as an assertion and the test will write two design decisions for you

**What happened.** Coreward's five world traits were each a multiplier on how much of
something generates: more gas, more caves, more geodes, faster soak. Adding a second half to
each - a rule the player can plan around - came with one obvious property worth asserting:
*no trait is strictly better than another*, because a chart offering five worlds where one is
free upside is a menu with one right answer.

The test failed twice, on two rows I had just written and read.

**Crystalline** had more geodes AND an 18% better price, for no cost at all. **Searing** had
faster soak AND a shallower heat line, both costs, with no upside - a world nobody would ever
choose. Neither was visible reading the table, and both were obvious the moment a machine
compared the good column to the bad one. The fixes were one field each: crystal rock is 20%
harder to cut, hot rock is 16% softer. Both are better design than what was there, and neither
was my idea.

**The rule.** When a table has a balance property - no row dominates, every row is reachable,
every entry costs something - write it as an assertion in the same commit as the table, not
after a playtest says something feels off. It takes a few lines, it runs in milliseconds, and
it reads the whole table every time rather than the row you happen to be looking at. The same
session had `every upgrade is built out of a real, reachable mineral` catch three rows whose
mineral had drifted below the world they unlock on.

**The sharper version.** A design test that has never failed is either protecting something
genuinely stable or is written too loosely to fire. These two fired on their first run against
a table their author had just proofread, which is the best evidence there is that the rule was
worth stating.

**Where it belongs.** `CRAFT.md`, under difficulty and balance, beside the existing rule that a
new knob must be a dial rather than a cliff. `TESTING.md` too, as the case for writing the
balance property at the same time as the table.
