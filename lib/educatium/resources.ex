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

  @doc """
  Builds a zip file from a directory.

  ## Examples

      iex> build_directory_zip(directory)
      [{:ok, %Zstream.Entry{}}, ...]
  """
  def build_directory_zip(%Directory{} = directory) do
    dir_path = "/#{directory.name}"
    file_entries = create_file_entries(directory.files, dir_path)
    directory_entries = create_directory_entries(directory.subdirectories, dir_path)

    entries = file_entries ++ directory_entries

    entries
    |> Zstream.zip()
    |> Enum.to_list()
  end

  defp create_file_entries(files, dir) do
    Enum.map(files, fn file ->
      # FIXME: Get the host from the config
      url =
        "http://localhost:4000" <> "#{Educatium.Uploaders.File.url({file.file, file}, :original)}"

      file_path = dir <> "/#{file.name}"

      Zstream.entry(file_path, HTTPStream.get(url))
    end)
  end

  defp create_directory_entries(subdirectories, parent_dir) do
    Enum.map(subdirectories, fn dir ->
      dir = get_directory!(dir.id, [:files, :subdirectories])
      new_dir = "#{parent_dir}/#{dir.name}"

      file_entries = create_file_entries(dir.files, new_dir)
      dir_entries = create_directory_entries(dir.subdirectories, new_dir)

      file_entries ++ dir_entries
    end)
    |> Enum.concat()
  end

  defp process_resource_item(resource, parent_directory, :dir, path) do
    parent_directory_id = if parent_directory == nil, do: nil, else: parent_directory.id
    path = Path.expand(path)

    attrs = %{
      name: Path.basename(path),
      resource_id: resource.id,
      directory_id: parent_directory_id
    }

    case create_directory(attrs) do
      {:ok, directory} ->
        for item <- Elixir.File.ls!(path) do
          # Full path to item
          item_path = Path.join(path, item)
          item_type = if Elixir.File.dir?(item_path), do: :dir, else: :file
          process_resource_item(resource, directory, item_type, item_path)
        end

        {:ok, directory}

      {:error, error} ->
        {:error, error}

      _ ->
        {:error, :failed_to_create_directory}
    end
  end

  defp process_resource_item(resource, parent_directory, :file, path) do
    parent_directory_id = if parent_directory == nil, do: nil, else: parent_directory.id
    path = Path.expand(path)
    name = Path.basename(path)
    file_stats = Elixir.File.lstat!(path)

    attrs = %{
      name: name,
      resource_id: resource.id,
      directory_id: parent_directory_id,
      size: file_stats.size,
      file: %Plug.Upload{
        path: path,
        filename: name
      }
    }

    create_file(attrs)
  end
end
