defmodule EducatiumWeb.Utils do
  @moduledoc """
  Utility functions for rendering data on views.
  """

  @doc """
  Build options for a select input.

  ## Examples

     iex> build_options_for_select([:student, :teacher])
     [Student: "student", Teacher: "teacher"]
  """
  def build_options_for_select(roles) do
    Enum.map(roles, fn role ->
      str = Atom.to_string(role)
      {String.capitalize(str), str}
    end)
  end
end
