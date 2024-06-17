defmodule EducatiumWeb.HomeLive.FormComponent do
  use EducatiumWeb, :live_component

  alias Educatium.Feed
  alias Educatium.Feed.{Announcement, Post}
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
          options={build_options_for_select(if @current_user.role == :admin, do: Post.types(), else: Post.types() -- [:announcement])}
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
        <.input field={@resource_form[:title]} label={gettext("Title")} />

        <.input field={@resource_form[:description]} type="textarea" label={gettext("Description")} />

        <.input
          field={@resource_form[:type]}
          type="select"
          options={build_options_for_select(Resource.types())}
          label={gettext("Type")}
        />

        <.input
          field={@resource_form[:date]}
          label={gettext("Original publication date")}
          type="date"
        />

        <.input
          name="tags"
          label={gettext("Select one or more tags")}
          type="multi-select"
          target={@myself}
          options={@tags}
          selected={@tag_count}
        />

        <p :if={@status}><%= @status %></p>
        <div class={@status && "hidden"}>
          <.label for="dir"><%= gettext("Upload a directory to join your resource") %></.label>
          <.live_file_input upload={@uploads.dir} class="hidden" />
          <input
            class="mt-2 block w-full rounded-lg border border-zinc-300 p-2 text-zinc-900 focus:ring-0 sm:text-sm sm:leading-6"
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

      <.simple_form
        :if={@type == "announcement"}
        for={@announcement_form}
        id="announcement-form"
        phx-target={@myself}
        phx-submit="save-announcement"
        class="mt-10"
      >
        <.input field={@announcement_form[:title]} label={gettext("Title")} />
        <.input field={@announcement_form[:body]} type="textarea" label={gettext("Body")} />

        <:actions>
          <.button phx-disable-with={gettext("Creating...")}><%= gettext("Create post") %></.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(assigns, socket) do
    type =
      if assigns.post_type,
        do: assigns.post_type,
        else: Post.types() |> List.first() |> Atom.to_string()

    resource = %Resource{}
    resource_changeset = Resources.change_resource(resource)

    announcement = %Announcement{}
    announcement_changeset = Feed.change_announcement(announcement)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:type_form, to_form(%{"type" => type}))
     |> assign(:type, type)
     |> assign(:resource_form, to_form(resource_changeset))
     |> assign(:resource, resource)
     |> assign(:announcement_form, to_form(announcement_changeset))
     |> assign(:announcement, announcement)
     |> assign(:tags, build_tags())
     |> assign(:tag_count, 0)
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
  def handle_event("validate", %{"_target" => ["dir"]}, socket) do
    {:noreply, assign(socket, status: gettext("Compressing files..."))}
  end

  @impl true
  def handle_event("validate-resource", %{"resource" => resource_params}, socket) do
    changeset =
      socket.assigns.resource
      |> Resources.change_resource(resource_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :resource_form, to_form(changeset))}
  end

  @impl true
  def handle_event("save-resource", %{"resource" => resource_params}, socket) do
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
      |> Map.put("visibility", "public")

    case Resources.create_resource(resource_params, socket.assigns.path) do
      {:ok, _resource} ->
        {:noreply,
         socket
         |> put_flash(:info, gettext("Resource created successfully."))
         |> push_patch(to: ~p"/posts")}

      {:error, :resource, %Ecto.Changeset{} = changeset, _post} ->
        {:noreply, assign(socket, :resource_form, to_form(changeset))}
    end
  end

  @impl true
  def handle_event("validate-announcement", %{"announcement" => announcement_params}, socket) do
    changeset =
      socket.assigns.announcement
      |> Feed.change_announcement(announcement_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :announcement_form, to_form(changeset))}
  end

  @impl true
  def handle_event("save-announcement", %{"announcement" => announcement_params}, socket) do
    announcement_params =
      announcement_params
      |> Map.put("user_id", socket.assigns.current_user.id)

    case Feed.create_announcement(announcement_params) do
      {:ok, _announcement} ->
        {:noreply,
         socket
         |> put_flash(:info, gettext("Announcement created successfully"))
         |> push_patch(to: ~p"/posts")}

      {:error, :announcement, %Ecto.Changeset{} = changeset, _post} ->
        {:noreply, assign(socket, :announcement_form, to_form(changeset))}
    end
  end

  @impl true
  def handle_event("change-type", %{"type" => type}, socket) do
    {:noreply, assign(socket, :type, type)}
  end

  defp build_tags do
    Resources.list_tags()
    |> Enum.map(fn tag ->
      %{
        id: tag.id,
        label: tag.name,
        selected: false
      }
    end)
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
