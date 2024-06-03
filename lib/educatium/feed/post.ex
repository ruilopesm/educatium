defmodule Educatium.Feed.Post do
  use Educatium, :schema

  @types ~w(resource)a

  @required_fields ~w(upvotes_count downvotes_count type)a
  @optional_fields ~w()a

  schema "posts" do
    field :upvotes_count, :integer, default: 0
    field :downvotes_count, :integer, default: 0
    field :type, Ecto.Enum, values: @types

    has_one :resource, Educatium.Resources.Resource

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(post, attrs) do
    post
    |> cast(attrs, @required_fields ++ @optional_fields)
    |> validate_required(@required_fields)
    |> validate_inclusion(:type, @types)
  end

  def types, do: @types
end
