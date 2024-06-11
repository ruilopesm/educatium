defmodule EducatiumWeb.UserLive.Show do
  use EducatiumWeb, :live_view

  alias Educatium.Accounts
  alias Educatium.Resources

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"handler" => handler}, _, socket) do
    user = Accounts.get_user_by_handler!(handler)
    is_current_user = user.id == socket.assigns.current_user.id

    query = if(is_current_user, do: [], else: [where: [visibility: :public]])
    resources = Resources.list_resources_by_user(user.id, query)

    {:noreply,
     socket
     |> assign(:user, user)
     |> assign(:is_current_user, is_current_user)
     |> assign(:resources, resources)}
  end
end
