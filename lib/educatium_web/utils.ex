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

  @doc """
  Display both the first and last name of a user.

  ## Examples

     iex> display_name(%{first_name: "John", last_name: "Doe"})
     "John Doe"
  """
  def display_name(%{first_name: first_name, last_name: last_name}) do
    "#{first_name} #{last_name}"
  end

  @doc """
  Display the role of a user.

  ## Examples

     iex> display_role(:student)
     "Student"
  """
  def display_role(role) do
    String.capitalize(Atom.to_string(role))
  end

  @doc """
  Display the handler of a user.

  ## Examples

     iex> display_handler("john_doe")
     "@john_doe"
  """
  def display_handler(handler) do
    "@#{handler}"
  end

  @doc """
  Return the initials of a name.

  ## Examples

     iex> extract_initials("John", "Doe")
     "JD"

  """
  def extract_initials(first_name, last_name) do
    first = String.at(first_name, 0)
    last = String.at(last_name, 0)

    "#{first}#{last}"
  end

  @doc """
  Return the slice of size N of a string.

  Appends three dots at the end of the string if the slice is smaller than the original string.

  ## Examples

     iex> slice_string("Hello, World!", 5)
     "Hello..."

      iex> slice_string("Hello, World!", 20)
      "Hello, World!"

  """
  def slice_string(string, n) do
    if String.length(string) > n do
      String.slice(string, 0, n) <> "..."
    else
      string
    end
  end
end
