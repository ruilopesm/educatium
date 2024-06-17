defmodule EducatiumWeb.Admin.TagLive.Index do
  use EducatiumWeb, :live_view

  alias Educatium.Resources
  alias Educatium.Resources.Tag
  alias EducatiumWeb.Admin.TagLive

  @impl true
  def mount(_params, _session, socket) do
    {:ok, stream(socket, :tags, Resources.list_tags())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, gettext("Edit Tag"))
    |> assign(:tag, Resources.get_tag!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, gettext("New Tag"))
    |> assign(:tag, %Tag{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, gettext("Listing Tag"))
    |> assign(:tag, nil)
  end

  @impl true
  def handle_info({TagLive.FormComponent, {:saved, tag}}, socket) do
    {:noreply, stream_insert(socket, :tags, tag)}
  end
end
