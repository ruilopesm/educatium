defmodule EducatiumWeb.HomeLive.Components.Post do
  use EducatiumWeb, :live_component

  alias Educatium.Feed
  alias Educatium.Feed.Post
  alias Educatium.Uploaders.Avatar

  attr :post, Post, required: true

  def render(assigns) do
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
      class="block w-full px-6 py-4 bg-white border border-gray-200 rounded-lg shadow hover:bg-gray-50"
    >
      <div class="flex gap-3">
        <%= if @post.resource.user.avatar do %>
          <.avatar
            class="!size-10"
            src={Avatar.url({@post.resource.user.avatar, @post.resource.user.avatar}, :original)}
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
            <h2 class="text-gray-900 text-sm font-medium leading-snug">
              <%= display_name(@post.resource.user) %>
              <span class="text-gray-500"><%= gettext("adicionou um novo recurso") %></span>
            </h2>
            <h3 class="text-gray-500 text-xs font-normal leading-4">
              <%= display_role(@current_user.role) %> | <%= relative_datetime(
                @current_user.inserted_at
              ) %>
            </h3>
          </div>
          <div class="gap-1 flex">
            <span class="px-2.5 py-1 bg-emerald-50 rounded-full text-center text-emerald-600 text-xs font-medium leading-4">
              Teste
            </span>
            <span class="px-2.5 py-1 bg-indigo-50 rounded-full text-center text-indigo-600 text-xs font-medium leading-4">
              EngWeb
            </span>
            <span class="px-2.5 py-1 bg-gray-100 rounded-full text-center text-gray-700 text-xs font-medium leading-4">
              +2
            </span>
          </div>
        </div>
      </div>

      <div class="mt-3.5 mb-7">
        <h3 class="text-gray-900 text-lg font-medium leading-snug"><%= @post.resource.title %></h3>
        <p class="text-gray-500 text-xs font-normal leading-4"><%= @post.resource.description %></p>
      </div>
    </.link>
    <div class="group hover:cursor-help flex gap-1 absolute right-[22px] top-3 text-gray-500 items-end">
      <p class="text-xs font-normal leading-4"><%= @post.view_count %></p>
      <div class="relative">
        <.icon name="hero-bars-3-bottom-right" class="size-4 rotate-90" />
        <div class="absolute bottom-full hidden group-hover:block bg-gray-700 text-white text-xs rounded py-1 px-2 whitespace-nowrap">
          <%= dngettext("view-count", "%{count} view", "%{count} views", @post.view_count) %>
        </div>
      </div>
    </div>
    <div class="flex gap-3 mt-6 absolute left-[22px] bottom-3">
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

      <.link
        href={~p"/resources/#{@post.resource.id}"}
        class="flex gap-1 items-center text-gray-600 text-xs font-medium leading-4 hover:text-gray-800"
      >
        <.icon name="hero-chat-bubble-oval-left" class="size-5" />
        <span>7</span>
      </.link>
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
end
