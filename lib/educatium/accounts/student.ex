defmodule Educatium.Accounts.Student do
  use Ecto.Schema

  import Ecto.Changeset

  alias Educatium.Accounts.User

  @required_fields [:first_name, :last_name, :course, :university, :user_id]
  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "students" do
    field :first_name, :string
    field :last_name, :string
    field :course, :string
    field :university, :string

    belongs_to :user, User

    timestamps(type: :utc_datetime)
  end

  @doc """
  A student changeset.
  """
  def changeset(student, attrs) do
    student
    |> cast(attrs, @required_fields)
    |> validate_required(@required_fields)
  end
end
