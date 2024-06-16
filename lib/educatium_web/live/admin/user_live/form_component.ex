defmodule EducatiumWeb.Admin.UserLive.FormComponent do
  use EducatiumWeb, :live_component

  alias Educatium.Accounts
  alias Educatium.Accounts.User

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        <%= @title %>
        <:subtitle><%= gettext("Use this form to manage user records in your database") %></:subtitle>
      </.header>

      <.simple_form
        for={@form}
        id="user-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
        class="mt-10"
      >
        <.input field={@form[:handle]} label={gettext("Handle")} />
        <.input field={@form[:email]} label={gettext("Email")} />
        <.input field={@form[:first_name]} label={gettext("First name")} />
        <.input field={@form[:last_name]} label={gettext("Last name")} />
        <.input field={@form[:course]} label={gettext("Course")} />
        <.input field={@form[:university]} label={gettext("University")} />
        <.input
          field={@form[:role]}
          type="select"
          label={gettext("Role")}
          prompt={gettext("Choose a value")}
          options={build_options_for_select(User.roles())}
        />
        <.input field={@form[:active]} type="checkbox" label={gettext("Active")} />
        <:actions>
          <.button phx-disable-with={gettext("Saving...")}><%= gettext("Save User") %></.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{user: user} = assigns, socket) do
    changeset = Accounts.change_user(user)

    {:ok,
     socket
     |> assign(assigns)
     |> assign_form(changeset)}
  end

  @impl true
  def handle_event("validate", %{"user" => user_params}, socket) do
    changeset =
      socket.assigns.user
      |> Accounts.change_user(user_params)
      |> Map.put(:action, :validate)

    {:noreply, assign_form(socket, changeset)}
  end

  def handle_event("save", %{"user" => user_params}, socket) do
    save_user(socket, socket.assigns.action, user_params)
  end

  defp save_user(socket, :edit, user_params) do
    case Accounts.update_user(socket.assigns.user, user_params) do
      {:ok, user} ->
        notify_parent({:saved, user})

        {:noreply,
         socket
         |> put_flash(:info, gettext("User updated successfully"))
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp save_user(socket, :new, user_params) do
    case Accounts.create_user(user_params) do
      {:ok, user} ->
        notify_parent({:saved, user})

        {:noreply,
         socket
         |> put_flash(:info, gettext("User created successfully"))
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    assign(socket, :form, to_form(changeset))
  end
end
