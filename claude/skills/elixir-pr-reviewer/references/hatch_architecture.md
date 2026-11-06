# Hatch Elixir Architecture Conventions

Project-specific architectural rules for hatch-elixir. These override generic Phoenix/Ecto guidance when reviewing PRs in this codebase.

## Domain-Driven Structure

### Domain Boundaries

Code must live in the appropriate domain module. The codebase is organized by business domain:
- `Automations` - automation rules, triggers, workflows
- `Messaging` - chat, notifications, communication
- `Analysis` - analytics, reporting, data analysis
- `Billing` - quotes, invoices, payments
- `Scheduling` - appointments, calendars, availability

**Anti-pattern: Generic locations.** Code in `Helpers`, `Utils`, `Shared`, or `Common` modules creates hidden coupling among domains. Flag any new module in these namespaces.

```elixir
# Bad - generic helper that couples domains
defmodule Hatch.Helpers.FormatHelper do
  def format_phone(phone), do: ...
  def format_currency(amount), do: ...
end

# Good - logic lives in its domain
defmodule Hatch.Messaging.PhoneFormatter do
  def call(phone), do: ...
end
```

### UseCase Pattern

All business operations are implemented as UseCase modules. Rules:

1. **One entry point**: Public functions must be named `call/1` or `call/2`
2. **One module per operation**: Each UseCase handles a single business operation
3. **No shared UseCases**: If two domains need similar logic, each gets its own UseCase

```elixir
# Good - single entry point
defmodule Hatch.Billing.UseCases.CreateQuote do
  def call(params) do
    # ...
  end
end

# Bad - multiple public entry points
defmodule Hatch.Billing.UseCases.QuoteOperations do
  def create(params), do: ...
  def update(quote, params), do: ...
  def send(quote), do: ...
end
```

### Schema Layer Rules

Schema modules should only export:
- Changeset functions (`changeset/2`, `registration_changeset/2`, etc.)
- Type definitions and struct definitions

Business logic does NOT belong in schema modules. If you see query functions, data transformation, or business rules in a schema module, flag it.

```elixir
# Bad - business logic in schema
defmodule Hatch.Billing.Schemas.Quote do
  use Ecto.Schema

  schema "quotes" do
    # ...
  end

  def changeset(quote, attrs), do: ...

  # This should be in a UseCase or context, not here
  def calculate_total(quote) do
    Enum.reduce(quote.line_items, 0, &(&1.amount + &2))
  end
end
```

### Facade Access Pattern

Domain logic should be accessed through facade modules, not by importing or aliasing internal modules directly.

```elixir
# Bad - reaching into domain internals
alias Hatch.Billing.UseCases.CreateQuote
CreateQuote.call(params)

# Good - go through the facade
Hatch.Billing.create_quote(params)
```

### Cross-Domain Communication

Domains should not directly call into each other's internals. When domains need to interact:
- Use the other domain's facade/public API
- Use events/PubSub for loose coupling
- Never import or alias another domain's schemas, use cases, or internal modules

## What to Flag

When reviewing PRs, flag these architectural violations:

1. New `Helpers` or `Utils` modules
2. UseCase modules with public functions other than `call/1` or `call/2`
3. Business logic in Schema modules
4. Direct access to another domain's internal modules (bypassing facades)
5. Code placed in the wrong domain (e.g., billing logic in the messaging domain)
6. Shared modules that create coupling between unrelated domains
