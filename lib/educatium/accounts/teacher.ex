defmodule Educatium.Accounts.Teacher do
  use Educatium, :schema

  alias Educatium.Accounts.User

  @required_fields ~w(first_name last_name university course department user_id)a
  @optional_fields ~w()a

  schema "teachers" do
    field :first_name, :string
    field :last_name, :string
    field :university, :string
    field :course, :string
    field :department, :string

    belongs_to :user, User

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(teacher, attrs) do
    teacher
    |> cast(attrs, @required_fields ++ @optional_fields)
    |> validate_required(@required_fields)
    |> prepare_changes(&apply_teacher_role_to_user/1)
  end

  defp apply_teacher_role_to_user(changeset) do
    if user_id = get_field(changeset, :user_id) do
      query = from u in User, where: u.id == ^user_id
      changeset.repo.update_all(query, set: [role: "teacher", active: true])
    end

    changeset
  end
end
