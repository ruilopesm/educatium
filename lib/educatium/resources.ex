defmodule Educatium.Resources do
  @moduledoc """
  The Resources context.
  """
  use Educatium, :context

  alias Educatium.Feed.Post
  alias Educatium.Resources.{Directory, File, Resource}

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
  Gets a single resource.

  Raises `Ecto.NoResultsError` if the Resource does not exist.

  ## Examples

      iex> get_resource!(123)
      %Resource{}

      iex> get_resource!(456)
      ** (Ecto.NoResultsError)

  """
  def get_resource!(id), do: Repo.get!(Resource, id)

  @doc """
  Creates a resource.

  ## Examples

      iex> create_resource(%{field: value}, "/resources/resource1")
      {:ok, %Resource{}}

      iex> create_resource(%{field: bad_value}, "/resources/resource1")
      {:error, %Ecto.Changeset{}}

  """
  def create_resource(attrs, resource_path \\ nil) do
    if attrs[:visibility] == :public do
      create_resource_with_post(attrs, resource_path)
    else
      create_resource_without_post(attrs, resource_path)
    end
  end

  defp create_resource_with_post(attrs, resource_path) do
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
      if resource_path do
        process_resource_item(resource, nil, :dir, resource_path)
      else
        {:ok, :no_files}
      end
    end)
    |> Repo.transaction()
  end

  defp create_resource_without_post(attrs, resource_path) do
    Multi.new()
    |> Multi.insert(:resource, fn _ ->
      %Resource{}
      |> Resource.changeset(attrs)
    end)
    |> Multi.run(:files, fn _repo, %{resource: resource} ->
      if resource_path do
        process_resource_item(resource, nil, :dir, resource_path)
      else
        {:ok, :no_files}
      end
    end)
    |> Repo.transaction()
  end

  @doc """
  Updates a resource.

  ## Examples

      iex> update_resource(resource, %{field: new_value}, "/resources/resource1")
      {:ok, %Resource{}}

      iex> update_resource(resource, %{field: bad_value}, "/resources/resource1")
      {:error, %Ecto.Changeset{}}

  """
  def update_resource(%Resource{} = resource, attrs, resource_path) do
    Multi.new()
    |> Multi.update(:resource, resource, attrs)
    |> Multi.run(:files, fn _repo, %{resource: resource} ->
      if resource_path do
        process_resource_item(resource, nil, :dir, resource_path)
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

  defp process_resource_item(resource, parent_directory, :dir, path) do
    parent_directory_id = if parent_directory == nil, do: nil, else: parent_directory.id
    path = Path.expand(path)

    attrs = %{
      name: Path.basename(path),
      resource_id: resource.id,
      parent_directory_id: parent_directory_id
    }

    with {:ok, directory} <- create_directory(attrs) do
      for item <- Elixir.File.ls!(path) do
        # Full path to item
        item_path = Path.join(path, item)
        item_type = if Elixir.File.dir?(item_path), do: :dir, else: :file
        process_resource_item(resource, directory, item_type, item_path)
      end

      {:ok, directory}
    else
      {:error, error} -> {:error, error}
      _ -> {:error, :failed_to_create_directory}
    end
  end

  defp process_resource_item(resource, parent_directory, :file, path) do
    parent_directory_id = if parent_directory == nil, do: nil, else: parent_directory.id
    path = Path.expand(path)
    name = Path.basename(path)

    attrs = %{
      name: name,
      resource_id: resource.id,
      directory_id: parent_directory_id,
      file: %Plug.Upload{
        path: path,
        filename: name
      }
    }

    create_file(attrs)
  end
end
