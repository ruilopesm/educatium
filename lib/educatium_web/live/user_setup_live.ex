defmodule EducatiumWeb.UserSetupLive do
  use EducatiumWeb, :live_view

  alias Educatium.Accounts
  alias Educatium.Accounts.Student
  alias Educatium.Accounts.Teacher

  def render(assigns) do
    ~H"""
    <.header class="text-center">
      Account Details
      <:subtitle>
        To finish your account registration please provide some additional information
      </:subtitle>
    </.header>

    <div>
      <.simple_form for={@role_form} id="role" phx-change="change_role">
        <.input
          field={@role_form[:role]}
          type="select"
          options={["student", "teacher"]}
          value={@role}
          phx-change="change_role"
          label="Select the type of account you want to create"
        />
      </.simple_form>
    </div>

    <%= if @role == "student" do %>
      <div>
        <.simple_form
          for={@student_form}
          id="student_form"
          phx-submit="submit_student"
          phx-change="validate_student"
        >
          <.input field={@student_form[:first_name]} type="text" label="First name" required />
          <.input field={@student_form[:last_name]} type="text" label="Last name" required />
          <.input field={@student_form[:course]} type="text" label="Course" required />
          <.input field={@student_form[:university]} type="text" label="University" required />
          <:actions>
            <.button phx-disable-with="Changing...">Save details</.button>
          </:actions>
        </.simple_form>
      </div>
    <% else %>
      <div>
        <.simple_form
          for={@teacher_form}
          id="teacher_form"
          phx-submit="submit_teacher"
          phx-change="validate_teacher"
        >
          <.input field={@teacher_form[:first_name]} type="text" label="First name" required />
          <.input field={@teacher_form[:last_name]} type="text" label="Last name" required />
          <.input field={@teacher_form[:university]} type="text" label="University" required />
          <.input field={@teacher_form[:department]} type="text" label="Department" required />
          <.input field={@teacher_form[:course]} type="text" label="Course" required />
          <:actions>
            <.button phx-disable-with="Changing...">Save details</.button>
          </:actions>
        </.simple_form>
      </div>
    <% end %>
    """
  end

  def mount(_params, _session, socket) do
    student_changeset = Accounts.change_student(%Student{})
    teacher_changeset = Accounts.change_teacher(%Teacher{})
    role_form = %{role: "student"}

    socket =
      socket
      |> assign(student_form: to_form(student_changeset))
      |> assign(teacher_form: to_form(teacher_changeset))
      |> assign(:role_form, to_form(role_form))
      |> assign(:role, role_form[:role])
      |> assign(:trigger_submit, false)

    {:ok, socket}
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

    case Accounts.create_student(user, params) do
      {:ok, _student} ->
        IO.puts("OK")
        info = "Your account details have been updated."
        {:noreply, socket |> put_flash(:info, info) |> redirect(to: "/")}

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

    case Accounts.create_teacher(user, params) do
      {:ok, _teacher} ->
        IO.puts("OK")
        info = "Your account details have been updated."
        {:noreply, socket |> put_flash(:info, info) |> redirect(to: "/")}

      {:error, changeset} ->
        {:noreply, assign(socket, form: to_form(Map.put(changeset, :action, :insert)))}
    end
  end

  def handle_event("change_role", %{"role" => role}, socket) do
    {:noreply, socket |> assign(:role, role)}
  end
end
