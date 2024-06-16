defmodule EducatiumWeb.Utils do
  @moduledoc """
  Utility functions for rendering data on views.
  """
  alias Timex.Format.DateTime.Formatters.Relative

  @doc """
  Build options for a select input.

  ## Examples

     iex> build_options_for_select([:student, :teacher])
     [Student: "student", Teacher: "teacher"]
  """
  def build_options_for_select(roles) do
    Enum.map(roles, fn role ->
      str = Atom.to_string(role)
      {Gettext.dgettext(EducatiumWeb.Gettext, "enums", String.capitalize(str)), str}
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
  Stringify an atom and capitalize it.

  ## Examples

     iex> display_atom(:student)
     "Student"
  """
  def display_atom(atom) do
    atom
    |> Atom.to_string()
    |> String.capitalize()
    |> then(&Gettext.dgettext(EducatiumWeb.Gettext, "enums", &1))
  end

  @doc """
  Display the handle of a user.

  ## Examples

     iex> display_handle("john_doe")
     "@john_doe"
  """
  def display_handle(handle) do
    "@#{handle}"
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

  @doc """
  Returns a relative datetime string for the given datetime.

  ## Examples

      iex> relative_datetime(Timex.today() |> Timex.shift(years: -3))
      "3 years ago"

      iex> relative_datetime(Timex.today() |> Timex.shift(years: 3))
      "in 3 years"

      iex> relative_datetime(Timex.today() |> Timex.shift(months: -8))
      "8 months ago"

      iex> relative_datetime(Timex.today() |> Timex.shift(months: 8))
      "in 8 months"

      iex> relative_datetime(Timex.today() |> Timex.shift(days: -1))
      "yesterday"

  """
  def relative_datetime(datetime) do
    Relative.lformat!(datetime, "{relative}", Gettext.get_locale(EducatiumWeb.Gettext))
  end

  @doc """
  Display first and last name as a full name.

  ## Examples

      iex> full_name(%{first_name: "John", last_name: "Doe"})
      "John Doe"

  """
  def full_name(%{first_name: first_name, last_name: last_name}) do
    "#{first_name} #{last_name}"
  end

  @doc """
  Capitalize an atom.

  ## Examples

      iex> capitalize_atom(:student)
      "Student"
  """
  def capitalize_atom(atom) do
    atom
    |> Atom.to_string()
    |> String.capitalize()
    |> then(&Gettext.dgettext(EducatiumWeb.Gettext, "enums", &1))
  end
end
