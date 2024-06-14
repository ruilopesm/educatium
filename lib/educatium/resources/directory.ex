defmodule Educatium.Resources.Directory do
  use Educatium, :schema

  alias Educatium.Resources.{File, Resource}

  @required_fields ~w(name resource_id)a
  @optional_fields ~w(directory_id)a
  schema "directories" do
    field :name, :string

    belongs_to :resource, Resource, foreign_key: :resource_id
    belongs_to :directory, __MODULE__, foreign_key: :directory_id

    has_many :files, File
    has_many :subdirectories, __MODULE__

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(directory, attrs) do
    directory
    |> cast(attrs, @required_fields ++ @optional_fields)
    |> validate_required(@required_fields)
  end
end
