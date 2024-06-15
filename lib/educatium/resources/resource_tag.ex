defmodule Educatium.Resources.ResourceTag do
  use Educatium, :schema

  alias Educatium.Resources.{Resource, Tag}

  @required_fields ~w(resource_id tag_id)a
  @optional_fields ~w()a

  schema "resources_tags" do
    belongs_to :resource, Resource
    belongs_to :tag, Tag

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(resource_tag, attrs) do
    resource_tag
    |> cast(attrs, @required_fields ++ @optional_fields)
    |> validate_required(@required_fields)
  end
end
