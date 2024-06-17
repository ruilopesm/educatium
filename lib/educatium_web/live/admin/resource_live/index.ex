defmodule EducatiumWeb.Admin.ResourceLive.Index do
  use EducatiumWeb, :live_view

  alias Educatium.Resources

  @impl true
  def mount(_params, _session, socket) do
    resources =
      Resources.list_resources()
      |> Enum.map(fn resource ->
        tags = Resources.list_tags_by_resource(resource.id)
        Map.put(resource, :tags, tags)
      end)

    {:ok, stream(socket, :resources, resources)}
  end

  @impl true
  def handle_params(_params, _url, socket) do
    {:noreply,
     socket
     |> assign(:page_title, gettext("Listing Resources"))}
  end
end
