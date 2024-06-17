defmodule EducatiumWeb.Admin.TagLive.FormComponent do
  use EducatiumWeb, :live_component

  alias Educatium.Resources
  alias Educatium.Resources.Tag

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        <%= @title %>
        <:subtitle><%= gettext("Use this form to manage tag records in your database.") %></:subtitle>
      </.header>

      <.simple_form
        for={@form}
        id="tag-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
        class="mt-10"
      >
        <.input field={@form[:name]} label={gettext("Name")} />
        <.input
          field={@form[:color]}
          type="select"
          label={gettext("Color")}
          prompt={gettext("Choose a value")}
          options={build_options_for_select(Tag.colors())}
        />

        <:actions>
          <div class="flex items-center space-x-4">
            <.button phx-disable-with={gettext("Saving...")}><%= gettext("Save Tag") %></.button>

            <%= if @form[:color].value && @form[:name].value do %>
              <span id="tag-preview" class={"bg-#{maybe_atom_to_string(@form[:color].value)}-50 text-#{maybe_atom_to_string(@form[:color].value)}-600 rounded-full px-2.5 py-1 text-center text-xs font-medium leading-4"}>
                <%= @form[:name].value %>
              </span>
            <% end %>
          </div>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{tag: tag} = assigns, socket) do
    changeset = Resources.change_tag(tag)

    {:ok,
     socket
     |> assign(assigns)
     |> assign_form(changeset)}
  end

  @impl true
  def handle_event("validate", %{"tag" => tag_params}, socket) do
    changeset =
      socket.assigns.tag
      |> Resources.change_tag(tag_params)
      |> Map.put(:action, :validate)

    {:noreply, assign_form(socket, changeset)}
  end

  def handle_event("save", %{"tag" => tag_params}, socket) do
    save_tag(socket, socket.assigns.action, tag_params)
  end

  defp save_tag(socket, :edit, tag_params) do
    case Resources.update_tag(socket.assigns.tag, tag_params) do
      {:ok, tag} ->
        notify_parent({:saved, tag})

        {:noreply,
         socket
         |> put_flash(:info, gettext("Tag updated successfully"))
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp save_tag(socket, :new, tag_params) do
    case Resources.create_tag(tag_params) do
      {:ok, tag} ->
        notify_parent({:saved, tag})

        {:noreply,
         socket
         |> put_flash(:info, gettext("Tag created successfully"))
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    assign(socket, :form, to_form(changeset))
  end
end
