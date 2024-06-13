defmodule EducatiumWeb.FileController do
  use EducatiumWeb, :controller

  alias Educatium.Resources
  alias Educatium.Uploaders.File

  def download_file(conn, %{"file_id" => file_id}) do
    file = Resources.get_file!(file_id)
    file_url= File.url({file.file, file}, :original) |> IO.inspect(label: "URL")

    conn
    |> put_resp_header("content-disposition", "attachment; filename=\"#{file.name}\"")
    |> send_download({:file, file_url})
  end
end
