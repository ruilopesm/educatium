defmodule EducatiumWeb.UserSettingsLive do
  use EducatiumWeb, :live_view

  alias Educatium.Accounts
  alias Educatium.Uploaders.Avatar

  @impl true
  def render(assigns) do
    ~H"""
    <.header size="3xl" class="text-center">
      <%= gettext("Account Settings") %>
      <:subtitle><%= gettext("Manage your account email address and password settings") %></:subtitle>
    </.header>

    <div x-data="{ option: 'details' }">
      <div class="mt-7 mb-10 flex justify-center border-b border-gray-200 text-center text-sm font-medium text-gray-500">
        <ul class="-mb-px flex flex-wrap">
          <li class="me-2">
            <button
              @click="option = 'details'"
              class="inline-block rounded-t-lg border-b-2 p-4"
              x-bind:class="option == 'details' ? 'active border-brand text-brand' : 'border-transparent hover:border-gray-300 hover:text-gray-600'"
            >
              <%= gettext("Details") %>
            </button>
          </li>
          <li class="me-2">
            <button
              @click="option = 'email'"
              class="inline-block rounded-t-lg border-b-2 p-4"
              x-bind:class="option == 'email' ? 'active border-brand text-brand' : 'border-transparent hover:border-gray-300 hover:text-gray-600'"
            >
              <%= gettext("Email") %>
            </button>
          </li>
          <li class="me-2">
            <button
              @click="option = 'password'"
              class="inline-block rounded-t-lg border-b-2 p-4"
              x-bind:class="option == 'password' ? 'active border-brand text-brand' : 'border-transparent hover:border-gray-300 hover:text-gray-600'"
            >
              <%= gettext("Password") %>
            </button>
          </li>
          <li class="me-2">
            <button
              @click="option = 'dev'"
              class="inline-block rounded-t-lg border-b-2 p-4"
              x-bind:class="option == 'dev' ? 'active border-brand text-brand' : 'border-transparent hover:border-gray-300 hover:text-gray-600'"
            >
              <%= gettext("Dev") %>
            </button>
          </li>
        </ul>
      </div>

      <div x-show="option === 'details'">
        <.simple_form
          for={@user_form}
          id="user_form"
          phx-submit="update_user"
          phx-change="validate_user"
          phx-drop-target={@uploads.avatar.ref}
        >
          <div class="flex justify-center">
            <.live_file_input upload={@uploads.avatar} class="hidden" />
            <a onclick={"document.getElementById('#{@uploads.avatar.ref}').click()"}>
              <div class={[
                length(@uploads.avatar.entries) != 0 && "hidden",
                "relative size-40 ring-2 ring-zinc-300 rounded-full cursor-pointer bg-zinc-400 sm:size-48 group hover:bg-tertiary"
              ]}>
                <div class="absolute flex h-full w-full items-center justify-center">
                  <.icon
                    name="hero-camera"
                    class="mx-auto h-12 w-12 text-white group-hover:text-opacity-70 sm:size-20"
                  />
                </div>
              </div>
              <section :for={entry <- @uploads.avatar.entries}>
                <article class="upload-entry group size-40 relative flex cursor-pointer items-center rounded-full bg-white sm:size-48">
                  <div class="absolute z-10 flex h-full w-full items-center justify-center rounded-full">
                    <.icon
                      name="hero-camera"
                      class="size-12 mx-auto rounded-full text-white text-opacity-0 group-hover:text-opacity-100 sm:size-20"
                    />
                  </div>
                  <figure class="flex h-full w-full items-center justify-center rounded-full group-hover:opacity-80">
                    <.live_img_preview
                      entry={entry}
                      class="size-40 rounded-full border-4 border-white object-cover object-center sm:size-48"
                    />
                  </figure>
                </article>
                <progress value={entry.progress} max="100" class="mt-2 w-full">
                  <%= entry.progress %>%
                </progress>
              </section>
            </a>
          </div>

          <.input field={@user_form[:handle]} label={gettext("Handle")} required />
          <.input field={@user_form[:first_name]} label={gettext("First name")} required />
          <.input field={@user_form[:last_name]} label={gettext("Last name")} required />
          <.input field={@user_form[:course]} label={gettext("Course")} required />
          <.input field={@user_form[:university]} label={gettext("University")} required />
          <:actions>
            <.button phx-disable-with={gettext("Updating...")}>
              <%= gettext("Update details") %>
            </.button>
          </:actions>
        </.simple_form>
      </div>

      <div x-show="option === 'email'">
        <.simple_form
          for={@email_form}
          id="email_form"
          phx-submit="update_email"
          phx-change="validate_email"
        >
          <.input field={@email_form[:email]} type="email" label="Email" required />
          <.input
            field={@email_form[:current_password]}
            name="current_password"
            id="current_password_for_email"
            type="password"
            label={gettext("Current password")}
            value={@email_form_current_password}
            required
          />
          <:actions>
            <.button phx-disable-with={gettext("Changing...")}>
              <%= gettext("Change Email") %>
            </.button>
          </:actions>
        </.simple_form>
      </div>

      <div x-show="option === 'password'">
        <.simple_form
          for={@password_form}
          id="password_form"
          action={~p"/users/log_in?_action=password_updated"}
          method="post"
          phx-change="validate_password"
          phx-submit="update_password"
          phx-trigger-action={@trigger_submit}
        >
          <input
            name={@password_form[:email].name}
            type="hidden"
            id="hidden_user_email"
            value={@current_email}
          />
          <.input
            field={@password_form[:password]}
            type="password"
            label={gettext("New password")}
            required
          />
          <.input
            field={@password_form[:password_confirmation]}
            type="password"
            label={gettext("Confirm new password")}
          />
          <.input
            field={@password_form[:current_password]}
            name="current_password"
            type="password"
            label={gettext("Current password")}
            id="current_password_for_password"
            value={@current_password}
            required
          />
          <:actions>
            <div>
              <.button phx-disable-with={gettext("Changing...")}>
                <%= gettext("Change Password") %>
              </.button>
              <.link href={~p"/users/reset_password"} class="ml-2 text-sm font-semibold">
                <%= gettext("Forgot your password?") %>
              </.link>
            </div>
          </:actions>
        </.simple_form>
      </div>
      <div x-show="option === 'dev'">
        <div class="flex flex-col space-y-2">
          <.input type="switch" name={gettext("Toggle API Key")} checked={!is_nil(@api_key)} />

          <%= if !is_nil(@api_key) do %>
            <.input name="key" label={gettext("Key")} type="text" value={@api_key} readonly />
            <.button phx-click="regenerate-key">
              <%= gettext("Regenerate Key") %>
            </.button>
          <% end %>
        </div>
      </div>
    </div>
    """
  end

  @impl true
  def mount(%{"token" => token}, _session, socket) do
    socket =
      case Accounts.update_user_email(socket.assigns.current_user, token) do
        :ok ->
          put_flash(socket, :info, gettext("Email changed successfully."))

        :error ->
          put_flash(socket, :error, gettext("Email change link is invalid or it has expired."))
      end

    {:ok, push_navigate(socket, to: ~p"/users/settings")}
  end

  @impl true
  def mount(_params, _session, socket) do
    user = socket.assigns.current_user
    email_changeset = Accounts.change_user_email(user)
    password_changeset = Accounts.change_user_password(user)
    user_changeset = Accounts.change_user(user)

    socket =
      socket
      |> assign(:page_title, gettext("Account Settings"))
      |> assign(:current_password, nil)
      |> assign(:email_form_current_password, nil)
      |> assign(:current_email, user.email)
      |> assign(:user_form, to_form(user_changeset))
      |> assign(:email_form, to_form(email_changeset))
      |> assign(:password_form, to_form(password_changeset))
      |> assign(:trigger_submit, false)
      |> assign(:api_key, user.api_key)
      |> allow_upload(:avatar, accept: Avatar.extensions_whitelist(), max_entries: 1)

    {:ok, socket}
  end

  @impl true
  def handle_event("validate_user", %{"user" => user_params}, socket) do
    user = socket.assigns.current_user

    user_changeset =
      user
      |> Accounts.change_user(user_params)
      |> Map.put(:action, :validate)
      |> to_form()

    {:noreply, assign(socket, user_form: user_changeset)}
  end

  @impl true
  def handle_event("update_user", params, socket) do
    user = socket.assigns.current_user

    case Accounts.update_user(user, params["user"], &consume_image_data(socket, &1)) do
      {:ok, user} ->
        user_changeset = Accounts.change_user(user)

        {:noreply,
         socket
         |> put_flash(:info, gettext("Your details have been updated."))
         |> assign(user: to_form(user_changeset))}

      {:error, changeset} ->
        {:noreply,
         socket
         |> put_flash(:error, gettext("There was an error updating your details."))
         |> assign(user: to_form(changeset))}
    end
  end

  @impl true
  def handle_event("validate_email", params, socket) do
    %{"current_password" => password, "user" => user_params} = params

    email_form =
      socket.assigns.current_user
      |> Accounts.change_user_email(user_params)
      |> Map.put(:action, :validate)
      |> to_form()

    {:noreply, assign(socket, email_form: email_form, email_form_current_password: password)}
  end

  @impl true
  def handle_event("update_email", params, socket) do
    %{"current_password" => password, "user" => user_params} = params
    user = socket.assigns.current_user

    case Accounts.apply_user_email(user, password, user_params) do
      {:ok, applied_user} ->
        Accounts.deliver_user_update_email_instructions(
          applied_user,
          user.email,
          &url(~p"/users/settings/confirm_email/#{&1}")
        )

        info = gettext("A link to confirm your email change has been sent to the new address.")
        {:noreply, socket |> put_flash(:info, info) |> assign(email_form_current_password: nil)}

      {:error, changeset} ->
        {:noreply, assign(socket, :email_form, to_form(Map.put(changeset, :action, :insert)))}
    end
  end

  @impl true
  def handle_event("validate_password", params, socket) do
    %{"current_password" => password, "user" => user_params} = params

    password_form =
      socket.assigns.current_user
      |> Accounts.change_user_password(user_params)
      |> Map.put(:action, :validate)
      |> to_form()

    {:noreply, assign(socket, password_form: password_form, current_password: password)}
  end

  @impl true
  def handle_event("update_password", params, socket) do
    %{"current_password" => password, "user" => user_params} = params
    user = socket.assigns.current_user

    case Accounts.update_user_password(user, password, user_params) do
      {:ok, user} ->
        password_form =
          user
          |> Accounts.change_user_password(user_params)
          |> to_form()

        {:noreply, assign(socket, trigger_submit: true, password_form: password_form)}

      {:error, changeset} ->
        {:noreply, assign(socket, password_form: to_form(changeset))}
    end
  end

  @impl true
  def handle_event("toggle-switch", params, socket) do
    if Map.has_key?(params, "value") do
      api_key = Accounts.generate_api_key(socket.assigns.current_user)
      {:noreply, assign(socket, api_key: api_key)}
    else
      Accounts.delete_api_key(socket.assigns.current_user)
      {:noreply, assign(socket, api_key: nil)}
    end
  end

  @impl true
  def handle_event("regenerate-key", _params, socket) do
    api_key = Accounts.generate_api_key(socket.assigns.current_user)
    {:noreply, assign(socket, api_key: api_key)}
  end

  defp consume_image_data(socket, activity) do
    consume_uploaded_entries(socket, :avatar, fn %{path: path}, entry ->
      Accounts.update_user_avatar(activity, %{
        "avatar" => %Plug.Upload{
          content_type: entry.client_type,
          filename: entry.client_name,
          path: path
        }
      })
    end)
    |> case do
      [{:ok, activity}] ->
        {:ok, activity}

      _errors ->
        {:ok, activity}
    end
  end
end
