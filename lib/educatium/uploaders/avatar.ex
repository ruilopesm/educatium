defmodule Educatium.Uploaders.Avatar do
  @moduledoc """
  Uploader for avatar images.
  """
  use Educatium, :uploader

  alias Educatium.Accounts.User

  @versions [:original, :medium, :thumb]
  @extensions_whitelist ~w(.jpg .jpeg .png)

  def validate({file, _}) do
    file_extension = file.file_name |> Path.extname() |> String.downcase()

    case Enum.member?(@extensions_whitelist, file_extension) do
      true -> :ok
      false -> {:error, gettext("invalid file type")}
    end
  end

  def storage_dir(_version, {_file, %User{} = scope}) do
    "uploads/user/avatars/#{scope.id}"
  end

  def transform(:thumb, _) do
    {:convert, "-strip -thumbnail 100x150^ -gravity center -extent 100x150 -format png", :png}
  end

  def transform(:medium, _) do
    {:convert, "-strip -thumbnail 400x600^ -gravity center -extent 400x600 -format png", :png}
  end

  def filename(version, _), do: version

  def versions, do: @versions
  def extensions_whitelist, do: @extensions_whitelist
end
