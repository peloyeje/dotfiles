---
name: session-report
description: Explicitly invoked command to synthesize the current session into a structured Markdown report saved to ~/Documents/ with a YYYY-MM-DD-title.md filename. Use when the user asks to "write a report", "document findings", "save conclusions", or invokes /session-report. Never auto-trigger.
argument-hint: [focus hint]
---

# Session Report

Write a structured Markdown report synthesizing the current session's findings and save it to `~/Documents/`.

## Step 1: Ask what to focus on

Before writing anything, ask the user two short questions in a single message:

1. **Theme/angle** - what aspect should be front and center? (e.g. root cause, risk surface, design decision, implementation approach)
2. **Scope** - what should be included or excluded? (e.g. just today's incident, the full investigation including related systems, only actionable findings)

If the user already provided a focus hint as an argument, use it to pre-fill your understanding and ask only for what's still missing.

Wait for the user's answer before proceeding.

## Step 2: Choose structure

Do not read existing reports at invocation time. Use the section menu below to pick what fits the content type and the user's focus.

**Section menu** (use only what fits - order to match the content's natural flow):

- **Context / Background** - why this was investigated, what system/component is involved
- **Summary** - 2-4 sentence executive digest; include for longer or multi-topic reports
- **Findings** / **Results** / **Analysis** - the substance, organized by theme not by chronology
- **Root cause** / **Explanation** - for incident/debugging reports
- **Research process** / **Method** / **Protocol** - queries run, systems inspected, what was ruled out
- **Impact** / **Risk** - who/what is affected and to what degree
- **Options** / **Recommendations** / **Next steps** - actionable conclusions with tradeoffs

**By report type:**
- *Incident / debugging* - Context, Root cause, Research process, Impact, Options
- *Analysis / exploration* - Context, Results/Analysis (subsections by theme), Recommendations
- *Design / spec* - Context, Summary, Options (with tradeoffs), Recommendations
- *How-to / protocol* - Context, Method, Results, Caveats

The structure should fit the content. These are patterns observed across the user's existing reports, not a rigid template.

## Step 3: Write the report

### Title and filename

- Filename: `YYYY-MM-DD-<kebab-case-title>.md` using today's date
- H1 title: sentence case, concise, describes the subject not the activity (e.g. "Redshift orphaned queries" not "Investigation of the Redshift orphaned queries incident")

### Content principles

**Lead with conclusions.** The report is not a transcript. Start with what was found, decided, or recommended - not with how the session started. Readers should get the answer in the first few sections.

**Surface the research process where it adds value.** Include investigative steps, queries run, data inspected, and intermediate findings when they:
- Justify a conclusion that might otherwise seem arbitrary
- Show the scope of what was ruled out
- Provide a reproducible method someone else could follow
- Reveal something surprising that shaped the final answer

Omit steps that were purely mechanical or dead ends with no informational value.

**Technical language, no padding.** Write for a technical peer who wasn't in the session. Be precise about versions, values, system names, file paths. No marketing language, no filler phrases ("it's worth noting that", "it is important to emphasize").

**Use tables and code blocks liberally** when they communicate structure more clearly than prose - timelines, configuration values, comparison of options, query results.

## Step 4: Save and confirm

Save to `~/Documents/YYYY-MM-DD-<title>.md`. Report the full path to the user.
