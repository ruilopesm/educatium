defmodule EducatiumWeb.HomeLive.Index do
  use EducatiumWeb, :live_view

  alias Educatium.Feed
  alias Educatium.Feed.Post
  alias Educatium.Resources.Resource
  alias EducatiumWeb.HomeLive.Components
  alias EducatiumWeb.HomeLive.FormComponent

  import EducatiumWeb.HomeLive.Components.Dropdown

  @preloads Post.preloads()

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket), do: Feed.subscribe()

    filters = build_filters()
    sorts = build_sorts()

    {:ok,
     socket
     |> assign(:page_title, gettext("Home"))
     |> stream(:posts, Feed.list_posts(preloads: @preloads))
     |> assign(:form, to_form(%{}, as: "post"))
     |> assign(:new_posts_count, 0)
     |> assign(:filters, filters)
     |> assign(:current_filter, Enum.at(filters, 0))
     |> assign(:sorts, sorts)
     |> assign(:current_sort, Enum.at(sorts, 0))}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :new, _params) do
    assign(socket, :page_title, gettext("New post"))
  end

  defp apply_action(socket, :index, _params), do: socket

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
     |> stream(:posts, Feed.list_posts(preloads: @preloads, order_by: [desc: :inserted_at]),
       reset: true
     )}
  end

  @impl true
  def handle_event("search", %{"post" => post}, socket) do
    {:noreply,
     socket
     |> stream(
       :posts,
       Feed.search_posts(post, preloads: @preloads, order_by: [desc: :inserted_at]),
       reset: true
     )}
  end

  @impl true
  def handle_event("show-new-posts", _, socket) do
    {:noreply,
     socket
     |> assign(:new_posts_count, 0)
     |> stream(:posts, Feed.list_posts(preloads: @preloads, order_by: [desc: :inserted_at]),
       reset: true
     )}
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
  def handle_event("entry-changed", %{"entry" => entry, "name" => name}, socket) do
    entry = String.to_existing_atom(entry)

    case name do
      "filter" -> handle_filter_change(entry, socket)
      "sort" -> handle_sort_change(entry, socket)
    end
  end

  defp handle_filter_change(:nothing, socket) do
    {:noreply,
     socket
     |> stream(:posts, Feed.list_posts(preloads: @preloads, order_by: [desc: :inserted_at]),
       reset: true
     )
     |> assign(:current_filter, Enum.at(socket.assigns.filters, 0))}
  end

  defp handle_filter_change(filter, socket) do
    {:noreply,
     socket
     |> stream(
       :posts,
       Feed.filter_posts(filter, preloads: @preloads, order_by: [desc: :inserted_at]),
       reset: true
     )
     |> assign(:current_filter, find_by_value(socket.assigns.filters, filter))}
  end

  defp handle_sort_change(:newest, socket) do
    {:noreply,
     socket
     |> stream(:posts, Feed.list_posts(preloads: @preloads, order_by: [desc: :inserted_at]),
       reset: true
     )
     |> assign(:current_sort, Enum.at(socket.assigns.sorts, 0))}
  end

  defp handle_sort_change(:oldest, socket) do
    {:noreply,
     socket
     |> stream(:posts, Feed.list_posts(preloads: @preloads, order_by: [asc: :inserted_at]),
       reset: true
     )
     |> assign(:current_sort, Enum.at(socket.assigns.sorts, 1))}
  end

  defp handle_sort_change(:most_viewed, socket) do
    {:noreply,
     socket
     |> stream(:posts, Feed.list_posts(preloads: @preloads, order_by: [desc: :view_count]),
       reset: true
     )
     |> assign(:current_sort, Enum.at(socket.assigns.sorts, 2))}
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

  defp build_filters do
    types = Resource.types()

    [%{label: gettext("Nothing"), value: :nothing}] ++
      Enum.map(types, fn type ->
        %{label: capitalize_atom(type), value: type}
      end)
  end

  defp build_sorts do
    [
      %{label: gettext("Newest"), value: :newest},
      %{label: gettext("Oldest"), value: :oldest},
      %{label: gettext("Most viewed"), value: :most_viewed}
    ]
  end

  defp find_by_value(list, value) do
    value = for item <- list, item.value == value, do: item
    List.first(value)
  end
end
