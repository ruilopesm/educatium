defmodule EducatiumWeb.FileController do
  use EducatiumWeb, :controller

  alias Educatium.Resources
  alias Educatium.Uploaders.File

  def download_file(conn, %{"file_id" => file_id}) do
    file = Resources.get_file!(file_id)
    file_path = File.url({file.file, file}, :original)

    conn
    |> redirect(to: file_path)
  end
end
