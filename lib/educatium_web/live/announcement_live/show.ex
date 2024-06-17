defmodule EducatiumWeb.AnnouncementLive.Show do
  use EducatiumWeb, :live_view

  alias Educatium.Feed

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    announcement = Feed.get_announcement!(id, [:user])
    is_owner = announcement.user_id == socket.assigns.current_user.id

    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action, announcement.title))
     |> assign(:announcement, announcement)
     |> assign(:is_owner, is_owner)}
  end

  defp page_title(:show, announcement_name), do: announcement_name

  defp page_title(:edit, announcement_name),
    do: gettext("Editing %{title}", title: announcement_name)
end
