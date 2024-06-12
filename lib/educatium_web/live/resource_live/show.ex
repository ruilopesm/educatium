defmodule EducatiumWeb.ResourceLive.Show do
  use EducatiumWeb, :live_view

  alias Educatium.Resources

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
  def handle_event("download-resource", _, socket) do
    IO.puts("download-resource")
    {:noreply, socket}
  end

  @impl true
  def handle_event("load-prev-directory", %{"dir_id" => dir_id}, socket) do
    directory = Resources.get_directory!(dir_id, [:files, :subdirectories])

    {:noreply, assign(socket, directory: directory)}
  end

  defp page_title(:show), do: "Show Resource"
  defp page_title(:edit), do: "Edit Resource"
end
