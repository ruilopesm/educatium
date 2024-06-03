defmodule EducatiumWeb.HomeLive.Components.Post do
  use EducatiumWeb, :live_component

  alias Educatium.Feed
  alias Educatium.Feed.Post

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
        <img src="https://i.pravatar.cc/300" alt="Hailey image" class="w-12 h-12 rounded-full" />
        <div class="grid gap-3">
          <div class="grid gap-0.5">
            <h2 class="text-gray-900 text-sm font-medium leading-snug">
              Rui Lopes <span class="text-gray-500">adicionou um novo recurso</span>
            </h2>
            <h3 class="text-gray-500 text-xs font-normal leading-4">
              Estudante | Qui, 10h03m
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
    <div class="flex gap-3 mt-6 absolute left-[22px] bottom-3">
      <object>
        <button
          phx-click="upvote"
          phx-target={@myself}
          class="flex gap-1 items-center text-gray-600 text-xs font-medium leading-4 hover:text-green-500"
        >
          <.icon name="hero-chevron-up" class="size-5" />
          <span><%= @post.upvotes_count %></span>
        </button>
      </object>
      <object>
        <button
          phx-click="downvote"
          phx-target={@myself}
          class="flex gap-1 items-center text-gray-600 text-xs font-medium leading-4 hover:text-red-500"
        >
          <.icon name="hero-chevron-down" class="size-5" />
          <span><%= @post.downvotes_count %></span>
        </button>
      </object>
      <object>
        <.link
          href={~p"/resources/#{@post.resource.id}"}
          class="flex gap-1 items-center text-gray-600 text-xs font-medium leading-4 hover:text-yellow-500"
        >
          <.icon name="hero-chat-bubble-oval-left" class="size-5" />
          <span>7</span>
        </.link>
      </object>
    </div>
    """
  end

  # FIXME: Should be current_user
  alias Educatium.Repo
  alias Educatium.Accounts.User

  @impl true
  def handle_event("upvote", _, socket) do
    user = hd(Repo.all(User))
    post = socket.assigns.post
    updated_post = Feed.upvote_post!(post, user)

    {:noreply, assign(socket, post: updated_post)}
  end

  @impl true
  def handle_event("downvote", _, socket) do
    user = hd(Repo.all(User))
    post = socket.assigns.post
    updated_post = Feed.downvote_post!(post, user)

    {:noreply, assign(socket, post: updated_post)}
  end

  # TODO: Complete after current_user (or maybe let not logged in users see resources?)
  defp current_user_upvoted?(post, user) do
    post.upvotes
    |> Enum.any?(&(&1.user_id == user.id))
  end

  defp current_user_downvoted?(post, user) do
    post.downvotes
    |> Enum.any?(&(&1.user_id == user.id))
  end
end
