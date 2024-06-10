defmodule EducatiumWeb.HomeLive.Components.Comment do
  use EducatiumWeb, :live_component

  alias Educatium.Feed.{Comment, Post}

  attr :comment, Comment, required: true

  def render(assigns) do
    ~H"""
    <.link
    href={~p"/resources/#{@post.resource.id}"}
    class="block w-full px-6 py-4 bg-white border border-gray-200 rounded-lg shadow hover:bg-gray-50"
    >
      <div class="flex gap-3">
      <p class="text-gray-500 text-xs font-normal leading-4"><%= @comment.user %></p>
      <p class="text-gray-500 text-xs font-normal leading-4"><%= @comment.body %></p>
      </div>
    </.link>
    """
  end
end
