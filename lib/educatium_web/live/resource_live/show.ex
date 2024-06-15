defmodule EducatiumWeb.ResourceLive.Show do
  use EducatiumWeb, :live_view

  alias Educatium.Resources

  import EducatiumWeb.ResourceLive.Components.FileSystem

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    resource = Resources.get_resource!(id, [:directory, :user])
    tags = Resources.list_tags_by_resource(resource.id)

    directory =
      if resource.directory,
        do: Resources.get_directory!(resource.directory.id, [:files, :subdirectories]),
        else: nil

    {:noreply,
     socket
     |> assign(:resource, resource)
     |> assign(:tags, tags)
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
end
