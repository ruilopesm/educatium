defmodule EducatiumWeb.HomeLive.FormComponent do
  use EducatiumWeb, :live_component

  alias EducatiumWeb.HomeLive.Components

  @impl true
  def render(assigns) do
    ~H"""
    <div x-data="{ option: 'single-resource' }">
      <div class="mb-10 flex justify-center border-b border-gray-200 text-center text-sm font-medium text-gray-500">
        <ul class="-mb-px flex flex-wrap">
          <li class="me-2">
            <button
              @click="option = 'single-resource'"
              class="inline-block rounded-t-lg border-b-2 p-4"
              x-bind:class="option == 'single-resource' ? 'active border-brand text-brand' : 'border-transparent hover:border-gray-300 hover:text-gray-600'"
            >
              <%= gettext("Single resource") %>
            </button>
          </li>
          <li class="me-2">
            <button
              @click="option = 'multiple-resources'"
              class="inline-block rounded-t-lg border-b-2 p-4"
              x-bind:class="option == 'multiple-resources' ? 'active border-brand text-brand' : 'border-transparent hover:border-gray-300 hover:text-gray-600'"
            >
              <%= gettext("Multiple resources") %>
            </button>
          </li>
        </ul>
      </div>

      <div x-show="option === 'single-resource'">
        <.live_component id="single-resource" module={Components.SingleResourceForm} title={gettext("New post")} current_user={@current_user} />
      </div>
      <div x-show="option === 'multiple-resources'">
        <.live_component id="multiple-resources" module={Components.MultipleResourcesForm} title={gettext("New post")} current_user={@current_user} />
      </div>
    </div>
    """
  end

  @impl true
  def update(assigns, socket) do
    {:ok, assign(socket, assigns)}
  end
end
