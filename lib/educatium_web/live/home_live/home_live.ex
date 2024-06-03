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
     |> assign(:form, to_form(%{}, as: "post"))}
  end

  @impl true
  def handle_event("search", %{"post" => ""}, socket) do
    {:noreply,
     socket
     |> stream(:posts, Feed.list_posts(preloads: :resource))}
  end

  @impl true
  def handle_event("search", %{"post" => post}, socket) do
    {:noreply,
     socket
     |> stream(:posts, Feed.search_posts(post, preloads: :resource))}
  end

  @impl true
  def handle_info({:post_updated, post}, socket) do
    {:noreply,
     socket
     |> stream_insert(:posts, post)}
  end
end
