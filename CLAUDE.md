# forge-action — the Forge GitHub Action

The reusable GitHub Action wrapper that runs Forge in CI. **No service deploy** — consumers
reference it by tag/ref, so keep inputs/outputs backward-compatible and tag releases deliberately.

<!-- shared:forge-fleet -->
## The Forge fleet & the roadmap

Forge is **one product built as a fleet of independently-deployed services**, all under
`github.com/simple-container-com`. You are in one of them; the others are sibling checkouts
(e.g. `../forge`, `../forge-conductor`). The fleet:

- **forge** — umbrella repo: the **roadmap + design docs** (`docs/roadmap`, `docs/design`) and the parent infra stack (`.sc/stacks/infra`).
- **forge-conductor** — "Hermes", the control plane + operator SPA (`app.simple-forge.com`): agent-workflow engine, issue/pipeline orchestration, runtime queue.
- **forge-aigateway** — the LLM gateway (`ai.simple-forge.com`): provider routing, generations, output-scan, egress logging.
- **forge-sessions** — cloud session + transcript store (`sessions.simple-forge.com`).
- **forge-runtime** — cloud-exec runtime (`inference.simple-forge.com`) + the agent-worker (Firecracker/k8s) that runs `claude` turns, the forge-mcp-bridge, and forge-stream-relay.
- **forge-notifier** — outbound notifications (`notifier.simple-forge.com`).
- **forge-storage** — object storage service (`storage.simple-forge.com`).
- **forge-cli** — the `forge` CLI (cloud-lift / pull / stitch, sessions sync).
- **forge-contracts** — shared types/contracts consumed across services.
- **forge-action** — the Forge GitHub Action.

**The roadmap is the single source of truth** for what is planned, in progress, and shipped:
**`forge/docs/roadmap/README.md`** (in the `forge` repo). Design docs live under
`forge/docs/design/<YYYY-MM-DD>/<feature>/`.

**Contributing to the roadmap — do it as part of every change, not after:**
- **Shipping a slice?** Update its roadmap entry to `✅ SHIPPED + live-verified <YYYY-MM-DD>`
  with the **commit SHA**, a tight summary of what landed, and what is still open. "Shipped"
  means *deployed AND verified live on staging* — not "code written". Be honest; don't overclaim.
- **Starting a milestone?** Add an entry: the goal (ideally in the requester's words), a link to
  its design doc, a first-step / walking-skeleton, and a clear **definition of done**.
- Keep entries scannable — push detail into the design doc.

## Definition of done & documentation discipline

A change is done when it is **shipped, verified, and documented** — not when it compiles. For
every non-trivial slice:

1. **Design doc** (substantial features) — `forge/docs/design/<date>/<feature>/README.md`: the
   decisions + file-grounded approach, before the code.
2. **Tests + a live smoke** — unit tests, AND a smoke against staging before you call it done.
   A green build ≠ works: bson/Cloudflare/runtime-wiring gotchas only surface live.
3. **Swagger** (services with annotated HTTP handlers) — new/changed `@Router` endpoints →
   `make swag` + commit `internal/docs/`. The Validate drift gate blocks deploy otherwise.
4. **Deploy via GitHub Actions only** — pushing to `main` triggers the service's Deploy workflow
   (or `gh workflow run …`). **Never** run `sc deploy` locally; it clobbers staging env.
5. **Roadmap + durable notes** — mark the slice shipped/verified (above), and record non-obvious
   decisions + live-caught gotchas where they'll be found again (design doc, code comments,
   agent memory).
6. **Secrets never touch git** — `.sc/stacks/*/secrets.yaml` and `.sc/cfg.github.yaml` stay
   gitignored; only the encrypted `.sc/secrets.yaml` registry is committed.
