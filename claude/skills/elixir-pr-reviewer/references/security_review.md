# Security Review Checklist

Security patterns and anti-patterns to check during Elixir PR reviews.

## API Schema Hardening

### Request Schema Validation

Always use `additionalProperties: false` on OpenApiSpex request schemas to prevent privilege escalation through unexpected field injection.

```elixir
# Bad - allows arbitrary fields through
%Schema{
  type: :object,
  properties: %{
    name: %Schema{type: :string},
    email: %Schema{type: :string}
  },
  required: [:name, :email]
}

# Good - rejects unexpected fields
%Schema{
  type: :object,
  properties: %{
    name: %Schema{type: :string},
    email: %Schema{type: :string}
  },
  required: [:name, :email],
  additionalProperties: false
}
```

### OpenApiSpex Plug Configuration

Use `struct?: false, derive?: false` on OpenApiSpex plugs to avoid nil-padding fields that weren't in the request.

```elixir
# Bad - creates struct with nil for missing optional fields
plug OpenApiSpex.Plug.CastAndValidate

# Good - keeps only fields that were actually sent
plug OpenApiSpex.Plug.CastAndValidate, struct?: false, derive?: false
```

## JWT and Token Security

### Audience Claims

- Single-string `aud` claim is valid per RFC 7519 section 4.1.3
- Do NOT change `aud` format (string vs array) without considering downstream consumers
- Use `azp` (authorized party) to distinguish the client that obtained the token from the intended audience
- Breaking audience changes will silently break downstream token validation

### Token Lifecycle

- Session refresh should bump TTL consistently with browser session behavior
- Token size budget: be aware of JWT size limits in HTTP headers (~8KB typical)
- Organization binding: bind tokens to org at code creation time, not at token exchange

### Auth Flow Patterns

- Use bearer-only pipelines for API endpoints
- Reject service accounts from user-facing auth flows
- Reject disabled users/orgs early in the pipeline, not deep in business logic
- Guard against nil `org_id` in token claims

## Log and Trace Redaction

### Sensitive Data in Logs

Flag any code that logs or traces:
- API keys, secrets, or tokens
- Passwords or hashed passwords
- PII (personally identifiable information)
- OAuth codes or refresh tokens

```elixir
# Bad - leaking secrets into logs
Logger.info("Connecting with API key: #{api_key}")

# Good - redact sensitive values
Logger.info("Connecting to external service", api_key_prefix: String.slice(api_key, 0, 4))
```

### Telemetry Events

- Ensure telemetry events don't include raw tokens or secrets in metadata
- Bound telemetry payload size to prevent memory issues from large payloads
- Audit log security-relevant operations (auth, permission changes, data access)

## Feature Flags and Kill Switches

### Separation of Concerns

Use separate kill switches for related but independent features. Don't use a single flag to control both reads and writes if they can fail independently.

```elixir
# Bad - one flag for everything
config :my_app, :feature_x_enabled, true

# Good - separate flags for independent failure domains
config :my_app, :feature_x_reads_enabled, true
config :my_app, :feature_x_writes_enabled, true
```

### Configuration Error Handling

Log configuration errors at the source (where config is loaded), not downstream where the missing config manifests as unexpected behavior.

## Data Safety

### Soft Delete Patterns

Soft delete features can create "trapdoor" situations where toggling a flag makes data changes that can't be cleanly reverted. Flag operations where:
- A feature flag triggers data mutations (not just visibility changes)
- Disabling a feature doesn't restore original state
- Soft-deleted records aren't filtered consistently across all query paths

### Input Sanitization

- Never use `String.to_atom/1` with user input (atom table is finite and not garbage collected)
- Validate and constrain all user-provided identifiers
- Use `String.to_existing_atom/1` only when the atom is guaranteed to exist

## What to Flag

1. Missing `additionalProperties: false` on request schemas
2. JWT claim format changes without downstream impact analysis
3. Secrets, tokens, or PII in log/telemetry output
4. Single feature flags controlling multiple independent operations
5. Soft delete operations that create irreversible state changes
6. Missing auth checks or auth checks happening too late in the pipeline
7. `String.to_atom/1` with any external input
