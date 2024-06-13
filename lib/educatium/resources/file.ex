defmodule Educatium.Resources.File do
  use Educatium, :schema

  alias Educatium.Resources.{Directory, Resource}
  alias Educatium.Uploaders.File, as: UFile

  @required_fields ~w(name resource_id directory_id)a
  @optional_fields ~w()a

  schema "files" do
    field :name, :string
    field :file, UFile.Type

    belongs_to :resource, Resource
    belongs_to :directory, Directory

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
