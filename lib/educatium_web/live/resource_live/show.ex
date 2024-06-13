defmodule EducatiumWeb.ResourceLive.Show do
  use EducatiumWeb, :live_view

  alias Educatium.Resources
  alias Educatium.Resources.{Directory, File, Resource}
  alias EducatiumWeb.Utils

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

  @impl true
  def handle_event("download-file", %{"file_id" => file_id}, socket) do
    # TODO: Implement download file
    case Resources.get_file!(file_id) do
      %File{file: file} ->
        IO.inspect(file)
        {:noreply, socket}

      _ ->
        {:noreply, socket}
    end

    {:noreply, socket}
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

  defp page_title(:show), do: "Show Resource"
  defp page_title(:edit), do: "Edit Resource"
end
