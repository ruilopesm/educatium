defmodule Educatium.Feed.Downvote do
  use Educatium, :schema

  alias Educatium.Accounts.User
  alias Educatium.Feed.Post

  @required_fields ~w(user_id post_id)a
  @optional_fields ~w()a

  schema "downvotes" do
    belongs_to :user, User
    belongs_to :post, Post

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(downvote, attrs) do
    downvote
    |> cast(attrs, @required_fields ++ @optional_fields)
    |> validate_required(@required_fields)
    |> unique_constraint([:user_id, :post_id], name: :unique_downvotes)
    |> prepare_changes(&increment_post_downvotes/1)
  end

  defp increment_post_downvotes(changeset) do
    if post_id = get_change(changeset, :post_id) do
      query = from Post, where: [id: ^post_id]
      changeset.repo.update_all(query, inc: [downvotes_count: 1])
    end

    changeset
  end
end
