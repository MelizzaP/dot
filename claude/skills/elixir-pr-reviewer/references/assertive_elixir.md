# Assertive Elixir Patterns

Concrete patterns for writing assertive Elixir code that crashes loudly on invalid state rather than silently propagating bugs.

## Core Principle

"Let it crash" is not just an OTP supervision strategy. It's a code-level discipline: trust your data contracts, assert on expectations, and let violations surface immediately rather than hiding behind defensive checks.

## Preloaded Associations

If you preloaded an association, assert on it. Don't defensively check for nil.

```elixir
# Bad - defensive nil check on preloaded association
user = Repo.get!(User, id) |> Repo.preload(:organization)

if user.organization do
  user.organization.name
else
  "Unknown"
end

# Good - you preloaded it, trust it
user = Repo.get!(User, id) |> Repo.preload(:organization)
user.organization.name
```

If the association can legitimately be nil (optional belongs_to), the preload still loaded it -- the nil IS the correct value. Handle it explicitly at the point where you need it, not as a "maybe it didn't load" guard.

## Assertive Conditionals

Prefer positive assertions over negative conditions.

```elixir
# Bad - double negative, harder to reason about
if not is_nil(user.email) do
  send_notification(user)
end

# Good - assert the positive case
if user.email do
  send_notification(user)
end

# Better - pattern match when the value is required
%{email: email} = user
send_notification(email)
```

## Unnecessary Rescue Clauses

Don't rescue errors you can't meaningfully handle. Especially don't rescue-and-return-nil.

```elixir
# Bad - swallowing errors, hiding bugs
def get_config(key) do
  try do
    Application.fetch_env!(:my_app, key)
  rescue
    _ -> nil
  end
end

# Good - crash if config is missing (it's a programming error)
def get_config(key) do
  Application.fetch_env!(:my_app, key)
end

# Also good - explicit handling when absence is expected
def get_config(key) do
  case Application.fetch_env(:my_app, key) do
    {:ok, value} -> value
    :error -> raise "Missing required config: #{key}"
  end
end
```

### When Rescue IS Appropriate

- External system calls (HTTP, database) where transient failures are expected
- Parsing user input that may be malformed
- Operations where you have a meaningful recovery strategy (retry, fallback, circuit break)

If your rescue clause just returns nil or logs and continues, it's almost certainly wrong.

## Unreachable Code

Flag code paths that can never execute. They indicate the author doesn't fully understand the data flow.

```elixir
# Bad - the else clause is unreachable if status is an Ecto.Enum
case record.status do
  :active -> handle_active(record)
  :inactive -> handle_inactive(record)
  :pending -> handle_pending(record)
  _ -> handle_unknown(record)  # unreachable if Ecto.Enum constrains values
end
```

Dead rescue clauses are a specific form of this:

```elixir
# Bad - this rescue can never trigger because Repo.get returns nil, not an error
try do
  Repo.get(User, id)
rescue
  Ecto.NoResultsError -> nil  # Repo.get doesn't raise
end
```

## Validation Layer

Validation should happen at the right layer, not defensively at every layer.

```elixir
# Bad - validating in schema, use case, AND controller
defmodule MySchema do
  def changeset(struct, attrs) do
    # validation here is correct
  end
end

defmodule MyUseCase do
  def call(params) do
    # Don't re-validate what the changeset already validates
    if is_nil(params.email), do: raise "email required"  # redundant
    # ...
  end
end

defmodule MyController do
  def create(conn, params) do
    # Don't validate here if the schema/changeset handles it
    if params["email"] == "", do: ...  # redundant
  end
end
```

The right layers for validation:
- **API schema (OpenApiSpex)**: Request shape and types
- **Ecto changeset**: Business rules and data integrity
- **Database constraints**: Uniqueness, foreign keys, check constraints

Don't duplicate validation across these layers.

## What to Flag

1. Nil checks on preloaded Ecto associations
2. `if not` / `unless` where a positive assertion is clearer
3. Rescue clauses that return nil or log-and-continue
4. Unreachable code paths (dead pattern match arms, impossible rescue targets)
5. Validation duplicated across multiple layers
6. Defensive coding that masks bugs instead of surfacing them
