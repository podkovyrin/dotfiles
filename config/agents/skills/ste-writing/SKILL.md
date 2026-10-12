---
name: ste-writing
description: Controlled-English writing rules distilled from ASD-STE100, adapted for software work. Strict mode for error messages, log lines, and panic text; prose mode for docs, UI text, doc comments, and commit bodies. Use whenever you write or edit English text in a software project.
---

# STE writing

ASD-STE100 exists because aerospace manuals cannot afford ambiguity. An error message read
during an incident has the same constraint. This skill is the essential subset of ASD-STE100
Issue 8 (53 rules + 6 recommendations), split into two modes. The full extracted rule set,
with what we kept and what we dropped, lives in [RULES.md](RULES.md).

Pick the mode from what you are writing:

| You are writing | Mode |
|---|---|
| error message, panic/assert text, error-context string | strict |
| log line (any level), alert text, metric description | strict |
| CLI/API user-facing error body | strict |
| UI labels, buttons, onboarding, and user-facing recovery text | prose; keep actions and risks precise |
| doc comment, documentation file, guide, README, man page | prose |
| code comment, commit body, PR description | prose |

## Both modes — the core

- One name per thing. Never rotate synonyms for the same item ("session" vs "login"),
  the same action ("cancel" vs "abort"), or the same event across call sites. (STE 1.11, 9.4)
- Active voice: name the actor. "the loader skips a held chain", not "a held chain is skipped". (3.6)
- Simple tenses only: present, past, future. No "has been", "had been", "will have been". (3.2)
- One verb, not a phrasal verb: "extinguish" not "put out", "remove" not "take off". (9.3)
- A pronoun must have exactly one possible referent. If "it"/"this"/"they" can point at two
  nouns, repeat the noun. (GR-3, GR-4)
- Keep small words. Never drop "that" after verbs like "make sure", "means", "shows", and
  never drop articles to sound terse in docs. (4.2, GR-1)
- Noun clusters of at most 3 words; hyphenate or unpack longer ones. (2.1)
- Be concrete: give the value, the limit, the name. "no leaks permitted" tells nobody what
  to do; "make sure that there are no leaks" does. (4.1)
- Use the substitution table in [RULES.md](RULES.md#substitutions) — "in order to" → "to",
  "prior to" → "before", "and/or" → "x, y, or both", and so on. The starred rows mark
  the mechanical subset; apply them by hand unless the project has a writing lint.
  The unstarred ones are yours to apply, and they are the ones that slip: "ensure" → "make
  sure that", "shall"/"should" (requirement) → "must", "commence" → "start", "attempt" →
  "try", "demonstrate" → "show", "as well as" → "and".
- "above" and "below" mean position, never a limit or a comparison. Write "more than 20 psi"
  and "a rate 5% higher than the opening rate", not "above 20 psi" or "5% above" it. (9.2)
- American spelling: "favor", "behavior", "analyze", "while", "among". A technical name keeps
  the spelling the code gives it, so `SessionCancelled` and `session_status = 'cancelled'`
  stay as they are. (1.14, 1.5)
- Leave no sentence open to two readings (GE-1 to GE-6 in [RULES.md](RULES.md#beyond-ste--global-english)).
  Keep "only" and "not" beside the word they change, and give the second half of a compound
  sentence its own verb.
- Name what "and" or "or" joins. Repeat the article when "the client and the host" are two
  things. Write "x, y, or both" instead of a slash, and never write a "(s)" plural.

## Strict mode

For messages, precision beats flow. On top of the core:

- At most 20 words per sentence or clause. One fact per sentence. (5.1, 5.2)
- State expected vs actual with the values: `expiry 1700000000 is before start 1700000100`.
  In structured logs the fields carry the values; the message names the event.
- Condition first, then the event or command: "if the lock is lost, the loop reconnects". (5.4, 7.2)
- Remediation hints are imperative: "increase MAX_SLICES", not "MAX_SLICES could be increased". (5.3)
- No contractions, no hedging ("probably", "seems"), no humor.
- Follow the existing message format at the call site. Do not carry one component's
  convention of lowercase starts, omitted periods, or `event; next action` logs into another, such as a UI.
  Keep public error codes and cross-boundary contract identifiers unchanged.
- Severity lives in the level/status, not the text — never prefix "warning:" in a warning-level log. (7.1)

## Prose mode

For docs and UI text, keep the existing tone, casing, and structure. This mode owns
the sentence level:

- Target 25 words per sentence. When a sentence carries two topics, split it. The em-dash
  aside is fine — but if you strip the asides and still count 25+, rewrite.
  The cap is a ceiling, never a target: a page whose sentences all land near one length
  reads mechanical, and that is the loudest sign nobody wrote it. Keep the long sentence
  that carries one topic with its condition. (6.3)
- One topic per paragraph, at most 6 sentences, information given gradually: each sentence
  builds on the one before it. (6.1, 6.4–6.6)
- 3+ parallel items go in a list or table, not a comma chain. (4.3)
- Keep contractions and "you" when they fit the existing tone (deviation from STE 4.2).
- "e.g."/"i.e." stay inside parentheses; in flowing prose write "for example"/"that is".
  Avoid "etc." — name the rest or cut it. (GR-6)
- Preserve required `MUST`/`SHALL` wording and scenario labels in specs and standards.
  Writing guidance does not add test documentation or completion gates.

### AI tells

[unslop](../unslop/SKILL.md) owns the AI-tell catalog:
puffery, the "not just X, but Y" shape, trailing "-ing" analysis, synonym cycling, chatbot
residue. Load it for prose, never for strict mode, and keep these carve-outs.

- Em-dash asides and parentheses stay (unslop 13 bans both).
- Navigational emoji stay (unslop 18 removes them).
- A bold lead-in that ends in a period is still over-structure here (unslop 16 allows it).
- "surface" can name an API boundary (unslop 26 reads it as a metaphor noun).
- Its "adding soul" section is for prose that carries a voice. Strict mode overrides it: a
  message the reader meets during an incident gets no first person, no opinion, and no mess.

## Validation

If the project has a docs lint or style check, run it. Also check writing manually against [RULES.md](RULES.md).
Sentence length, voice, tense, and vocabulary need context to judge.
After you change doc text, read it again and name the rules you checked by hand.
Sections 1, 3, 5, and 9, plus the unstarred substitutions, are where the violations
come from. A passing automated check does not prove writing compliance.
