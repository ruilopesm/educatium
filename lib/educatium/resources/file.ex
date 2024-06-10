defmodule Educatium.Resources.File do
  use Educatium, :schema

  @required_fields ~w(name resource_id directory_id)a
  @optional_fields ~w()a

  schema "files" do
    field :name, :string
    field :file, Educatium.Uploaders.File.Type

    belongs_to :resource, Educatium.Resources.Resource, foreign_key: :resource_id
    belongs_to :directory, Educatium.Resources.Directory, foreign_key: :directory_id

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(file, attrs) do
    file
    |> cast(attrs, @required_fields ++ @optional_fields)
    |> cast_attachments(attrs, [:file])
    |> validate_required(@required_fields)
  end
end
