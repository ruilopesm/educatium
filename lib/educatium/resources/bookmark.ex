defmodule Educatium.Resources.Bookmark do
  use Educatium, :schema

  alias Educatium.Accounts.User
  alias Educatium.Resources.Resource

  @required_fields ~w(user_id resource_id)a
  @optional_fields ~w()a

  schema "bookmarks" do
    belongs_to :user, User
    belongs_to :resource, Resource

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(bookmark, attrs) do
    bookmark
    |> cast(attrs, @required_fields ++ @optional_fields)
    |> validate_required(@required_fields)
    |> unique_constraint([:user_id, :resource_id], name: :unique_bookmarks)
  end
end
