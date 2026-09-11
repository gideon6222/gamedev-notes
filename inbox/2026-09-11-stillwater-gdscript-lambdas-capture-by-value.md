# GDScript lambdas capture by VALUE, so a probe that writes its result into a captured local reports nothing

**Stillwater, 2026-09-11.** A probe measured why fish are lost, splitting the causes:

```gdscript
var why := ""
s.lost.connect(func(reason: String) -> void:
    why = "broke" if reason == Sim.BROKE else "escaped")   # writes the LAMBDA's copy
...
return why if why != "" else "ran out of clock"
```

It reported, for every species and every bot, that **no fish is ever lost anywhere in the
game** - every failure was the probe's own two-minute clock. That reading was a fact about
the closure. `why` was never written: GDScript lambdas capture by value, so the assignment
landed in the lambda's private copy and the caller saw the empty string forever.

The damage was not the wasted hour. It was that the reading was *plausible* - the fight had
just been rebuilt, and "nothing can be lost" is exactly the sort of thing a new model gets
wrong - so a model change was half-built on top of it before a single-fight TRACE showed a
fish escaping at 4.2 seconds and contradicted the summary.

**The fix:** carry the result in a Dictionary or an Array, which are reference types.

```gdscript
var out := {"why": ""}
s.lost.connect(func(reason: String) -> void:
    out["why"] = "broke" if reason == Sim.BROKE else "escaped")
```

**The general rule: a new instrument's first job is to report something you can already
check by hand.** A summary over 26 species and 6 bots has no obvious wrong answer. Trace ONE
case first, confirm the instrument agrees with it, and only then read the aggregate. The
trace cost two minutes and was the thing that caught it.

Related: [[an-instrument-is-code-and-can-be-wrong]]
