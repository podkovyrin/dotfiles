# ASD-STE100 rule extraction

This is the essential content of ASD-STE100 Issue 8 (2021-04-30), Part 1 — 9 sections,
53 rules, 6 general recommendations — mapped onto software writing, plus one section STE does not
cover: the Global English disambiguation rules. Each rule carries a tag:

- `both` — applies in strict and prose mode
- `strict` / `prose` — applies in that mode only
- `adapted` — we keep the intent but deviate; the deviation is stated
- `n/a` — does not transfer to software writing; the reason is stated

STE separates *procedural* writing (instructions, max 20 words/sentence) from *descriptive*
writing (information, max 25 words/sentence). Our strict mode inherits the procedural
limits, prose mode the descriptive ones.

## Section 1 — words

| Rule | Content | Tag |
|---|---|---|
| 1.1–1.3 | Use a controlled vocabulary: each word has one approved meaning and one part of speech | adapted — we have no 900-word dictionary; the transfer is "one word, one meaning": pick one term per concept and hold it |
| 1.4 | Use only approved verb/adjective forms | n/a — dictionary-specific |
| 1.5–1.9 | Technical names are open vocabulary; keep them short, official, consistent | both — the project's domain terms are its technical names; use the code's name, never a paraphrase |
| 1.10 | No slang or jargon as technical names | both |
| 1.11 | Never use different technical names for the same item | both — the single highest-value STE rule for a codebase |
| 1.12–1.13 | Technical verbs allowed; do not use them as nouns | adapted — "the parse failed" is idiomatic in engineering; prefer the verb form when both read well |
| 1.14 | American English spelling | both — matches most codebases and APIs (`canceled`, `color`, `behavior`). Check common British forms manually unless the project has a spelling lint. A technical name keeps the spelling the code gives it, so `SessionCancelled` and `session_status = 'cancelled'` are exempt (1.5) |

## Section 2 — noun clusters

| Rule | Content | Tag |
|---|---|---|
| 2.1 | No noun cluster longer than 3 words | both — "chain sync checkpoint drift metric" needs unpacking or hyphens |
| 2.2 | Longer technical names: write in full once, then shorten or hyphenate | both |
| 2.3 | Use articles (the/a/an) and demonstratives before nouns | prose — strict mode allows telegraph form where it is the established diagnostic message style |

## Section 3 — verbs

| Rule | Content | Tag |
|---|---|---|
| 3.1–3.2 | Only infinitive, imperative, simple present, simple past, past participle (as adjective), future | both — no perfect tenses: "the session expired", never "the session has been expired" |
| 3.3 | Past participle only as an adjective ("the removed parts") | both |
| 3.4 | No complex helping-verb structures | both — "you can adjust X", not "X can be adjusted"; "adjust X", not "X must be adjusted" |
| 3.5 | "-ing" forms only in technical names | adapted — "when running the tests" → "when you run the tests" in prose; log telegraph keeps "-ing" for the in-progress action ("reconnecting") because it states what the process is doing right now |
| 3.6 | Active voice; mandatory in procedures, preferred in description | both |
| 3.7 | Describe an action with a verb, not a nominalization | both — "failed to decode the response", not "response decoding failure occurred" |

## Section 4 — sentences

| Rule | Content | Tag |
|---|---|---|
| 4.1 | Short, clear, specific sentences; never vague ("no leaks permitted" → "make sure that there are no leaks") | both |
| 4.2 | Do not omit words or use contractions to shorten | strict for contractions; prose keeps contractions when they fit the existing tone but never drops "that" or articles |
| 4.3 | Vertical lists for complex text | prose — use a list or table when it makes complex text easier to read |
| 4.4 | Connect related sentences with connecting words (thus, then, before, after) | prose |

## Section 5 — procedural writing (→ strict mode)

| Rule | Content | Tag |
|---|---|---|
| 5.1 | Max 20 words per sentence | strict |
| 5.2 | One instruction (for us: one fact) per sentence, unless simultaneous | strict |
| 5.3 | Instructions in the imperative | strict — remediation hints and doc procedures ("run the checks") |
| 5.4 | Descriptive statement before a command, divided by a comma — condition first | strict |
| 5.5 | Notes give information, not instructions | prose — a doc "note:" must not hide a required step |

## Section 6 — descriptive writing (→ prose mode)

| Rule | Content | Tag |
|---|---|---|
| 6.1 | Give information gradually | prose |
| 6.2 | Use key words/phrases to organize text logically | prose |
| 6.3 | Max 25 words per sentence | prose — guideline, not a lint. The cap is a ceiling, never a target: sentences that all land near one length read mechanical. Split a sentence carrying two topics. Keep a long one that carries a single topic with its condition |
| 6.4–6.5 | Paragraph = related information, exactly one topic | prose |
| 6.6 | Max 6 sentences per paragraph | prose |

## Section 7 — safety instructions (→ warnings, alerts)

