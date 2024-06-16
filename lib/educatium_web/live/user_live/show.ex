defmodule EducatiumWeb.UserLive.Show do
  use EducatiumWeb, :live_view

  alias Educatium.Accounts
  alias Educatium.Resources
  alias Educatium.Uploaders.Avatar

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"handle" => handle}, _, socket) do
    user = Accounts.get_user_by_handle!(handle)
    is_current_user = user.id == socket.assigns.current_user.id

    query = if(is_current_user, do: [], else: [where: [visibility: :public]])
    resources = Resources.list_resources_by_user(user.id, query)

    resources =
      Enum.map(resources, fn resource ->
        tags = Resources.list_tags_by_resource(resource.id)
        Map.put(resource, :tags, tags)
      end)

    bookmarked = build_bookmarked_resources(user, is_current_user)

    bookmarked =
      Enum.map(bookmarked, fn resource ->
        tags = Resources.list_tags_by_resource(resource.id)
        Map.put(resource, :tags, tags)
      end)

    {:noreply,
     socket
     |> assign(:page_title, gettext("Profile"))
     |> assign(:user, user)
     |> assign(:is_current_user, is_current_user)
     |> assign(:resources, resources)
     |> assign(:bookmarked, bookmarked)}
  end

  defp build_bookmarked_resources(user, is_current_user) do
    if is_current_user do
      Resources.list_bookmarked_resources_by_user(user.id)
    else
      []
    end
  end
end
