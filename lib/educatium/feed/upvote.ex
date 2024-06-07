defmodule Educatium.Feed.Upvote do
  use Educatium, :schema

  alias Educatium.Accounts.User
  alias Educatium.Feed.Post

  @required_fields ~w(user_id post_id)a
  @optional_fields ~w()a

  schema "upvotes" do
    belongs_to :user, User
    belongs_to :post, Post

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(upvote, attrs) do
    upvote
    |> cast(attrs, @required_fields ++ @optional_fields)
    |> validate_required(@required_fields)
    |> unique_constraint([:user_id, :post_id], name: :unique_upvotes)
    |> prepare_changes(&increment_post_upvotes/1)
  end

  defp increment_post_upvotes(changeset) do
    if post_id = get_change(changeset, :post_id) do
      query = from Post, where: [id: ^post_id]
      changeset.repo.update_all(query, inc: [upvote_count: 1])
    end

    changeset
  end
end
