defmodule EducatiumWeb.Admin.AnnouncementLive.Index do
  use EducatiumWeb, :live_view

  alias Educatium.Feed
  alias EducatiumWeb.Admin.AnnouncementLive

  @impl true
  def mount(_params, _session, socket) do
    {:ok, stream(socket, :announcements, Feed.list_announcements())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, gettext("Edit Announcement"))
    |> assign(:announcement, Feed.get_announcement!(id))
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, gettext("Listing Announcements"))
    |> assign(:announcement, nil)
  end

  @impl true
  def handle_info({AnnouncementLive.FormComponent, {:saved, announcement}}, socket) do
    {:noreply, stream_insert(socket, :announcements, announcement)}
  end
end
