defmodule EducatiumWeb.UserSetupLive do
  use EducatiumWeb, :live_view

  alias Educatium.Accounts

  def render(assigns) do
    ~H"""
    <.header class="text-center">
      Account Details
      <:subtitle>To finish your account registration please provide some additional information</:subtitle>
    </.header>

    <div>
      <.simple_form
        for={@user_details_form}
        id="user_setup_form"
        phx-submit="update_details"
        phx-change="validate_details"
      >
        <.input field={@user_details_form[:full_name]} type="text" label="Full name" value={@current_user.full_name} required />
        <.input field={@user_details_form[:filliation]} type="select" options={@filiation_options} label="Filliation" required />
        <:actions>
          <.button phx-disable-with="Changing...">Save details</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  def mount(_params, _session, socket) do
    user = socket.assigns.current_user
    user_details_changeset = Accounts.change_user_details(user)
    filiation_options = Accounts.list_filiation_options()

    socket =
      socket
      |> assign(:user_details_form, to_form(user_details_changeset))
      |> assign(:filiation_options, filiation_options)
      |> assign(:trigger_submit, false)

    {:ok, socket}
  end

  def handle_event("validate_details", %{"user" => params}, socket) do
    details_form = socket.assigns.current_user
    |> Accounts.change_user_details(params)
    |> Map.put(:action, :validate)
    |> to_form()

    {:noreply, assign(socket, user_details_form: details_form)}
  end

  def handle_event("update_details", %{"user" => params}, socket) do
    user = socket.assigns.current_user

    case Accounts.setup_user_details(user, params) do
      {:ok, _updated_user} ->
        info = "Your account details have been updated."
        {:noreply, socket |> put_flash(:info, info) |> redirect(to: "/")}

      {:error, changeset} ->
        {:noreply, assign(socket, user_details_form: to_form(Map.put(changeset, :action, :insert)))}
    end
  end
end
