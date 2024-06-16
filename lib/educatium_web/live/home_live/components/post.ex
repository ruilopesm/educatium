defmodule EducatiumWeb.HomeLive.Components.Post do
  use EducatiumWeb, :live_component

  alias Educatium.Feed
  alias Educatium.Feed.Post
  alias Educatium.Resources
  alias Educatium.Uploaders.Avatar

  attr :post, Post, required: true

  @impl true
  def render(assigns) do
    tags = Resources.list_tags_by_resource(assigns[:post].resource.id)
    assigns = Map.put(assigns, :tags, tags)

    ~H"""
    <div id="wrapper" class="relative">
      <%= if @post.type == :resource do %>
        <%= render_resource(assigns) %>
      <% end %>
    </div>
    """
  end

  defp render_resource(assigns) do
    ~H"""
    <.link
      href={~p"/resources/#{@post.resource.id}"}
      class="block w-full rounded-lg border border-gray-200 bg-white px-6 py-4 shadow hover:bg-gray-50"
    >
      <div class="flex gap-3">
        <%= if @post.resource.user.avatar do %>
          <.avatar
            class="!size-10"
            src={Avatar.url({@post.resource.user.avatar, @post.resource.user}, :original)}
            fallback={extract_initials(@post.resource.user.first_name, @post.resource.user.last_name)}
          />
        <% else %>
          <.avatar
            class="!size-10"
            fallback={extract_initials(@post.resource.user.first_name, @post.resource.user.last_name)}
          />
        <% end %>

        <div class="grid gap-3">
          <div class="grid gap-0.5">
            <h2 class="text-sm font-medium leading-snug text-gray-900">
              <%= display_name(@post.resource.user) %>
              <span class="text-gray-500"><%= gettext("added a new resource") %></span>
            </h2>
            <h3 class="text-xs font-normal leading-4 text-gray-500">
              <%= display_atom(@post.resource.user.role) %> | <%= relative_datetime(
                @post.resource.inserted_at
              ) %>
            </h3>
          </div>
          <div class="flex gap-1">
            <span class="rounded-full bg-gray-100 px-2.5 py-1 text-center text-xs font-medium leading-4 text-gray-600">
              <%= capitalize_atom(@post.resource.type) %>
            </span>

            <%= for tag <- Enum.take(@tags, 2) do %>
              <span class={"bg-#{tag.color}-50 text-#{tag.color}-600 rounded-full px-2.5 py-1 text-center text-xs font-medium leading-4"}>
                <%= tag.name %>
              </span>
            <% end %>

            <%= if length(@tags) > 2 do %>
              <span class="rounded-full bg-gray-100 px-2.5 py-1 text-center text-xs font-medium leading-4 text-gray-700">
                +<%= length(@tags) - 2 %>
              </span>
            <% end %>
          </div>
        </div>
      </div>

      <div class="mt-3.5 mb-7">
        <h3 class="text-lg font-medium leading-snug text-gray-900"><%= @post.resource.title %></h3>
        <p class="text-xs font-normal leading-4 text-gray-500"><%= @post.resource.description %></p>
      </div>
    </.link>
    <div class="group right-[22px] absolute top-3 flex items-end gap-1 text-gray-500 hover:cursor-help">
      <p class="text-xs font-normal leading-4"><%= @post.view_count %></p>
      <div class="relative">
        <.icon name="hero-bars-3-bottom-right" class="size-4 rotate-90" />
        <div class="absolute bottom-full hidden whitespace-nowrap rounded bg-gray-700 px-2 py-1 text-xs text-white group-hover:block">
          <%= ngettext("%{count} view", "%{count} views", @post.view_count) %>
        </div>
      </div>
    </div>
    <div class="left-[22px] absolute bottom-3 mt-6 flex gap-3">
      <button
        phx-click="upvote"
        phx-target={@myself}
        class={[
          "flex gap-1 items-center text-xs font-medium leading-4 text-gray-600 hover:text-green-500",
          current_user_upvoted?(@post, @current_user) && "text-green-500 hover:text-green-800"
        ]}
      >
        <.icon name="hero-chevron-up" class="size-5" />
        <span><%= @post.upvote_count %></span>
      </button>

      <button
        phx-click="downvote"
        phx-target={@myself}
        class={[
          "flex gap-1 items-center text-xs font-medium leading-4 text-gray-600 hover:text-red-500",
          current_user_downvoted?(@post, @current_user) && "text-red-500 hover:text-red-800"
        ]}
      >
        <.icon name="hero-chevron-down" class="size-5" />
        <span><%= @post.downvote_count %></span>
      </button>

      <button
        phx-click="show-comments"
        phx-target={@myself}
        class="flex items-center gap-1 text-xs font-medium leading-4 text-gray-600 hover:text-amber-800"
      >
        <.icon name="hero-chat-bubble-oval-left" class="size-5" />
        <span><%= @post.comment_count %></span>
      </button>

    </div>
    <div class="right-[22px] absolute bottom-3 mt-6 flex gap-3">
      <button
        phx-click="bookmark"
        phx-target={@myself}
        class="flex items-center gap-1 text-xs font-medium leading-4 text-gray-600 hover:text-amber-800"
      >
        <%= if current_user_bookmarked?(@post, @current_user) do %>
          <.icon name="hero-bookmark-solid" class="size-5 text-black" />
        <% else %>
          <.icon name="hero-bookmark" class="size-5" />
        <% end %>
      </button>
    </div>
    """
  end

  @impl true
  def handle_event("upvote", _, socket) do
    user = socket.assigns.current_user
    post = socket.assigns.post

    if current_user_downvoted?(post, user) do
      invert_vote(socket, post, user, type: :upvote)
    else
      upvote_post(socket, post, user)
    end
  end

  @impl true
  def handle_event("downvote", _, socket) do
    user = socket.assigns.current_user
    post = socket.assigns.post

    if current_user_upvoted?(post, user) do
      invert_vote(socket, post, user, type: :downvote)
    else
      downvote_post(socket, post, user)
    end
  end

  @impl true
  def handle_event("show-comments", _, socket) do
    {:noreply, socket |> push_redirect(to: ~p"/posts/#{socket.assigns.post.id}/comments")}
  end

  @impl true
  def handle_event("bookmark", _, socket) do
    user = socket.assigns.current_user
    post = socket.assigns.post

    if current_user_bookmarked?(post, user) do
      delete_bookmark(socket, post.resource, user)
    else
      bookmark_post(socket, post.resource, user)
    end
  end

  defp delete_bookmark(socket, resource, user) do
    Resources.delete_bookmark!(resource, user)
    updated_post = Feed.get_post!(socket.assigns.post.id, Post.preloads())
    notify_parent({:info, gettext("Bookmark from resource has been removed")})
    {:noreply, assign(socket, post: updated_post)}
  end

  defp bookmark_post(socket, resource, user) do
    Resources.bookmark_resource!(resource, user)
    updated_post = Feed.get_post!(socket.assigns.post.id, Post.preloads())

    notify_parent(
      {:info,
       gettext("Bookmark has been added to resource. Check your bookmarks under your profile!")}
    )

    {:noreply, assign(socket, post: updated_post)}
  end

  defp upvote_post(socket, post, user) do
    if current_user_upvoted?(post, user) do
      updated_post = Feed.delete_upvote!(post, user)
      {:noreply, assign(socket, post: updated_post)}
    else
      updated_post = Feed.upvote_post!(post, user)
      {:noreply, assign(socket, post: updated_post)}
    end
  end

  defp downvote_post(socket, post, user) do
    if current_user_downvoted?(post, user) do
      updated_post = Feed.delete_downvote!(post, user)
      {:noreply, assign(socket, post: updated_post)}
    else
      updated_post = Feed.downvote_post!(post, user)
      {:noreply, assign(socket, post: updated_post)}
    end
  end

  defp invert_vote(socket, post, user, type: type) when type in [:upvote, :downvote] do
    updated_post = Feed.invert_vote!(post, user, type: type)
    {:noreply, assign(socket, post: updated_post)}
  end

  defp current_user_upvoted?(post, user) do
    post.upvotes
    |> Enum.any?(&(&1.user_id == user.id))
  end

  defp current_user_downvoted?(post, user) do
    post.downvotes
    |> Enum.any?(&(&1.user_id == user.id))
  end

  defp current_user_bookmarked?(post, user) do
    post.resource.bookmarks
    |> Enum.any?(&(&1.user_id == user.id))
  end
end
