defmodule EducatiumWeb.UserSetupLive do
  use EducatiumWeb, :live_view

  alias Educatium.Accounts
  alias Educatium.Accounts.{User, Student, Teacher}

  def render(assigns) do
    ~H"""
    <.header class="text-center">
      Account Details
      <:subtitle>
        To finish your account registration please provide some additional information
      </:subtitle>
    </.header>

    <.simple_form for={@role_form} id="role_form" phx-change="change-role" class="mt-10">
      <.input
        field={@role_form[:role]}
        type="select"
        options={build_options_for_select(User.roles())}
        value={@role}
        label="Select the type of account you want to create"
      />
    </.simple_form>

    <div :if={@role == "student"}>
      <.simple_form
        for={@student_form}
        id="student_form"
        phx-submit="submit_student"
        phx-change="validate_student"
        class="mt-8"
      >
        <.input field={@student_form[:first_name]} label={gettext("First name")} required />
        <.input field={@student_form[:last_name]} label={gettext("Last name")} required />
        <.input field={@student_form[:university]} label={gettext("University")} required />
        <.input field={@student_form[:course]} label={gettext("Course")} required />
        <:actions>
          <.button phx-disable-with="Changing...">Save details</.button>
        </:actions>
      </.simple_form>
    </div>

    <div :if={@role == "teacher"}>
      <.simple_form
        for={@teacher_form}
        id="teacher_form"
        phx-submit="submit_teacher"
        phx-change="validate_teacher"
        class="mt-6"
      >
        <.input field={@teacher_form[:first_name]} label={gettext("First name")} required />
        <.input field={@teacher_form[:last_name]} label={gettext("Last name")} required />
        <.input field={@teacher_form[:university]} label={gettext("University")} required />
        <.input field={@teacher_form[:course]} label={gettext("Course")} required />
        <.input field={@teacher_form[:department]} label={gettext("Department")} required />
        <:actions>
          <.button phx-disable-with={gettext("Changing...")}>Save details</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @default_role hd(User.roles())

  def mount(_params, _session, socket) do
    student_changeset = Accounts.change_student(%Student{})
    teacher_changeset = Accounts.change_teacher(%Teacher{})
    role = Atom.to_string(@default_role)

    {:ok,
     socket
     |> assign(:student_form, to_form(student_changeset))
     |> assign(:teacher_form, to_form(teacher_changeset))
     |> assign(:role_form, to_form(%{"role" => role}))
     |> assign(:role, role)
     |> assign(:trigger_submit, false)}
  end

  def handle_event("validate_student", %{"student" => params}, socket) do
    student_form =
      %Student{}
      |> Accounts.change_student(params)
      |> Map.put(:action, :validate)
      |> to_form()

    {:noreply, assign(socket, student_form: student_form)}
  end

  def handle_event("submit_student", %{"student" => params}, socket) do
    user = socket.assigns.current_user
    params = Map.put(params, "user_id", user.id)

    case Accounts.create_student(params) do
      {:ok, _student} ->
        info = "Your account details have been updated."
        {:noreply, socket |> put_flash(:info, info) |> redirect(to: ~p"/")}

      {:error, changeset} ->
        {:noreply, assign(socket, form: to_form(Map.put(changeset, :action, :insert)))}
    end
  end

  def handle_event("validate_teacher", %{"teacher" => params}, socket) do
    teacher_form =
      %Teacher{}
      |> Accounts.change_teacher(params)
      |> Map.put(:action, :validate)
      |> to_form()

    {:noreply, assign(socket, teacher_form: teacher_form)}
  end

  def handle_event("submit_teacher", %{"teacher" => params}, socket) do
    user = socket.assigns.current_user
    params = Map.put(params, "user_id", user.id)

    case Accounts.create_teacher(params) do
      {:ok, _teacher} ->
        info = "Your account details have been updated."
        {:noreply, socket |> put_flash(:info, info) |> redirect(to: ~p"/")}

      {:error, changeset} ->
        {:noreply, assign(socket, form: to_form(Map.put(changeset, :action, :insert)))}
    end
  end

  def handle_event("change-role", %{"role" => role}, socket) do
    {:noreply, assign(socket, role: role)}
  end
end
