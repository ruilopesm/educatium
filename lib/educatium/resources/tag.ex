defmodule Educatium.Resources.Tag do
  use Educatium, :schema

  alias Educatium.Resources.{Resource, ResourceTag}

  @colors ~w(
    gray
    red
    orange
    amber
    yellow
    lime
    green
    emerald
    teal
    cyan
    sky
    blue
    indigo
    violet
    purple
    fuchsia
    pink
    rose
  )a

  @required_fields ~w(name color)a
  @optional_fields ~w()a

  schema "tags" do
    field :name, :string
    field :color, Ecto.Enum, values: @colors, default: :gray

    many_to_many :resources, Resource, join_through: ResourceTag

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(tag, attrs) do
    tag
    |> cast(attrs, @required_fields ++ @optional_fields)
    |> validate_required(@required_fields)
  end

  def colors, do: @colors
end
