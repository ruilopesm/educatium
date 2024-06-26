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
    resource = Resources.get_resource!(id, [:directory, :user, :tags, :bookmarks])
    tags = Resources.list_tags_by_resource(resource.id)
    directory = maybe_get_directory!(resource.directory)

    is_owner = resource.user_id == socket.assigns.current_user.id

    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action, resource.title))
     |> assign(:resource, resource)
     |> assign(:tags, tags)
     |> assign(:directory, directory)
     |> assign(:is_owner, is_owner)}
  end

  @impl true
  def handle_event("bookmark", _, socket) do
    user = socket.assigns.current_user
    bookmark_post(socket, socket.assigns.resource, user)
  end

  @impl true
  def handle_event("delete-bookmark", _, socket) do
    user = socket.assigns.current_user
    Resources.delete_bookmark!(socket.assigns.resource, user)

    {:noreply,
     socket
     |> put_flash(:info, gettext("Bookmark from resource has been removed"))
     |> push_patch(to: ~p"/resources/#{socket.assigns.resource.id}")}
  end

  @impl true
  def handle_event("load-directory", %{"dir_id" => dir_id}, socket) do
    directory = Resources.get_directory!(dir_id, [:files, :subdirectories])
    {:noreply, assign(socket, directory: directory)}
  end

  defp bookmark_post(socket, resource, user) do
    Resources.bookmark_resource!(resource, user)

    {:noreply,
     socket
     |> put_flash(
       :info,
       gettext("Bookmark has been added to resource. Check your bookmarks under your profile!")
     )
     |> push_patch(to: ~p"/resources/#{resource}")}
  end

  defp current_user_bookmarked?(resource, user) do
    resource.bookmarks
    |> Enum.any?(&(&1.user_id == user.id))
  end

  defp maybe_get_directory!(nil), do: nil

  defp maybe_get_directory!(directory),
    do: Resources.get_directory!(directory.id, [:files, :subdirectories])

  defp page_title(:show, resource_name), do: resource_name
  defp page_title(:edit, resource_name), do: gettext("Editing %{title}", title: resource_name)
end
