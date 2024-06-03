defmodule EducatiumWeb.HomeLive do
  use EducatiumWeb, :live_view

  alias Educatium.Feed
  alias EducatiumWeb.HomeLive.Components

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket), do: Feed.subscribe()

    {:ok,
     socket
     |> stream(:posts, Feed.list_posts(preloads: :resource))
     |> assign(:form, to_form(%{}, as: "post"))
     # TODO: Handle new post creation (PubSub-based)
     |> assign(:new_posts_count, 0)}
  end

  @impl true
  def handle_event("search", %{"post" => ""}, socket) do
    {:noreply,
     socket
     |> stream(:posts, Feed.list_posts(preloads: :resource), reset: true)}
  end

  @impl true
  def handle_event("search", %{"post" => post}, socket) do
    {:noreply,
     socket
     |> stream(:posts, Feed.search_posts(post, preloads: :resource), reset: true)}
  end

  @impl true
  def handle_event("show-new-posts", _, socket) do
    {:noreply,
     socket
     |> assign(:new_posts_count, 0)
     |> stream(:posts, Feed.list_posts(preloads: :resource), reset: true)}
  end

  @impl true
  def handle_info({:post_updated, post}, socket) do
    {:noreply,
     socket
     |> stream_insert(:posts, post)}
  end
end
