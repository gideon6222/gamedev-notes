# A cumulative-threshold table reads like a probability table and is not one

**Coreward, 2026-09-10, round seven.** Eleven ores, each with a `chance`, picked
by walking the list deepest-first:

```js
for (const o of ORES) if (d >= o.min && r < o.chance) return o;
```

That is a **cumulative threshold**, so an entry's real share is the GAP to the
one above it - except the first one tested, which keeps its whole number. The
table looked like eleven probabilities and behaved like ten differences and one
absolute.

Measured, at depth:

| ore | value | `chance` | actual share |
|---|---|---|---|
| solmarrow | 132,000 | 0.021 | **2.10%** |
| umbrite | 54,000 | 0.026 | 0.50% |
| coreite | 22,000 | 0.030 | 0.40% |

**The most valuable thing in the game was four times more common than the next
one down**, and had been since the day a third ore was added, because every new
deepest entry was written as "a smaller number than the one above it" and then
tested first.

Two more consequences nobody had noticed:

- **Total density was constant at every depth** - always the shallowest eligible
  entry's threshold, 10% - so going deeper never changed how much ore there was,
  only which kind.
- **Adding a deeper entry stole from the one above it** rather than adding
  density, so the table flattened silently as it grew.

## What to do

- **Store the quantity you mean.** If the design says "0.2% of cells", put 0.002
  in the table and derive the thresholds at load. A field whose value is only
  meaningful relative to its neighbour will be edited as if it were absolute.
- **Print the derived numbers in a test or a probe.** One table of actual
  per-entry rates at three depths made a three-year-old inversion obvious in
  seconds. Nobody reading the source had ever seen it.
- **Watch for the first-tested entry.** In any first-match-wins scan, the first
  branch is the one whose parameter means something different from all the
  others. That is where the bug will be.

The repo's own test had the same bug: it estimated "how many runs to find N of
this mineral" as `chance * 100`, reading the threshold as a rate.
