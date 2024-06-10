defmodule EducatiumWeb.ResourceLive.Show do
  use EducatiumWeb, :live_view

  alias Educatium.Resources
  alias Educatium.Feed
  alias Educatium.Feed.Comment

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    {:noreply,
     socket
     |> stream(:comments, Feed.list_comments(id,preloads: Comment.preloads()))
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:resource, Resources.get_resource!(id))}
  end

  @impl true
  def handle_event("post_comment",%{"comment" => comment_params}, socket) do
    comment_params = add_user_id(socket,comment_params)
    IO.inspect(comment_params)
    case Feed.create_comment(comment_params) do
      {:ok, comment} ->
        {:noreply,
         socket
         |> push_event("comment_created", comment)
         |> assign(:comment, %{})}
      {:error, _changeset} ->
        {:noreply, socket}
    end
  end

  defp add_user_id(socket,resource_params) do
    Map.put(resource_params, "user_id", socket.assigns.current_user.id)
  end

  defp page_title(:show), do: "Show Resource"
  defp page_title(:edit), do: "Edit Resource"
end
