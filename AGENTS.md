# CopperScript entry point

Before design work, run `copper agent-guide`
in the active CopperScript environment. Retrieve individual guide topics and
library contracts as needed. Follow this project's README and build/review targets
for its board configuration and evidence.

If the pinned compiler lacks the guide, explicitly select a current compiler for
guidance/review as the README describes; retain the project's build pins. This is
a reusable project template: carry this pointer into new board projects, with
their own configuration. Keep generic algorithms in CopperScript.

## Rust layout migration

Read docs/project-migration.md before using historical scripts or build evidence.
Use the pinned Rust CLI and active paths in make/targets/. Old compiler-internal
Python helpers are migration references; do not install them into the normal build
or weaken their checks. `make test` and packaging stay blocked until their required
coverage is migrated. Historical evidence is not refreshed by moving files.
