defmodule EducatiumWeb.DirectoryController do
  use EducatiumWeb, :controller

  alias Educatium.Resources

  def download_directory(conn, %{"id" => directory_id}) do
    zip_file_path = 
      Resources.get_directory!(directory_id, [:files, :subdirectories])
      |> Resources.build_zip()
      |> IO.inspect()

    conn
    |> send_download(zip_file_path)
  end
end
