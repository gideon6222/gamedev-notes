# When a golden is re-recorded, read the diff as counts per id and refuse it if any id LEAVES that the change could only have added, because an ES-module import cycle fails silently by evaluating a constant as undefined, and the first thing that shows it is a room or an object missing from the world.

**Game:** coreward  **Date:** 2026-09-12  **Belongs in:** TESTING.md / goldens / re-recording a baseline

## What happened
In Coreward (TypeScript, ES modules, esbuild for the pure test bundle), a one-line change added `import { anchorAt, anchorSealed, VAULT_W, VAULT_H } from './vaults'` to `src/sim/finds.ts`. `config.ts` already imported from `finds.ts`, and `vaults.ts` imports `W` from `config.ts`, so this created the cycle config -> finds -> vaults -> config. ES modules do not error on a cycle; `vaults.ts` evaluated `VAULT_CORE_X = Math.floor(W / 2)` while `config.ts` was still mid-evaluation, so `W` was undefined, the constant became NaN, and the Vault (the game's ending room) silently vanished from the generated world. Nothing threw. Four unrelated vault tests failed and the world-generation golden mismatched. The golden was re-recorded because the change WAS expected to move it (new crates), and only reading the re-recorded diff as counts per block id showed "- vaultwall 6, - vaultcore 6": ids LEAVING the world, when the change could only add crates. That line was the whole diagnosis. The golden was restored from git, the eviction logic moved into `world.ts` (which already imports both modules, so no cycle), and the re-recorded diff then read "+1 schematic" and nothing else.

## The rule
When a golden is re-recorded, read the diff as a count per id and refuse any re-record where an id LEAVES the world that the change could only have added. An ES-module import cycle between sim modules evaluates constants as undefined without an error, and the first observable sign is a missing room or object in the world.

## Replaces or contradicts
Never re-record a golden without reading the diff.
