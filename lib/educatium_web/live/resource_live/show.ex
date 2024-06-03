defmodule EducatiumWeb.ResourceLive.Show do
  use EducatiumWeb, :live_view

  alias Educatium.Resources

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:resource, Resources.get_resource!(id))}
  end

  defp page_title(:show), do: "Show Resource"
  defp page_title(:edit), do: "Edit Resource"
end
