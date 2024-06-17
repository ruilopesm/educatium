defmodule EducatiumWeb.Admin.PostLive.FormComponent do
  use EducatiumWeb, :live_component

  alias Educatium.Feed
  alias Educatium.Feed.Post

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        <%= @title %>
        <:subtitle><%= gettext("Use this form to manage post records in your database.") %></:subtitle>
      </.header>

      <.simple_form
        for={@form}
        id="post-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
        class="mt-10"
      >
        <.input
          field={@form[:type]}
          type="select"
          label={gettext("Type")}
          prompt={gettext("Choose a value")}
          options={build_options_for_select(Post.types())}
        />
        <.input field={@form[:view_count]} type="number" label={gettext("Views")} />
        <.input field={@form[:upvote_count]} type="number" label={gettext("Upvotes")} />
        <.input field={@form[:downvote_count]} type="number" label={gettext("Downvotes")} />
        <.input field={@form[:comment_count]} type="number" label={gettext("Comments")} />
        <:actions>
          <.button phx-disable-with={gettext("Saving...")}><%= gettext("Save Post") %></.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{post: post} = assigns, socket) do
    changeset = Feed.change_post(post)

    {:ok,
     socket
     |> assign(assigns)
     |> assign_form(changeset)}
  end

  @impl true
  def handle_event("validate", %{"post" => post_params}, socket) do
    changeset =
      socket.assigns.post
      |> Feed.change_post(post_params)
      |> Map.put(:action, :validate)

    {:noreply, assign_form(socket, changeset)}
  end

  def handle_event("save", %{"post" => post_params}, socket) do
    case Feed.update_post(socket.assigns.post, post_params) do
      {:ok, post} ->
        notify_parent({:saved, post})

        {:noreply,
         socket
         |> put_flash(:info, gettext("Post updated successfully"))
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    assign(socket, :form, to_form(changeset))
  end
end
