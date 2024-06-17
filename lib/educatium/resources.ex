defmodule Educatium.Resources do
  @moduledoc """
  The Resources context.
  """
  use Educatium, :context

  alias Educatium.Feed
  alias Educatium.Feed.Post
  alias Educatium.Resources.{Bookmark, Directory, File, Resource, ResourceTag, Tag}
  alias Educatium.Utils.FileManager

  @doc """
  Returns the list of resources.

  ## Examples

      iex> list_resources()
      [%Resource{}, ...]

  """
  def list_resources(opts \\ []) do
    Resource
    |> apply_filters(opts)
    |> Repo.all()
  end

  def list_resources_which_user_can_see(user_id, opts \\ []) do
    # if owner id is user id, can see private posts, otherwise only public posts
    Resource
    |> where([r], r.user_id == ^user_id or r.visibility == :public)
    |> apply_filters(opts)
    |> Repo.all()
  end

  def can_see_resource(user_id, resource) do
    resource.user_id == user_id or resource.visibility == :public
  end

  @doc """
  Returns the list of resources by user.

  ## Examples

      iex> list_resources_by_user(123)
      [%Resource{}, ...]

  """
  def list_resources_by_user(user_id, opts \\ []) do
    Resource
    |> where(user_id: ^user_id)
    |> apply_filters(opts)
    |> Repo.all()
  end

  @doc """
  Returns the list of resources bookmarked by user.

  ## Examples

      iex> list_bookmarked_resources_by_user(123)
      [%Resource{}, ...]

  """
  def list_bookmarked_resources_by_user(user_id) do
    Resource
    |> join(:inner, [r], b in Bookmark, on: b.resource_id == r.id)
    |> where([r, b], b.user_id == ^user_id)
    |> Repo.all()
  end

  @doc """
  Gets a single resource.

  Raises `Ecto.NoResultsError` if the Resource does not exist.

  ## Examples

      iex> get_resource!(123, [:directory])
      %Resource{}

      iex> get_resource!(456, [:directory])
      ** (Ecto.NoResultsError)

  """
  def get_resource!(id, preloads \\ []) do
    Repo.get!(Resource, id)
    |> Repo.preload(preloads)
  end

  @doc """
  Creates a resource.

  ## Examples

      iex> create_resource(%{field: value}, ...)
      {:ok, %Resource{}}

      iex> create_resource(%{field: bad_value}, ...)
      {:error, %Ecto.Changeset{}}

  """
  def create_resource(attrs, path \\ nil)

  def create_resource(%{"visibility" => "public"} = attrs, path) do
    IO.puts("Creating public resource")
    create_resource_with_post(attrs, path)
  end

  def create_resource(%{"visibility" => _} = attrs, path) do
    create_resource_without_post(attrs, path)
  end

  defp create_resource_with_post(attrs, path) do
    Multi.new()
    |> Multi.insert(:post, fn _ ->
      %Post{}
      |> Post.changeset(%{type: :resource})
    end)
    |> Multi.insert(:resource, fn %{post: post} ->
      %Resource{}
      |> Resource.changeset(attrs)
      |> Ecto.Changeset.put_assoc(:post, post)
    end)
    |> Multi.run(:files, fn _repo, %{resource: resource} ->
      if path do
        FileManager.process_resource_item(resource, nil, :dir, path)
      else
        {:ok, :no_files}
      end
    end)
    |> Repo.transaction()
    |> case do
      {:ok, %{resource: resource, post: post}} ->
        final_post = Feed.get_post!(post.id, Post.preloads())
        broadcast({1, final_post}, :post_created)
        {:ok, resource}

      error ->
        error
    end
  end

  defp create_resource_without_post(attrs, path) do
    Multi.new()
    |> Multi.insert(:resource, fn _ ->
      %Resource{}
      |> Resource.changeset(attrs)
    end)
    |> Multi.run(:files, fn _repo, %{resource: resource} ->
      if path do
        FileManager.process_resource_item(resource, nil, :dir, path)
      else
        {:ok, :no_files}
      end
    end)
    |> Repo.transaction()
  end

  @doc """
  Creates mulitple resources from a directory with a JSON manifest file.

  ## Examples

      iex> create_resources(user, path)
      {:ok, :resources_created}

      iex> create_resources(user, path)
      {:error, error}
  """
  def create_resources(user, path) do
    FileManager.process_resources(user.id, path)
  end

  @doc """
  Updates a resource.

  ## Examples

      iex> update_resource(resource, %{field: new_value}, ...)
      {:ok, %Resource{}}

      iex> update_resource(resource, %{field: bad_value}, ...)
      {:error, %Ecto.Changeset{}}

  """
  def update_resource(%Resource{} = resource, attrs, path \\ nil) do
    Multi.new()
    |> Multi.update(:resource, Resource.changeset(resource, attrs))
    |> Multi.run(:files, fn _repo, %{resource: resource} ->
      if path do
        FileManager.process_resource_item(resource, nil, :dir, path)
      else
        {:ok, :no_files}
      end
    end)
    |> Repo.transaction()
  end

  @doc """
  Deletes a resource.

  ## Examples

      iex> delete_resource(resource)
      {:ok, %Resource{}}

      iex> delete_resource(resource)
      {:error, %Ecto.Changeset{}}

  """
  def delete_resource(%Resource{} = resource) do
    Repo.delete(resource)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking resource changes.

  ## Examples

      iex> change_resource(resource)
      %Ecto.Changeset{data: %Resource{}}

  """
  def change_resource(%Resource{} = resource, attrs \\ %{}) do
    Resource.changeset(resource, attrs)
  end

  @doc """
  Creates a directory.

  ## Examples

      iex> create_directory(%{field: value})
      {:ok, %Directory{}}

      iex> create_directory(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_directory(attrs) do
    %Directory{}
    |> Directory.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Gets a single directory.

  Raises `Ecto.NoResultsError` if the Directory does not exist.

  ## Examples

      iex> get_directory!(123)
      %Directory{}

      iex> get_directory!(456)
      ** (Ecto.NoResultsError)

  """
  def get_directory!(id, preloads \\ []) do
    Repo.get!(Directory, id)
    |> Repo.preload(preloads)
  end

  @doc """
  Creates a file.

  ## Examples

      iex> create_file(%{field: value})
      {:ok, %File{}}

      iex> create_file(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_file(attrs) do
    %File{}
    |> File.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Returns the list of tags.

  ## Examples

      iex> list_tags()
      [%Tag{}, ...]

  """
  def list_tags do
    Tag
    |> Repo.all()
  end

  @doc """
  Returns the list of tags by ids.

  ## Examples

      iex> list_tags_by_ids([1, 2, 3])
      [%Tag{}, ...]
  """
  def list_tags_by_ids(ids) do
    Tag
    |> where([t], t.id in ^ids)
    |> Repo.all()
  end

  @doc """
  Gets a single tag.

  Raises `Ecto.NoResultsError` if the Tag does not exist.

  ## Examples

      iex> get_tag!(123)
      %Tag{}

      iex> get_tag!(456)
      ** (Ecto.NoResultsError)

  """
  def get_tag!(id) do
    Repo.get!(Tag, id)
  end

  @doc """
  Creates a tag.

  ## Examples

      iex> create_tag(%{field: value})
      {:ok, %Tag{}}

      iex> create_tag(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_tag(attrs) do
    %Tag{}
    |> Tag.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking tag changes.

  ## Examples

      iex> change_tag(tag)
      %Ecto.Changeset{data: %Tag{}}

  """
  def change_tag(%Tag{} = tag, attrs \\ %{}) do
    Tag.changeset(tag, attrs)
  end

  @doc """
  Updates a tag.

   ## Examples

       iex> update_tag(tag, %{field: new_value})
       {:ok, %Tag{}}

       iex> update_tag(tag, %{field: bad_value})
       {:error, %Ecto.Changeset{}}

  """
  def update_tag(%Tag{} = tag, attrs \\ %{}) do
    tag
    |> Tag.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a tag.

  ## Examples

      iex> delete_tag(tag)
      {:ok, %Tag{}}

      iex> delete_tag(tag)
      {:error, %Ecto.Changeset{}}

  """
  def delete_tag(%Tag{} = tag) do
    Repo.delete(tag)
  end

  @doc """
  Lists all tags for a resource.
  """
  def list_tags_by_resource(resource_id) do
    Tag
    |> join(:inner, [t], rt in ResourceTag, on: rt.tag_id == t.id)
    |> where([t, rt], rt.resource_id == ^resource_id)
    |> Repo.all()
  end

  @doc """
  Creates a relationship between a resource and a tag.

  ## Examples

      iex> create_resource_tag(resource_id, tag_id)
      {:ok, %ResourceTag{}}

      iex> create_resource_tag(resource_id, tag_id)
      {:error, %Ecto.Changeset{}}

  """
  def create_resource_tag(resource_id, tag_id) do
    %ResourceTag{}
    |> ResourceTag.changeset(%{resource_id: resource_id, tag_id: tag_id})
    |> Repo.insert()
  end

  @doc """
  Gets a single file.

  Raises `Ecto.NoResultsError` if the File does not exist.

  ## Examples

      iex> get_file!(123)
      %File{}

      iex> get_file!(456)
      ** (Ecto.NoResultsError)

  """
  def get_file!(id) do
    Repo.get!(File, id)
  end

  @topic "posts"

  defp broadcast({1, post}, event) do
    Phoenix.PubSub.broadcast(Educatium.PubSub, @topic, {event, post})
    {:ok, post}
  end

  @doc """
  Gets a bookmark for the given post and user.

  ## Examples

      iex> get_bookmark(resource, user)
      %Bookmark{}

  """
  def get_bookmark(resource, user) do
    Bookmark
    |> where([b], b.resource_id == ^resource.id and b.user_id == ^user.id)
    |> Repo.one()
  end

  @doc """
  Creates a bookmark for the given post and user.

  ## Examples

      iex> bookmark_resource(resource, user)
      %Resource{}

  """
  def bookmark_resource!(resource, user) do
    %Bookmark{}
    |> Bookmark.changeset(%{resource_id: resource.id, user_id: user.id})
    |> Repo.insert!()
  end

  @doc """
  Deletes a bookmark for the given post and user.

  ## Examples

      iex> delete_bookmark(resource, user)
      {:ok, %Resource{}}

      iex> delete_bookmark(resource, user)
      {:error, %Ecto.Changeset{}}
  """
  def delete_bookmark!(resource, user) do
    get_bookmark(resource, user)
    |> Repo.delete()
  end

  @doc """
  Lists the bookmarks for the given user.

  ## Examples

      iex> list_user_bookmarks(user)
      [%Bookmark{}, ...]

  """
  def list_user_bookmarks(user) do
    Bookmark
    |> where([b], b.user_id == ^user.id)
    |> Repo.all()
  end
end
