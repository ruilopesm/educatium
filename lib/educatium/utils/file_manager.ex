defmodule Educatium.Utils.FileManager do
  alias Educatium.Resources
  alias Educatium.Resources.{Directory, File}

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
      dir = Resources.get_directory!(dir.id, [:files, :subdirectories])
      new_dir = "#{parent_dir}/#{dir.name}"

      file_entries = create_file_entries(dir.files, new_dir)
      dir_entries = create_directory_entries(dir.subdirectories, new_dir)

      file_entries ++ dir_entries
    end)
    |> Enum.concat()
  end

  def process_resource_item(resource, parent_directory, :dir, path) do
    parent_directory_id = if parent_directory == nil, do: nil, else: parent_directory.id
    path = Path.expand(path)

    attrs = %{
      name: Path.basename(path),
      resource_id: resource.id,
      directory_id: parent_directory_id
    }

    case Resources.create_directory(attrs) do
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

  def process_resource_item(resource, parent_directory, :file, path) do
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

    Resources.create_file(attrs)
  end

  def process_resources(user_id, path) do
    manifest =
      (path <> "/manifest.json")
      |> Elixir.File.read!()
      |> Jason.decode!()

    case validate_manifest(manifest) do
      {:ok, :valid} ->
        Enum.each(manifest, fn entry ->
          attrs = build_resource_attrs(entry, user_id)
          path = path <> "/#{Map.get(entry, "path")}"

          Resources.create_resource(attrs, path)
        end)

        {:ok, :resources_created}

      {:error, error} ->
        {:error, error}
    end
  end

  defp build_resource_attrs(entry, user_id) do
    tags =
      Resources.list_tags()
      |> Enum.filter(fn tag -> tag.name in Map.get(entry, "tags") end)
      |> Enum.map(fn tag -> tag.id end)

    entry
    |> Map.put("tags", tags)
    |> Map.put("user_id", user_id)
  end

  # def validate_manifest(manifest) when is_list(manifest) do
  #   Enum.each(manifest, fn entry ->
  #     if is_map(entry) do
  #       if Map.has_key?(entry, "title") and
  #            Map.has_key?(entry, "description") and
  #            Map.has_key?(entry, "type") and
  #            Map.has_key?(entry, "date") and
  #            Map.has_key?(entry, "visibility") and
  #            Map.has_key?(entry, "tags") and
  #            Map.has_key?(entry, "path") do
  #         :ok
  #       else
  #         {:error, "Invalid manifest entry, missing required fields"}
  #       end
  #     else
  #       {:error, "Invalid manifest format, expected a list"}
  #     end
  #   end)
  # end
  def validate_manifest(manifest) when is_list(manifest) do
    Enum.reduce_while(manifest, {:ok, :valid}, fn entry, _acc ->
      if is_map(entry) do
        required_keys = ~w(title description type date visibility tags path)

        if Enum.all?(required_keys, &Map.has_key?(entry, &1)) do
          {:cont, {:ok, :valid}}
        else
          {:halt, {:error, "Invalid manifest entry, missing required fields"}}
        end
      else
        {:halt, {:error, "Invalid manifest format, expected a list of maps"}}
      end
    end)
  end
end
