defmodule EducatiumWeb.HomeLive.FormComponent do
  use EducatiumWeb, :live_component

  alias Educatium.Feed.Post
  alias Educatium.Resources
  alias Educatium.Resources.Resource

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        <%= @title %>
        <:subtitle><%= gettext("Use this form to create a post for the main feed.") %></:subtitle>
      </.header>

      <.simple_form
        for={@type_form}
        id="type-form"
        phx-target={@myself}
        phx-change="change-type"
        class="mt-10"
      >
        <.input
          field={@type_form[:type]}
          type="select"
          options={build_options_for_select(Post.types())}
          label={gettext("Type of post to create")}
          value={@type}
        />
      </.simple_form>

      <.simple_form
        :if={@type == "resource"}
        for={@resource_form}
        id="resource-form"
        phx-target={@myself}
        phx-change="validate-resource"
        phx-submit="save-resource"
        class="mt-10"
      >
        <.input field={@resource_form[:title]} label={gettext("Title")} required />
        <.input
          field={@resource_form[:description]}
          type="textarea"
          label={gettext("Description")}
          required
        />
        <.input
          field={@resource_form[:type]}
          type="select"
          options={build_options_for_select(Resource.types())}
          label={gettext("Type")}
          required
        />
        <.input
          field={@resource_form[:date]}
          label={gettext("Original publication date")}
          type="date"
          required
        />

        <p :if={@status}><%= @status %></p>
        <div class={@status && "hidden"}>
          <.label for="dir"><%= gettext("Upload a directory to join your resource") %></.label>
          <.live_file_input upload={@uploads.dir} class="hidden" />
          <input
            class="mt-2 block w-full rounded-lg text-zinc-900 focus:ring-0 sm:text-sm sm:leading-6 p-2 border border-zinc-300"
            id="dir"
            type="file"
            webkitdirectory
            phx-hook="ZipUpload"
          />
          <p class="mt-1 text-sm text-gray-500 hover:cursor-help">
            Any type of file. Maximum size: 100 MiB
          </p>
        </div>

        <:actions>
          <.button phx-disable-with={gettext("Creating...")}><%= gettext("Create post") %></.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(assigns, socket) do
    resource_changeset = Resources.change_resource(%Resource{})
    resource = %Resource{}

    type = Post.types() |> List.first() |> Atom.to_string()

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:type_form, to_form(%{"type" => type}))
     |> assign(:type, type)
     |> assign(:resource_form, to_form(resource_changeset))
     |> assign(:resource, resource)
     |> assign(files: [], status: nil, path: nil)
     |> allow_upload(:dir,
       accept: :any,
       max_entries: 1,
       auto_upload: true,
       # 100 MiB
       max_file_size: 100_000_000,
       progress: &handle_progress/3
     )}
  end

  @impl true
  def handle_event("validate", %{"_target" => ["dir"]}, socket) do
    {:noreply, assign(socket, status: gettext("Compressing files..."))}
  end

  @impl true
  def handle_event("validate-resource", %{"resource" => resource_params}, socket) do
    changeset =
      socket.assigns.resource
      |> Resources.change_resource(resource_params)
      |> Map.put(:action, :validate)

    IO.inspect(socket.assigns.resource, label: "resource")

    {:noreply, assign(socket, :resource_form, to_form(changeset))}
  end

  @impl true
  def handle_event("save-resource", %{"resource" => resource_params}, socket) do
    resource_params =
      resource_params
      |> Map.put("user_id", socket.assigns.current_user.id)
      |> Map.put("visibility", "public")

    case Resources.create_resource(resource_params, socket.assigns.path) do
      {:ok, _resource} ->
        {:noreply,
         socket
         |> put_flash(:info, gettext("Resource created successfully."))
         |> push_patch(to: ~p"/posts")}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :resource_form, to_form(changeset))}
    end
  end

  @impl true
  def handle_event("change-type", %{"type" => type}, socket) do
    {:noreply, assign(socket, :type, type)}
  end

  @uploads_dir Application.compile_env(:educatium, Educatium.Uploaders)[:uploads_dir]

  defp handle_progress(:dir, entry, socket) do
    if entry.done? do
      File.mkdir_p!(@uploads_dir)

      [{dest, paths}] =
        consume_uploaded_entries(socket, :dir, fn %{path: path}, _entry ->
          {:ok, [{:zip_comment, []}, {:zip_file, first, _, _, _, _} | _]} =
            :zip.list_dir(~c"#{path}")

          dest = Path.join(@uploads_dir, Path.basename(to_string(first)))
          {:ok, paths} = :zip.unzip(~c"#{path}", cwd: ~c"#{@uploads_dir}")
          {:ok, {dest, paths}}
        end)

      {:noreply,
       socket
       |> assign(
         status:
           gettext("Directory %{name} was successfully uploaded (%{length} files)",
             name: Path.basename(dest),
             length: length(paths)
           )
       )
       |> assign(path: dest)}
    else
      {:noreply,
       assign(socket, status: gettext("Uploading %{progress}%", progress: entry.progress))}
    end
  end
end
