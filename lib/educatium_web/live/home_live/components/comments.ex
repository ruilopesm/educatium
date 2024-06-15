defmodule EducatiumWeb.HomeLive.Components.Comments do
  @moduledoc false
  use EducatiumWeb, :live_component

  alias Educatium.Feed
  alias Educatium.Uploaders.Avatar

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        <%= @title %>
          <:subtitle><%= gettext("Showing a total of %{count} comments", count: @post.comment_count) %></:subtitle>
      </.header>

      <.button phx-click="comment" phx-target={@myself} class="mt-2 h-10">
        <%= gettext("Add a comment") %>
      </.button>

      <ul class="mt-10 mb-8 flex flex-col space-y-8">
        <%= for {comment, index} <- Enum.with_index(@post.comments) do %>
          <article class="rounded-lg bg-white text-sm">
            <footer class="mb-2 flex items-center justify-between">
              <div class="flex items-center">
                <p class="mr-2 inline-flex items-center text-sm font-semibold text-gray-900">
                  <.avatar
                    class="mr-2"
                    size={:sm}
                    src={Avatar.url({comment.user.avatar, comment.user}, :original)}
                    fallback={extract_initials(comment.user.first_name, comment.user.last_name)}
                  />
                  <%= display_name(comment.user) %>
                </p>
                <p class="text-sm text-gray-600">
                  <%= relative_datetime(comment.inserted_at) %>
                </p>
              </div>
              <button
                class="inline-flex items-center rounded-lg bg-white p-2 text-center text-sm font-medium text-gray-500 hover:bg-gray-100 focus:outline-none focus:ring-4 focus:ring-gray-50"
                type="button"
              >
                <svg
                  class="h-4 w-4"
                  aria-hidden="true"
                  xmlns="http://www.w3.org/2000/svg"
                  fill="currentColor"
                  viewBox="0 0 16 3"
                >
                  <path d="M2 0a1.5 1.5 0 1 1 0 3 1.5 1.5 0 0 1 0-3Zm6.041 0a1.5 1.5 0 1 1 0 3 1.5 1.5 0 0 1 0-3ZM14 0a1.5 1.5 0 1 1 0 3 1.5 1.5 0 0 1 0-3Z" />
                </svg>
                <span class="sr-only">Comment settings</span>
              </button>
              <!-- Dropdown menu -->
              <div class="z-10 hidden w-36 divide-y divide-gray-100 rounded bg-white shadow">
                <ul
                  class="py-1 text-sm text-gray-700"
                  aria-labelledby="dropdownMenuIconHorizontalButton"
                >
                  <li>
                    <a href="#" class="block px-4 py-2 hover:bg-gray-100">
                      Edit
                    </a>
                  </li>
                  <li>
                    <a href="#" class="block px-4 py-2 hover:bg-gray-100">
                      Remove
                    </a>
                  </li>
                  <li>
                    <a href="#" class="block px-4 py-2 hover:bg-gray-100">
                      Report
                    </a>
                  </li>
                </ul>
              </div>
            </footer>
            <p class="text-zinc-600">
              <%= comment.body %>
            </p>
          </article>
          <hr :if={index != @post.comment_count - 1} class="border-zinc-150 my-4" />
        <% end %>
      </ul>

      <.modal
        :if={@action}
        id="add-comment-modal"
        show
        on_cancel={JS.push("clear-action", target: @myself)}
      >
        <.simple_form
          for={@comment_form}
          phx-submit="submit"
          phx-target={@myself}
        >
          <.input phx-mounted={JS.focus()} type="textarea" name="comment" value="" required spellcheck />
          <:actions>
            <.button phx-disable-with={gettext("Saving...")} class="-mt-2">
              <%= gettext("Comment") %>
            </.button>
          </:actions>
        </.simple_form>
      </.modal>
    </div>
    """
  end

  @impl true
  def handle_event("comment", _, socket) do
    {:noreply, assign(socket, action: :comment)}
  end

  @impl true
  def handle_event("submit", %{"comment" => body}, socket) do
    attrs = %{
      body: body,
      post_id: socket.assigns.post.id,
      user_id: socket.assigns.current_user.id
    }

    case Feed.create_comment(attrs) do
      {:ok, _comment} ->
        send(self(), {:comment_created, gettext("Comment successfully created!")})
        {:noreply, assign(socket, action: nil)}

      {:error, _changeset} ->
        {:noreply, socket}
    end

    {:noreply, socket}
  end

  @impl true
  def handle_event("clear-action", _, socket) do
    {:noreply, assign(socket, action: nil)}
  end
end
