# A boundary written in a comment is not a boundary, and a guard nobody falsified is not a guard

**What happened.** Coreward obeyed standing rule 2 in substance and not in shape. Thirteen
pure modules sat in `src/` beside the renderer modules, and the only thing recording which
was which was a paragraph at the top of `test/pure-entry.ts` asking the next person to keep
it that way. Nothing would have failed at the moment of the mistake. A `import * as THREE`
added to one of those files would have shipped, and the first sign of it would have been an
esbuild error in the golden harness days later, in a file nobody had touched.

Moving them into `src/sim/` cost 77 changed import lines and nothing else, and it converts
the rule from a request into a location. The wall is then worth asserting: a test that reads
the files in `src/sim` and fails on an import of three.js, on any non-`import type` crossing
out of the directory, on a renderer or input global, and on an unseeded roll.

**The part worth the whole lesson.** Rule 11 says verify a regression test by reintroducing
the bug, so each of the five assertions was checked by injecting exactly the thing it claims
to catch. Four caught it. **The `Math.random` assertion did not.** It allowed the roll when
the preceding text ended in an equals sign, which was meant to permit the injectable default
`rand: () => number = Math.random` and in fact also permits `const roll = Math.random()`,
which is the bug. Written, read twice, green, and completely inert. It now matches the exact
signature `=> number =` and nothing looser.

**The rule.** Put the boundary where the compiler and the file system can see it, then write
the test that reads it, then break the code five times to prove the test is awake. A guard
written and never falsified is not evidence, and an allow-list clause is the part most likely
to be silently wrong, because it is the clause that makes the test pass.

**Where it belongs.** `TESTING.md`, under verifying a test by reintroducing the bug, with the
allow-list clause called out as the specific place vacuous guards hide. The directory half
belongs in `WEB.md` beside the pure-layer section, and in `CRAFT.md` if there is a section on
making rules structural.
