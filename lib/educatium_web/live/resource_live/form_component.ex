defmodule EducatiumWeb.ResourceLive.FormComponent do
  use EducatiumWeb, :live_component

  alias Educatium.Resources
  alias Educatium.Resources.Resource

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        <%= @title %>
        <:subtitle><%= gettext("Use this form to manage resource records in your database.") %></:subtitle>
      </.header>

      <.simple_form
        for={@form}
        id="resource-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
        class="mt-10"
      >
        <.input field={@form[:title]} label={gettext("Title")} />

        <.input field={@form[:description]} type="textarea" label={gettext("Description")} />

        <.input
          field={@form[:type]}
          type="select"
          options={build_options_for_select(Resource.types())}
          label={gettext("Type")}
        />

        <.input field={@form[:date]} label={gettext("Original publication date")} type="date" />

        <.input
          name="tags"
          label={gettext("Select one or more tags")}
          type="multi-select"
          target={@myself}
          options={@tags}
          selected={@tag_count}
        />

        <:actions>
          <.button phx-disable-with={gettext("Updating...")}>
            <%= gettext("Update resource") %>
          </.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{resource: resource} = assigns, socket) do
    changeset = Resources.change_resource(resource)
    {tags, tag_count} = build_tags(resource)

    {:ok,
     socket
     |> assign(assigns)
     |> assign_form(changeset)
     |> assign(:tags, tags)
     |> assign(:tag_count, tag_count)}
  end

  @impl true
  def handle_event("toggle-option", %{"id" => id}, socket) do
    tags =
      Enum.map(socket.assigns.tags, fn tag ->
        if tag.id == id do
          %{tag | selected: not tag.selected}
        else
          tag
        end
      end)

    {:noreply, assign(socket, tags: tags, tag_count: Enum.count(tags, & &1.selected))}
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
    tags =
      List.foldl(socket.assigns.tags, [], fn tag, acc ->
        if tag.selected do
          [tag.id | acc]
        else
          acc
        end
      end)

    resource_params =
      resource_params
      |> Map.put("tags", tags)
      |> Map.put("user_id", socket.assigns.current_user.id)

    case Resources.update_resource(socket.assigns.resource, resource_params) do
      {:ok, _resource} ->
        {:noreply,
         socket
         |> put_flash(:info, gettext("Resource updated successfully!"))
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp build_tags(resource) do
    resource_tags = Resources.list_tags_by_resource(resource.id)

    tags =
      Resources.list_tags()
      |> Enum.map(fn tag ->
        %{
          id: tag.id,
          label: tag.name,
          selected: Enum.member?(resource_tags, tag)
        }
      end)

    {tags, Enum.count(tags, & &1.selected)}
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    assign(socket, :form, to_form(changeset))
  end
end
