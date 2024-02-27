import_if_available Ecto.Query
import_if_available Ecto.Changeset

defmodule AC do
  def update(schema, changes) do
    schema
    |> Ecto.Changeset.change(changes)
    |> Repo.update()
  end

  IEx.configure(
    colors: [
      syntax_colors: [
        number: :light_yellow,
        atom: :light_cyan,
        string: :green,
        boolean: [:light_blue],
        nil: [:magenta, :bright]
      ],
      ls_directory: :cyan,
      ls_device: :yellow,
      doc_code: :green,
      doc_inline_code: :magenta,
      doc_headings: [:cyan, :underline],
      doc_title: [:cyan, :bright, :underline]
    ],
    default_prompt:
      [
        :yellow,
        " 󰇥 ",
        ">",
        :white,
        :reset
      ]
      |> IO.ANSI.format()
      |> IO.chardata_to_string()
  )
end
