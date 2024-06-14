defmodule Educatium.Uploaders.File do
  use Waffle.Definition
  use Waffle.Ecto.Definition

  @versions [:original]

  # Override the storage directory:
  def storage_dir(_version, {_file, scope}) do
    "uploads/user/files/#{scope.resource_id}"
  end

  def versions, do: @versions

  # Provide a default URL if there hasn't been a file uploaded
  # def default_url(version, scope) do
  #   "/images/avatars/default_#{version}.png"
  # end
end
