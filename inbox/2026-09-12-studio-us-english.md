# Gideon is in the United States, so everything he or a player reads is US English

**Game:** studio  **Date:** 2026-09-12  **Belongs in:** PLAYER.md / Preferences that carry into every game

## What happened
He asked for it directly: "I live in the US but it seems like claude keeps saying I'm from
the UK or using UK spellings. Can you make sure all current and future games know that I am
from the US and to use US spellings of words?" Nothing in the base said where he lives, and
the exemplars a session imitates were themselves British: `licence` in `ASSETS.md`'s row and
in the asset-scout agent's own description line, `summarising` in `MODELS.md`, `centre` in
the playtest skill, `serialisation` in `INDEX.md` rule 2, and 26 more across
`godot-template`. A session that copies the surrounding style was being taught to write
British English by the framework itself, which is why saying it once never held. Fixed on
2026-09-12: `INDEX.md` standing rule 15 states it, `scripts\us-english.txt` is the word
list, `doctor.ps1`'s `Test-USEnglish` WARNs on a hit in a game's strings, scene text,
changelog and README, and `skills\digest\SKILL.md` converts a topic-file section whenever it
folds a lesson into it.

## The rule
Write US English in everything he or a player reads: chat replies, reports, commit subjects,
changelogs, README text, on-screen strings, and the Play listing, which is en-US with USD
pricing. It is spelling, not units, so Godot's meters stay meters, and a word is left alone
when it is an identifier, a shader uniform, a dictionary key, an external API field or quoted
third-party license text. The list is `scripts\us-english.txt`; add a word there when one is
missing and the doctor and the digest both learn it.

## Replaces or contradicts
Nothing. Neither `PLAYER.md` nor `PLAY.md` says anything about spelling, locale or currency:
a grep for `en-GB`, `en-US`, `USD`, `British`, `American`, `spelling`, `locale` and `UK`
across both returns no line. This is a new rule in `PLAYER.md`'s "Preferences that carry into
every game", and `PLAY.md`'s "The listing" section should gain one line saying the listing
defaults to en-US and the price to USD.
