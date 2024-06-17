defmodule EducatiumWeb.AnnouncementJSON do
  alias Educatium.Feed.Announcement

  @doc """
  Renders a list of announcements.
  """
  def index(%{announcements: announcements}) do
    %{data: for(announcement <- announcements, do: data(announcement))}
  end

  @doc """
  Renders a single announcement.
  """
  def show(%{announcement: announcement}) do
    %{data: data(announcement)}
  end

  defp data(%Announcement{} = announcement) do
    %{
      id: announcement.id,
      title: announcement.title,
      body: announcement.body,
      user_id: announcement.user_id,
      post_id: announcement.post_id,
    }
  end
end
