defmodule Educatium.Feed.Bookmark do
  use Educatium, :schema

  alias Educatium.Accounts.User
  alias Educatium.Feed.Post

  @required_fields ~w(user_id post_id)a
  @optional_fields ~w()a

  schema "bookmarks" do
    belongs_to :user, User
    belongs_to :post, Post

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(bookmark, attrs) do
    bookmark
    |> cast(attrs, @required_fields ++ @optional_fields)
    |> validate_required(@required_fields)
    |> unique_constraint([:user_id, :post_id], name: :unique_bookmarks)
  end
end
