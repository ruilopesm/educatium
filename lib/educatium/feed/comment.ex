defmodule Educatium.Feed.Comment do
  use Educatium, :schema

  alias Educatium.Accounts.User
  alias Educatium.Feed.Post

  @required_fields ~w(user_id post_id body)a
  @optional_fields ~w()a

  schema "comments" do
    field :body, :string

    belongs_to :user, User
    belongs_to :post, Post

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(comment, attrs) do
    comment
    |> cast(attrs, @required_fields ++ @optional_fields)
    |> validate_required(@required_fields)
    |> prepare_changes(&increment_post_comments/1)
  end

  defp increment_post_comments(changeset) do
    if post_id = get_change(changeset, :post_id) do
      query = from Post, where: [id: ^post_id]
      changeset.repo.update_all(query, inc: [comment_count: 1])
    end

    changeset
  end
end
