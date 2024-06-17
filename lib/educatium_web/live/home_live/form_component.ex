defmodule EducatiumWeb.HomeLive.FormComponent do
  use EducatiumWeb, :live_component

  alias EducatiumWeb.HomeLive.Components

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <div class="mb-10 flex justify-center border-b border-gray-200 text-center text-sm font-medium text-gray-500">
        <ul class="-mb-px flex flex-wrap">
          <li class="me-2">
            <button
              class={selector_class("single-resource", @form_type)}
              phx-click="select-form"
              phx-value-form-type="single-resource"
              phx-target={@myself}
            >
              <%= gettext("Single resource") %>
            </button>
          </li>
          <li class="me-2">
            <button
              class={selector_class("multiple-resources", @form_type)}
              phx-click="select-form"
              phx-value-form-type="multiple-resources"
              phx-target={@myself}
            >
              <%= gettext("Multiple resources") %>
            </button>
          </li>
        </ul>
      </div>

      <div :if={@form_type === "single-resource"}>
        <.live_component id="single-resource" module={Components.SingleResourceForm} title={gettext("New post")} current_user={@current_user} />
      </div>
      <div :if={@form_type === "multiple-resources"}>
        <.live_component id="multiple-resources" module={Components.MultipleResourcesForm} title={gettext("New post")} current_user={@current_user} />
      </div>
    </div>
    """
  end

  @impl true
  def update(assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     |> assign(:form_type, "single-resource")}
  end

  @impl true
  def handle_event("select-form", %{"form-type" => form_type}, socket) do
    {:noreply, assign(socket, :form_type, form_type)}
  end

  defp selector_class(form_type, selected_form_type) do
    class = "inline-block rounded-t-lg border-b-2 p-4 "

    if selected_form_type == form_type do
      class <> "active border-brand text-brand"
    else
      class <> "border-transparent hover:border-gray-300 hover:text-gray-600"
    end
  end
end
