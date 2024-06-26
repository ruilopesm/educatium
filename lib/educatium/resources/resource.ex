defmodule Educatium.Resources.Resource do
  use Educatium, :schema

  alias Educatium.Accounts.User
  alias Educatium.Feed.Post
  alias Educatium.Resources
  alias Educatium.Resources.{Bookmark, Directory, ResourceTag, Tag}

  @types ~w(book article notes code application worksheet presentation quiz project report exam assignment thesis homework solution)a
  @visibilities ~w(private public)a

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

    has_one :directory, Directory

    has_many :bookmarks, Bookmark

    many_to_many :tags, Tag, join_through: ResourceTag

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(resource, attrs) do
    resource
    |> cast(attrs, @required_fields ++ @optional_fields)
    |> validate_required(@required_fields)
    |> maybe_put_tags(attrs)
  end

  defp maybe_put_tags(changeset, attrs) do
    if attrs["tags"] do
      tags = Resources.list_tags_by_ids(attrs["tags"])
      Ecto.Changeset.put_assoc(changeset, :tags, tags)
    else
      changeset
    end
  end

  def types, do: @types
  def visibilities, do: @visibilities
end