| Rule | Content | Tag |
|---|---|---|
| 7.1 | A word identifies the risk level (warning/caution) | adapted — the log level or alert severity IS the risk word; never restate it in the message text |
| 7.2 | Start with a clear, simple command or condition | strict |
| 7.3 | Then give the specific risk or result | strict — "aborting remaining ticks" follows "grace period elapsed" |

## Section 8 — punctuation and word count

| Rule | Content | Tag |
|---|---|---|
| 8.1 | No semicolons — write two sentences | adapted — existing log telegraph `event; next action` can keep its semicolon; in prose prefer a period when a semicolon joins two full sentences |
| 8.2 | Hyphens connect closely related words | both |
| 8.3 | Parentheses for references, identifiers, abbreviations, alternatives | both |
| 8.4–8.7 | Word-count conventions: parenthetical text, numbers, units, quoted text, hyphenated words each count as one word | both — count this way when you apply the 20/25-word caps |

## Section 9 — writing practices

| Rule | Content | Tag |
|---|---|---|
| 9.1 | When a word swap changes the meaning, rewrite the sentence instead | both |
| 9.2 | Use each word with its exact meaning ("above/below" = position, not limits: "more than 20 psi", not "above 20 psi") | both — judgment, never a lint. It earns its keep on a numeric bound in an error message; in prose "just under 100%" and "precision over 2^53" are clear, and rewriting them costs more than it buys |
| 9.3 | No phrasal verbs ("give off" → "release", "put out" → "extinguish") | both — check manually; few lints catch phrasal verbs |
| 9.4 | Consistent terminology and consistent wording for the same context | both — same event, same message text, at every call site |

## General recommendations

| GR | Content | Tag |
|---|---|---|
| GR-1 | Keep the conjunction "that" ("make sure that the valve is open") | both |
| GR-2 | "with" is 3-way ambiguous (has / together with / by means of) — reread and disambiguate | both — "install the panel with the green fasteners" is the canonical trap |
| GR-3 | Replace a pronoun with its noun when two referents are possible | both |
| GR-4 | "this" must have one clear referent; otherwise restate the context | both |
| GR-5 | False friends: check the English meaning, not your native language's | both |
| GR-6 | No Latin abbreviations (e.g., i.e., etc.) | adapted — "e.g."/"i.e." allowed inside parentheses (house convention); avoid "etc." — name the rest or cut it |

## Beyond STE — Global English

STE removes the ambiguity that lives in a sentence's vocabulary and its length. It says
little about the syntax that lets one sentence read two ways. The six below close that gap.
Source: Kohl, *The Global English Style Guide* (SAS Press).

| GE | Content | Tag |
|---|---|---|
| GE-1 | Keep "only" and "not" next to the word they change | both — "only fails on growth" and "fails only on growth" state different things |
| GE-2 | Never drop the verb from the second half of a compound sentence | both — "phase 1 moves the converters and phase 2 the runtime" leaves phase 2 without one |
| GE-3 | Repeat the article in a series when it prevents a misread | prose — "the client and the host" when they are two things, not "the client and host" |
| GE-4 | Say which parts "and" or "or" joins when a sentence groups two ways | both — "both … and", "either … or", and "if … then" cost nothing and settle it |
| GE-5 | No slash that stands in for a relation between two words | both — write "x, y, or both", never "a/b". check `and/or` manually; a path, a protocol name, a unit, and an established compound term keep their slash |
| GE-6 | No "(s)" plural; text in parentheses is a full grammatical unit | both — write "one or more directions", never "direction(s)". `http(s)` is a protocol name, not a plural |

GE-5 and GE-6 require judgment. Protocol names, paths, and established compound terms
keep their slash; do not change code identifiers to satisfy prose rules.

## Substitutions

The starred rows mark the mechanical subset from the source skill. Apply these replacements
manually unless the project has a writing lint, and preserve quoted text, code
identifiers, and required `MUST`/`SHALL` spec wording.

| Never write | Write | |
|---|---|---|
| in order to | to | * |
| prior to | before | * |
| subsequent to | after | * |
| utilize | use | * |
| and/or | x, y, or both | * |
| due to the fact that | because | * |
| in the event of/that | if | * |
| at this point in time | now | * |
| in a timely manner | quickly, or give the deadline | * |
| make use of | use | * |
| with regard/respect to | for, about | * |
| it is necessary/recommended/advised to | must, or the imperative | * |
| a number of | the count, or "some" | * |
| is/are able to | can | * |
| carry out | do, run | * |
| take into account | include, allow for | * |
| shall / should (requirement) | must |  |
| ensure | make sure that |  |
| above/below (a limit) | more/less than |  |
| commence | start |  |
| attempt (verb) | try |  |
| demonstrate | show |  |
| as well as | and |  |

The unstarred rows are judgment calls: they collide with quoted text or established house
usage often enough that a lint would false-positive, so apply them yourself when writing
new text.
