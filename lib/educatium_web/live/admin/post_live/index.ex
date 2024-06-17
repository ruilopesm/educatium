defmodule EducatiumWeb.Admin.PostLive.Index do
  use EducatiumWeb, :live_view

  alias Educatium.Feed
  alias Educatium.Feed.Post
  alias EducatiumWeb.Admin.PostLive

  @impl true
  def mount(_params, _session, socket) do
    {:ok, stream(socket, :posts, Feed.list_posts(preloads: [:resource, :announcement]))}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, gettext("Edit Post"))
    |> assign(:post, Feed.get_post!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, gettext("New Post"))
    |> assign(:post, %Post{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, gettext("Listing Posts"))
    |> assign(:post, nil)
  end

  @impl true
  def handle_info({PostLive.FormComponent, {:saved, post}}, socket) do
    {:noreply, stream_insert(socket, :posts, post)}
  end
end
