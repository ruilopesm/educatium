defmodule Educatium.Feed.Announcement do
  use Educatium, :schema

  alias Educatium.Accounts.User
  alias Educatium.Feed.Post

  @required_fields ~w(title body user_id)a
  @optional_fields ~w()a

  schema "announcements" do
    field :title, :string
    field :body, :string

    belongs_to :user, User
    belongs_to :post, Post

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(announcement, attrs) do
    announcement
    |> cast(attrs, @required_fields ++ @optional_fields)
    |> validate_required(@required_fields)
  end
end
