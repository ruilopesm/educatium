defmodule EducatiumWeb.HomeLive do
  use EducatiumWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end
end
