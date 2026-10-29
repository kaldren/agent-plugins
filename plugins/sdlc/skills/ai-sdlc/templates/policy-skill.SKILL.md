---
name: secure-api-review
description: Apply the API security standard. Use whenever creating or modifying an external-facing endpoint, reviewing API code, or generating an OpenAPI spec.
---

# Secure API review
<!-- Example policy skill from the playbook. Replace with the real policy, written from the policy owner's source of truth.
     Owner: <name>. Source of truth: <link>. Changes to this file need the owner's approval. -->

When you create or change an API endpoint:

1. **Authentication:** every endpoint requires the gateway JWT; no anonymous routes outside /health.
2. **Input validation:** validate request bodies against the OpenAPI schema and reject unknown fields.
3. **Audit:** every state-changing endpoint emits an audit event with actor, action, entity and timestamp.
4. **Data classification:** fields tagged `pii` in the schema must never appear in logs or error messages.

Run `scripts/check-endpoints.sh` and include its output in your summary.
<!-- A skill is advisory. If this policy must always hold, back it with a hook or a REVIEW.md pass. -->
