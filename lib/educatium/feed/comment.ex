defmodule Educatium.Feed.Comment do
  use Educatium, :schema

  alias Educatium.Accounts.User
  alias Educatium.Feed.Post

  @preloads ~w(user post)a

  @required_fields ~w(body)a
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
  end

  def preloads, do: @preloads
end
