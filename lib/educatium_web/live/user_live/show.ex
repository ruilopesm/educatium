defmodule EducatiumWeb.UserLive.Show do
  use EducatiumWeb, :live_view

  alias Educatium.Accounts

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    user = Accounts.get_user!(id)
    is_current_user = user.id == socket.assigns.current_user.id

    {:noreply,
     socket
     |> assign(:user, user)
     |> assign(:is_current_user, is_current_user)
     |> assign(:role, user.role)}
  end
end
