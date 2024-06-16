defmodule EducatiumWeb.HomeLive.Components.Dropdown do
  @moduledoc false
  use EducatiumWeb, :html

  attr :name, :string, required: true
  attr :title, :string, required: true
  attr :entries, :list, required: true
  attr :current, :map, required: true

  def dropdown(assigns) do
    ~H"""
    <div x-data="{ open: false }" class="relative inline-block text-left">
      <button
        type="button"
        class="h-[28px] flex items-center rounded-full border border-gray-400 bg-zinc-50 px-4 py-1.5 text-sm text-gray-800 focus:border-gray-500"
        aria-expanded="false"
        aria-haspopup="true"
        @click="open = !open"
        @click.away="open = false"
        @keydown.escape="open = false"
      >
        <span><%= @title %></span>
        <span class="sr-only">Open dropdown</span>
        <span class="px-1 text-gray-400"><%= @current.label %></span>
        <.icon
          name="hero-chevron-down"
          class="size-5 stroke-[2.5px] -mr-1 -mb-0.5 pl-1 text-gray-900"
        />
      </button>
      <div
        class="absolute right-0 z-10 mt-2 w-48 origin-top-right rounded-md bg-white py-1 shadow-lg ring-1 ring-black ring-opacity-5 focus:outline-none"
        role="menu"
        aria-orientation="vertical"
        tabindex="-1"
        x-show="open"
        x-transition:enter="transition ease-out duration-200"
        x-transition:enter-start="transform opacity-0 scale-95"
        x-transition:enter-end="transform opacity-100 scale-100"
        x-transition:leave="transition ease-in duration-75"
        x-transition:leave-start="transform opacity-100 scale-100"
        x-transition:leave-end="transform opacity-0 scale-95"
      >
        <%= for entry <- @entries do %>
          <a
            phx-click="entry-changed"
            phx-value-name={@name}
            phx-value-entry={entry.value}
            class={[
              "block px-4 py-2 text-sm text-gray-700 hover:bg-gray-100 hover:cursor-pointer",
              entry.value == @current.value && "bg-gray-100 text-gray-900"
            ]}
            role="menuitem"
            tabindex="-1"
          >
            <%= entry.label %>
          </a>
        <% end %>
      </div>
    </div>
    """
  end
end
