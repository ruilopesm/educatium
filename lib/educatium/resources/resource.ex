defmodule Educatium.Resources.Resource do
  use Educatium, :schema

  alias Educatium.Accounts.User
  alias Educatium.Feed.Post

  @types ~w(book article presentation project report exam assignment solution)a
  @visibilities ~w(protected private public)a

  @required_fields ~w(title description type date visibility user_id)a
  @optional_fields ~w()a

  schema "resources" do
    field :title, :string
    field :description, :string
    field :type, Ecto.Enum, values: @types
    field :date, :date
    field :visibility, Ecto.Enum, values: @visibilities, default: :public

    belongs_to :user, User
    belongs_to :post, Post

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(resource, attrs) do
    resource
    |> cast(attrs, @required_fields ++ @optional_fields)
    |> validate_required(@required_fields)
  end

  def types, do: @types
  def visibilities, do: @visibilities
end
