defmodule EducatiumWeb.UserSetupLive do
  use EducatiumWeb, :live_view

  alias Educatium.Accounts
  alias Educatium.Accounts.User

  @impl true
  def render(assigns) do
    ~H"""
    <.header class="text-center">
      <%= gettext("Account Details") %>
      <:subtitle>
        <%= gettext("To finish your account registration please provide some additional information") %>
      </:subtitle>
    </.header>

    <.simple_form for={@form} id="user-form" phx-change="validate" phx-submit="save" class="mt-10">
      <.input
        field={@form[:role]}
        type="select"
        options={build_options_for_select(User.roles())}
        value={@role}
        label={gettext("Select the type of account you want to create")}
      />

      <.input
        field={@form[:handler]}
        label={gettext("Handler")}
        value={@recommended_handler}
        required
      />

      <.input field={@form[:first_name]} label={gettext("First name")} required />
      <.input field={@form[:last_name]} label={gettext("Last name")} required />
      <.input field={@form[:course]} label={gettext("Course")} required />
      <.input field={@form[:university]} label={gettext("University")} required />
      <:actions>
        <.button phx-disable-with={gettext("Saving...")}><%= gettext("Save Details") %></.button>
      </:actions>
    </.simple_form>
    """
  end

  @default_role hd(User.roles())

  @impl true
  def mount(_params, _session, socket) do
    role = Atom.to_string(@default_role)
    changeset = Accounts.change_user_setup(%User{})
    recommended_handler = build_recommended_handler(socket.assigns.current_user)

    {:ok,
     socket
     |> assign_form(changeset)
     |> assign(:role, role)
     |> assign(:recommended_handler, recommended_handler)}
  end

  @impl true
  def handle_event("validate", %{"user" => user_params}, socket) do
    changeset =
      socket.assigns.current_user
      |> Accounts.change_user_setup(user_params)
      |> Map.put(:action, :validate)

    {:noreply, assign_form(socket, changeset)}
  end

  @impl true
  def handle_event("save", %{"user" => user_params}, socket) do
    user = socket.assigns.current_user

    case Accounts.complete_user_setup(user, user_params) do
      {:ok, _user} ->
        {:noreply,
         socket
         |> put_flash(:info, gettext("Account registration completed successfully"))
         |> push_redirect(to: ~p"/")}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    assign(socket, form: to_form(changeset))
  end

  @forbidden_characters "!#$%&'*+-/=?^`{|}~"

  defp build_recommended_handler(user) do
    email_local_part =
      user.email
      |> String.split("@")
      |> List.first()

    String.replace(
      email_local_part,
      ~r/[#{@forbidden_characters}]+/,
      ""
    )
  end
end
