defmodule EducatiumWeb.DirectoryController do
  use EducatiumWeb, :controller

  alias Educatium.Resources
  alias Educatium.Utils.FileManager

  def download_directory(conn, %{"id" => directory_id}) do
    directory = Resources.get_directory!(directory_id, [:files, :subdirectories])
    zip = FileManager.build_directory_zip(directory)

    send_download(conn, {:binary, zip}, filename: directory.name <> ".zip")
  end
end
