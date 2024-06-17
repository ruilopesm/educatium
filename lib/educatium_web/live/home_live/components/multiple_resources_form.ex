defmodule EducatiumWeb.HomeLive.Components.MultipleResourcesForm do
  use EducatiumWeb, :live_component

  alias Educatium.Feed.Post
  alias Educatium.Resources
  alias Educatium.Resources.Resource

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        <%= gettext("New resources") %>
        <:subtitle><%= gettext("Use this form to create multiple resources.") %></:subtitle>
      </.header>
      <div class="mt-4 text-gray-600">
        <p>The submited directory should have a root file called manifest.json just like this:</p>
        <pre class><code class="language-json">
    [
      {
        "title": "Resource Title 1",
        "description": "Description",
        "type": "book",
        "date": "2023-05-15",
        "visibility": "public",
        "tags": ["Webdev", "Video", ...],
        "path": "resource1"
      },
      other resources...
    ]
        </code></pre>

        <div>
          <p>Available tags:</p>
          <div class="flex flex-wrap gap-2 mt-4">
            <%= for tag <- @tags do %>
              <span class={"bg-#{tag.color}-50 text-#{tag.color}-600 rounded-full px-2.5 py-1 text-center text-xs font-medium leading-4"}>
                <%= tag.name %>
              </span>
            <% end %>
          </div>
        </div>
      </div>

      <.simple_form
        for={nil}
        id="multiple-resource-form"
        phx-target={@myself}
        phx-change="validate-resource"
        phx-submit="save-resource"
        class="mt-10"
      >
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
    </div>
    """
  end

  @impl true
  def update(assigns, socket) do
    tags = Resources.list_tags()

    {:ok,
     socket
     |> assign(assigns)
     |> assign(tags: tags)
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
  def handle_event("validate-resource", _params, socket) do
    {:noreply, assign(socket, status: gettext("Compressing files..."))}
  end

  @impl true
  def handle_event("save-resource", _params, socket) do
    current_user = socket.assigns.current_user
    path = socket.assigns.path
    case Resources.create_resources(current_user, path) do
      {:ok, _} ->
        {:noreply,
         socket
         |> put_flash(:info, gettext("Resources created successfully."))
         |> push_patch(to: ~p"/posts")}

      {:error, error} ->
        {:noreply, put_flash(socket, :info, error)}
    end
  end

  @uploads_dir Application.compile_env(:educatium, Educatium.Uploaders)[:uploads_dir]

  defp handle_progress(:dir, entry, socket) do
    if entry.done? do
      upload_dir = @uploads_dir <> socket.assigns.current_user.id
      File.mkdir_p!(upload_dir)

      [{dest, paths}] =
        consume_uploaded_entries(socket, :dir, fn %{path: path}, _entry ->
          {:ok, [{:zip_comment, []}, {:zip_file, first, _, _, _, _} | _]} =
            :zip.list_dir(~c"#{path}")

          dest = Path.join(upload_dir, Path.basename(to_string(first)))
          {:ok, paths} = :zip.unzip(~c"#{path}", cwd: ~c"#{upload_dir}")
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
