defmodule EducatiumWeb.ResourceLive.FormComponent do
  use EducatiumWeb, :live_component

  alias Educatium.Resources

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        <%= @title %>
        <:subtitle>Use this form to manage resource records in your database.</:subtitle>
      </.header>

      <.simple_form
        for={@form}
        id="resource-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
        class="mt-10"
      >
        <.input field={@form[:title]} type="text" label="Title" />
        <.input field={@form[:description]} type="text" label="Description" />
        <.input
          field={@form[:type]}
          type="select"
          label="Type"
          prompt="Choose a value"
          options={Ecto.Enum.values(Educatium.Resources.Resource, :type)}
        />
        <.input field={@form[:date]} type="date" label="Date" />
        <.input field={@form[:published]} type="datetime-local" label="Published" />
        <.input
          field={@form[:visibility]}
          type="select"
          label="Visibility"
          prompt="Choose a value"
          options={Ecto.Enum.values(Educatium.Resources.Resource, :visibility)}
        />
        <:actions>
          <.button phx-disable-with="Saving...">Save Resource</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{resource: resource} = assigns, socket) do
    changeset = Resources.change_resource(resource)

    {:ok,
     socket
     |> assign(assigns)
     |> assign_form(changeset)}
  end

  @impl true
  def handle_event("validate", %{"resource" => resource_params}, socket) do
    changeset =
      socket.assigns.resource
      |> Resources.change_resource(resource_params)
      |> Map.put(:action, :validate)

    {:noreply, assign_form(socket, changeset)}
  end

  def handle_event("save", %{"resource" => resource_params}, socket) do
    save_resource(socket, socket.assigns.action, resource_params)
  end

  defp save_resource(socket, :edit, resource_params) do
    case Resources.update_resource(socket.assigns.resource, resource_params) do
      {:ok, resource} ->
        notify_parent({:saved, resource})

        {:noreply,
         socket
         |> put_flash(:info, "Resource updated successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp save_resource(socket, :new, resource_params) do
    case Resources.create_resource(resource_params) do
      {:ok, resource} ->
        notify_parent({:saved, resource})

        {:noreply,
         socket
         |> put_flash(:info, "Resource created successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    assign(socket, :form, to_form(changeset))
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end
