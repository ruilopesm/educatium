defmodule EducatiumWeb.Admin.UserLive.Index do
  use EducatiumWeb, :live_view

  alias Educatium.Accounts
  alias Educatium.Accounts.User
  alias EducatiumWeb.Admin.UserLive

  @impl true
  def mount(_params, _session, socket) do
    {:ok, stream(socket, :users, Accounts.list_users())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"handle" => handle}) do
    socket
    |> assign(:page_title, gettext("Edit User"))
    |> assign(:user, Accounts.get_user_by_handle!(handle))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, gettext("Create User"))
    |> assign(:user, %User{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, gettext("Listing Users"))
    |> assign(:user, nil)
  end

  @impl true
  def handle_info({UserLive.FormComponent, {:saved, user}}, socket) do
    {:noreply, stream_insert(socket, :users, user)}
  end
end
