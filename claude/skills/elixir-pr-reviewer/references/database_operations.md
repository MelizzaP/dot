# Database Operation Patterns

Patterns for efficient and correct database operations in Ecto.

## Batch Operations

### Use update_all for Bulk Updates

When updating multiple records, use `Repo.update_all/3` instead of looping with individual updates.

```elixir
# Bad - N individual UPDATE queries
users
|> Enum.each(fn user ->
  user
  |> User.changeset(%{active: false})
  |> Repo.update()
end)

# Good - single UPDATE query
from(u in User, where: u.id in ^user_ids)
|> Repo.update_all(set: [active: false, updated_at: DateTime.utc_now()])
```

### Use insert_all for Bulk Inserts

```elixir
# Bad - N individual INSERT queries
items
|> Enum.each(fn attrs ->
  %Item{}
  |> Item.changeset(attrs)
  |> Repo.insert()
end)

# Good - single INSERT query (when changeset validation isn't needed per-row)
now = DateTime.utc_now()
entries = Enum.map(items, &Map.merge(&1, %{inserted_at: now, updated_at: now}))
Repo.insert_all(Item, entries)
```

### Use delete_all for Bulk Deletes

```elixir
# Bad
records |> Enum.each(&Repo.delete/1)

# Good
from(r in Record, where: r.batch_id == ^batch_id) |> Repo.delete_all()
```

### Spotting Batch Opportunities

Flag any `Enum.each/2`, `Enum.map/2`, or comprehension that contains `Repo.insert/1`, `Repo.update/1`, or `Repo.delete/1` inside the callback. Ask: "Can we batch here?"

## Association Queries

### Use the assoc Macro

Use `Ecto.assoc/2` for building queries on associations instead of manually constructing joins with foreign keys.

```elixir
# Bad - manual foreign key reference
from(lt in LookupTable, where: lt.line_item_id == ^line_item.id)

# Good - use assoc
from(lt in assoc(line_item, :lookup_table))

# Also good in a pipeline
line_item
|> Ecto.assoc(:lookup_table)
|> Repo.all()
```

### Preload Strategies

Choose the right preload strategy:

```elixir
# Separate query per association (default, good for large associations)
Repo.preload(posts, [:comments, :tags])

# Join-based preload (good for small associations, avoids extra queries)
from(p in Post, preload: [comments: ^from(c in Comment, order_by: c.inserted_at)])
|> Repo.all()

# Inline preload in the original query (single query)
from(p in Post,
  join: u in assoc(p, :user),
  preload: [user: u]
)
|> Repo.all()
```

## Soft Delete Patterns

### Consistent Filtering

When the codebase uses soft deletes (`deleted_at` field), every query path must filter deleted records explicitly. Missing filters cause "ghost" records to appear.

```elixir
# Bad - returns soft-deleted records
def list_items do
  Repo.all(Item)
end

# Good - explicit filter
def list_items do
  from(i in Item, where: is_nil(i.deleted_at))
  |> Repo.all()
end

# Better - composable query fragment
defp not_deleted(query) do
  where(query, [q], is_nil(q.deleted_at))
end

def list_items do
  Item |> not_deleted() |> Repo.all()
end
```

### Soft Delete Trapdoors

Flag operations where:
- A feature flag triggers data mutations (setting `deleted_at`) rather than just hiding records from views
- Disabling the feature doesn't restore `deleted_at` to nil
- The operation is described as "reversible" but the undo path doesn't exist

## Import Collision Avoidance

When importing `Ecto.Query` alongside modules that define their own `update/2` or similar functions, use `:except` to avoid compilation warnings and accidental shadowing.

```elixir
# Bad - collision between Ecto.Query.update/2 and Ecto.Changeset.change/2
import Ecto.Query
import Ecto.Changeset

# Good - explicit exclusion
import Ecto.Query, except: [update: 2]
import Ecto.Changeset
```

## What to Flag

1. `Enum.each/map` wrapping individual `Repo.insert/update/delete` calls -- suggest batch operations
2. Manual foreign key joins where `Ecto.assoc/2` would work
3. Missing `deleted_at` filters in query paths (when the schema uses soft deletes)
4. Soft delete operations that mutate data irreversibly under a "reversible" feature flag
5. `import Ecto.Query` without `:except` when other imports create naming collisions
