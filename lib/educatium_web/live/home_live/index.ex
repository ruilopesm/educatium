defmodule EducatiumWeb.HomeLive.Index do
  use EducatiumWeb, :live_view

  alias Educatium.Feed
  alias Educatium.Feed.Post

  alias EducatiumWeb.HomeLive.Components
  alias EducatiumWeb.HomeLive.FormComponent

  @preloads Post.preloads()

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket), do: Feed.subscribe()

    {:ok,
     socket
     |> stream(:posts, Feed.list_posts(preloads: @preloads))
     |> assign(:form, to_form(%{}, as: "post"))
     |> assign(:new_posts_count, 0)}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :new, _params) do
    assign(socket, :page_title, gettext("New post"))
  end

  defp apply_action(socket, :index, _params) do
    assign(socket, :page_title, "Home")
  end

  defp apply_action(socket, :comments, %{"id" => id}) do
    post = Feed.get_post!(id, @preloads)
    comment_form = to_form(%{}, as: "comment")

    socket
    |> assign(:page_title, gettext("Comments"))
    |> assign(:post, post)
    |> assign(:comment_form, comment_form)
  end

  @impl true
  def handle_event("search", %{"post" => ""}, socket) do
    {:noreply,
     socket
     |> stream(:posts, Feed.list_posts(preloads: @preloads), reset: true)}
  end

  @impl true
  def handle_event("search", %{"post" => post}, socket) do
    {:noreply,
     socket
     |> stream(:posts, Feed.search_posts(post, preloads: @preloads), reset: true)}
  end

  @impl true
  def handle_event("show-new-posts", _, socket) do
    {:noreply,
     socket
     |> assign(:new_posts_count, 0)
     |> stream(:posts, Feed.list_posts(preloads: @preloads), reset: true)}
  end

  @impl true
  def handle_event("increment-post-views", %{"id" => id}, socket) do
    Feed.increment_post_views!(id)
    {:noreply, socket}
  end

  @impl true
  def handle_event("new-post", _, socket) do
    {:noreply,
     socket
     |> push_patch(to: ~p"/posts/new")}
  end

  @impl true
  def handle_info({:post_updated, post}, socket) do
    {:noreply,
     socket
     |> stream_insert(:posts, post)}
  end

  @impl true
  def handle_info({:post_created, post}, socket) do
    {:noreply,
     socket
     |> stream_insert(:posts, post)
     |> update(:new_posts_count, &(&1 + 1))}
  end

  @impl true
  def handle_info({:comment_created, msg}, socket) do
    {:noreply,
     socket
     |> put_flash(:info, msg)
     |> push_patch(to: ~p"/posts")}
  end

  @impl true
  def handle_info({Components.Post, {level, msg}}, socket) do
    {:noreply,
     socket
     |> put_flash(level, msg)}
  end
end
