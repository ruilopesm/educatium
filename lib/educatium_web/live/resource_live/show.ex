defmodule EducatiumWeb.ResourceLive.Show do
  use EducatiumWeb, :live_view

  alias EducatiumWeb.Utils

  alias Educatium.Resources
  alias Educatium.Resources.{Directory, File, Resource}
  alias Educatium.Uploaders.File

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    resource = Resources.get_resource!(id, [:directory])

    directory =
      if resource != nil,
        do: Resources.get_directory!(resource.directory.id, [:files, :subdirectories]),
        else: nil

    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:resource, resource)
     |> assign(:directory, directory)}
  end

  @impl true
  def handle_event("load-directory", %{"dir_id" => dir_id}, socket) do
    directory = Resources.get_directory!(dir_id, [:files, :subdirectories])
    {:noreply, assign(socket, directory: directory)}
  end

  @impl true
  def handle_event("load-prev-directory", %{"dir_id" => dir_id}, socket) do
    directory = Resources.get_directory!(dir_id, [:files, :subdirectories])
    {:noreply, assign(socket, directory: directory)}
  end

  defp file_size(size) do
    mb =
      (size / 1024 / 1024)
      |> Float.round(2)

    if mb < 0.1 do
      bytes =
        (size / 1024)
        |> Float.round(2)

      "#{bytes} bytes"
    else
      "#{mb} MB"
    end
  end

  defp get_file_path(file_id) do
    file = Resources.get_file!(file_id)
    File.url({file.file, file}, :original)
  end

  defp directory_n_items(directory_id) do
    directory = Resources.get_directory!(directory_id, [:files, :subdirectories])
    n_items = Enum.count(directory.files) + Enum.count(directory.subdirectories)

    if n_items == 1, do: "#{n_items} item", else: "#{n_items} items"
  end


  defp page_title(:show), do: "Show Resource"
  defp page_title(:edit), do: "Edit Resource"
end
