defmodule EducatiumWeb.AnnouncementLive.FormComponent do
  use EducatiumWeb, :live_component

  alias Educatium.Feed

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        <%= @title %>
        <:subtitle><%= gettext("Use this form to manage announcement records in your database.") %></:subtitle>
      </.header>

      <.simple_form
        for={@form}
        id="announcement-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
        class="mt-10"
      >
        <.input field={@form[:title]} label={gettext("Title")} />
        <.input field={@form[:body]} type="textarea" label={gettext("Body")} />

        <:actions>
          <.button phx-disable-with={gettext("Updating...")}>
            <%= gettext("Update announcement") %>
          </.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{announcement: announcement} = assigns, socket) do
    changeset = Feed.change_announcement(announcement)

    {:ok,
     socket
     |> assign(assigns)
     |> assign_form(changeset)}
  end

  @impl true
  def handle_event("validate", %{"announcement" => announcement_params}, socket) do
    changeset =
      socket.assigns.announcement
      |> Feed.change_announcement(announcement_params)
      |> Map.put(:action, :validate)

    {:noreply, assign_form(socket, changeset)}
  end

  def handle_event("save", %{"announcement" => announcement_params}, socket) do
    announcement_params =
      announcement_params
      |> Map.put("user_id", socket.assigns.current_user.id)

    case Feed.update_announcement(socket.assigns.announcement, announcement_params) do
      {:ok, _announcement} ->
        {:noreply,
         socket
         |> put_flash(:info, gettext("Announcement updated successfully"))
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    assign(socket, :form, to_form(changeset))
  end
end
