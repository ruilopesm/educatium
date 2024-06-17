defmodule EducatiumWeb.AnnouncementController do
  use EducatiumWeb, :controller

  alias Educatium.Feed
  alias Educatium.Feed.Announcement

  action_fallback EducatiumWeb.FallbackController

  def index(conn, _params) do
    announcements = Feed.list_announcements()
    render(conn, :index, announcements: announcements)
  end

  def create(conn, %{"announcement" => announcement_params}) do
    with {:ok, %Announcement{} = announcement} <- Feed.create_announcement(announcement_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", ~p"/api/announcements/#{announcement}")
      |> render(:show, announcement: announcement)
    end
  end

  def show(conn, %{"id" => id}) do
    announcement = Feed.get_announcement!(id)
    render(conn, :show, announcement: announcement)
  end

  def update(conn, %{"id" => id, "announcement" => announcement_params}) do
    announcement = Feed.get_announcement!(id)

    with {:ok, %Announcement{} = announcement} <- Feed.update_announcement(announcement, announcement_params) do
      render(conn, :show, announcement: announcement)
    end
  end

  def delete(conn, %{"id" => id}) do
    announcement = Feed.get_announcement!(id)

    with {:ok, %Announcement{}} <- Feed.delete_announcement(announcement) do
      send_resp(conn, :no_content, "")
    end
  end
end
