defmodule Educatium.Accounts.Student do
  use Ecto.Schema

  import Ecto.Changeset
  import Ecto.Query

  alias Educatium.Accounts.User

  @required_fields ~w(first_name last_name course university user_id)a
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
    |> prepare_changes(&apply_student_role_to_user/1)
  end

  defp apply_student_role_to_user(changeset) do
    if user_id = get_field(changeset, :user_id) do
      query = from u in User, where: u.id == ^user_id
      changeset.repo.update_all(query, set: [role: "student", active: true])
    end

    changeset
  end
end
