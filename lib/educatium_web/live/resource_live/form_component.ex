defmodule EducatiumWeb.ResourceLive.FormComponent do
  use EducatiumWeb, :live_component

  alias Educatium.Resources

  @uploads_dir Path.expand("../../../../priv/uploads", __DIR__)

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
        <.input field={@form[:title]} type="text" label="Title" required />
        <.input field={@form[:description]} type="text" label="Description" required />
        <.input
          field={@form[:type]}
          type="select"
          label="Type"
          prompt="Choose a value"
          options={Ecto.Enum.values(Educatium.Resources.Resource, :type)}
          required
        />
        <.input field={@form[:date]} type="date" label="Date" />
        <.input
          field={@form[:visibility]}
          type="select"
          label="Visibility"
          prompt="Choose a value"
          options={Ecto.Enum.values(Educatium.Resources.Resource, :visibility)}
          required
        />
        <p :if={@status}><%= @status %></p>
        <div class={@status && "hidden"}>
          <.live_file_input upload={@uploads.dir} class="hidden" />
          <input id="dir" type="file" webkitdirectory={true} phx-hook="ZipUpload" required />
        </div>
        <%= for entry <- @uploads.dir.entries do %>
          <%= entry.progress %>%
        <% end %>
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
     |> assign(files: [], status: nil)
     |> allow_upload(:dir,
      accept: :any,
      max_entries: 1,
      auto_upload: true,
      max_file_size: 1_000_000_000,
      progress: &handle_progress/3
     )
     |> assign(assigns)
     |> assign_form(changeset)}
  end

  def handle_event("validate", %{"_target" =>  ["undefined"]}, socket) do
    # TODO: change the target of this event form something more meaningful

    {:noreply, assign(socket, status: "compressing files...")}
  end

  def handle_progress(:dir, entry, socket) do
    if entry.done? do
      File.mkdir_p!(@uploads_dir)

      [{dest, _paths}] =
        consume_uploaded_entries(socket, :dir, fn %{path: path}, _entry ->
          {:ok, [{:zip_comment, []}, {:zip_file, first, _, _, _, _} | _]} =
            :zip.list_dir(~c"#{path}")

          dest_path = Path.join(@uploads_dir, Path.basename(to_string(first)))
          {:ok, paths} = :zip.unzip(~c"#{path}", cwd: ~c"#{@uploads_dir}")
          {:ok, {dest_path, paths}}
        end)

      {:noreply, assign(socket, status: "\"#{Path.basename(dest)}\" uploaded!")}
    else
      {:noreply, assign(socket, status: "uploading...")}
    end
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
end
