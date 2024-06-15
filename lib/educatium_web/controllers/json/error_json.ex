defmodule EducatiumWeb.ErrorJSON do
  use EducatiumWeb, :controller

  def render(template, _assigns) do
    %{errors: %{detail: Phoenix.Controller.status_message_from_template(template)}}
  end
end
