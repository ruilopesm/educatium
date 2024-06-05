defmodule Educatium.Accounts.Teacher do
  use Ecto.Schema

  import Ecto.Changeset

  alias Educatium.Accounts.User

  @required_fields [:first_name, :last_name, :university, :course, :department, :user_id]
  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "teachers" do
    field :first_name, :string
    field :last_name, :string
    field :university, :string
    field :course, :string
    field :department, :string

    belongs_to :user, User

    timestamps(type: :utc_datetime)
  end

  @doc """
  A teacher changeset.
  """
  def changeset(teacher, attrs) do
    teacher
    |> cast(attrs, @required_fields)
    |> validate_required(@required_fields)
  end
end
