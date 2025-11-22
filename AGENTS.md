# Account Config Agent Guide

This repository publishes the public `Account` configuration package. It vends AWS Organizations accounts, wires OU placement, emits ProviderConfigs, and chains into the private `AccountBaseline` composite. Use this guide whenever you update schemas, templates, or automation.

## Repository Layout

- `apis/` — XRD, composition, and packaging metadata for the Account composite.
- `examples/` — Minimal and feature-rich specs used by docs and tests.
- `functions/render/` — Go-template pipeline with desired/observed separation (`00-`, `05-`, `10-`, … `99-`). Leave numeric gaps for future inserts.
- `tests/` — KCL-based regression suites executed via `up test`. Add an `e2e` suite when we start writing live org tests.
- `.github/`, `.gitops/` (if present) — Workflows and GitOps manifests; these should mirror the layout used in `configuration-cert-manager`.
- `_output/`, `.up/` — Generated artefacts; nuke with `make clean`.

## Rendering Guidelines

- Hoist every reusable value inside `00-desired-values*.gotmpl`. Later files should only reference the hoisted values.
- Mirror the pipeline defined in `docs/plan/01-account-xrd.md`: org bootstrapping, OU resolution, account creation, SCP attachments, ProviderConfig creation, and status projection.
- Derive AWS tags by merging `{"hops": "true"}` with `spec.parameters.tags`.
- Keep templating simple—inline strings such as ARNs instead of building maps or ternaries.
- Guard optional resources with booleans (e.g., only render the Organizations root when `ouPath == "root"` and no org exists).
- When giving pods AWS access, depend on our IRSA or PodIdentity composites instead of rebuilding IAM plumbing.
- **Avoid Upbound-hosted configuration packages unless they are mirrored into `crossplane-contrib`**; paid-account gated bundles break our OSS workflow. Carry this reminder forward whenever you touch AGENTS files.
- `configuration-aws-ipam` (render tests) and `configuration-aws-irsa` (tests + e2e) are the closest reference repos—follow their observed-resource gating, fixtures, and workflow wiring whenever you are unsure about structure.

## Testing

- Unit-style render tests live under `tests/test-render`. Use dedicated example specs to assert the behaviour that matters (OU trees, SCP sets, ProviderConfig naming, etc.).
- Prefer `assertResources` partials over full-manifest snapshots so templates remain evolvable.
- Run `make test` (alias for `up test run tests/*`) after every change to templates, examples, or the schema.
- Keep render/e2e assertions scoped to org/account resources. The e2e suite currently waits on `Synced` instead of `Ready` to avoid flaking on eventual-consistency delays in Organizations.

## Development Workflow

1. `make render-example` – Sanity check example composition renders.
2. `make validate` – Lint CRDs/compositions and ensure examples conform.
3. `make test` – Execute the regression suite.
4. Add or refresh docs/README snippets whenever the public API shifts.

Document behavioural changes in `README.md` and keep `examples/` plus `tests/` in sync. When new providers or functions are required, update both `apis/accounts/configuration.yaml` and `upbound.yaml`.
