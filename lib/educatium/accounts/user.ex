defmodule Educatium.Accounts.User do
  use Educatium, :schema

  alias Educatium.Resources.Resource
  alias Educatium.Uploaders.Avatar

  @roles ~w(student teacher admin)a

  @required_fields ~w(email password)a
  @optional_fields ~w(confirmed_at active api_key)a
  @setup_fields ~w(handle first_name last_name course university role)a

  @derive {Phoenix.Param, key: :handle}

  schema "users" do
    field :email, :string
    field :password, :string, virtual: true, redact: true
    field :hashed_password, :string, redact: true

    field :api_key, :string

    field :avatar, Avatar.Type
    field :handle, :string
    field :first_name, :string
    field :last_name, :string
    field :course, :string
    field :university, :string

    field :role, Ecto.Enum, values: @roles

    field :confirmed_at, :naive_datetime
    field :active, :boolean, default: false

    has_many :resources, Resource

    timestamps(type: :utc_datetime)
  end

  @doc """
  A user changeset for registration.

  It is important to validate the length of both email and password.
  Otherwise databases may truncate the email without warnings, which
  could lead to unpredictable or insecure behaviour. Long passwords may
  also be very expensive to hash for certain algorithms.

  ## Options

    * `:hash_password` - Hashes the password so it can be stored securely
      in the database and ensures the password field is cleared to prevent
      leaks in the logs. If password hashing is not needed and clearing the
      password field is not desired (like when using this changeset for
      validations on a LiveView form), this option can be set to `false`.
      Defaults to `true`.

    * `:validate_email` - Validates the uniqueness of the email, in case
      you don't want to validate the uniqueness of the email (like when
      using this changeset for validations on a LiveView form before
      submitting the form), this option can be set to `false`.
      Defaults to `true`.
  """
  def registration_changeset(user, attrs, opts \\ []) do
    user
    |> cast(attrs, @required_fields ++ @optional_fields)
    |> validate_email(opts)
    |> validate_password(opts)
  end

  defp validate_email(changeset, opts \\ []) do
    changeset
    |> validate_required([:email])
    |> validate_format(:email, ~r/^[^\s]+@[^\s]+$/,
      message: gettext("must have the @ sign and no spaces")
    )
    |> validate_length(:email, max: 160)
    |> maybe_validate_unique_email(opts)
  end

  defp validate_password(changeset, opts) do
    changeset
    |> validate_required([:password])
    |> validate_length(:password, min: 12, max: 72)
    # Examples of additional password validation:
    # |> validate_format(:password, ~r/[a-z]/, message: "at least one lower case character")
    # |> validate_format(:password, ~r/[A-Z]/, message: "at least one upper case character")
    # |> validate_format(:password, ~r/[!?@#$%^&*_0-9]/, message: "at least one digit or punctuation character")
    |> maybe_hash_password(opts)
  end

  defp maybe_hash_password(changeset, opts) do
    hash_password? = Keyword.get(opts, :hash_password, true)
    password = get_change(changeset, :password)

    if hash_password? && password && changeset.valid? do
      changeset
      # Hashing could be done with `Ecto.Changeset.prepare_changes/2`, but that
      # would keep the database transaction open longer and hurt performance.
      |> put_change(:hashed_password, Argon2.hash_pwd_salt(password))
      |> delete_change(:password)
    else
      changeset
    end
  end

  defp maybe_validate_unique_email(changeset, opts) do
    if Keyword.get(opts, :validate_email, true) do
      changeset
      |> unsafe_validate_unique(:email, Educatium.Repo)
      |> unique_constraint(:email)
    else
      changeset
    end
  end

  @doc """
  A user changeset for changing the email.

  It requires the email to change otherwise an error is added.
  """
  def email_changeset(user, attrs, opts \\ []) do
    user
    |> cast(attrs, [:email])
    |> validate_email(opts)
    |> case do
      %{changes: %{email: _}} = changeset -> changeset
      %{} = changeset -> add_error(changeset, :email, "did not change")
    end
  end

  @doc """
  A user changeset for changing the password.

  ## Options

    * `:hash_password` - Hashes the password so it can be stored securely
      in the database and ensures the password field is cleared to prevent
      leaks in the logs. If password hashing is not needed and clearing the
      password field is not desired (like when using this changeset for
      validations on a LiveView form), this option can be set to `false`.
      Defaults to `true`.
  """
  def password_changeset(user, attrs, opts \\ []) do
    user
    |> cast(attrs, [:password])
    |> validate_confirmation(:password, message: "does not match password")
    |> validate_password(opts)
  end

  @doc """
  A user changeset for updating the user.
  """
  def changeset(user, attrs) do
    user
    |> cast(attrs, @required_fields ++ @setup_fields ++ @optional_fields)
    |> validate_email()
    |> validate_handle()
  end

  @doc """
  A user changeset for updating the user's avatar.
  """
  def avatar_changeset(user, attrs) do
    user
    |> cast_attachments(attrs, [:avatar])
  end

  @doc """
  A user changeset for completing the setup.
  """
  def setup_changeset(user, attrs) do
    user
    |> cast(attrs, @setup_fields)
    |> validate_required(@setup_fields)
    |> validate_handle()
    |> change(active: true)
  end

  defp validate_handle(changeset) do
    changeset
    |> validate_format(:handle, ~r/^[a-zA-Z0-9_.]+$/,
      message: gettext("must only contain alphanumeric characters, underscores and periods")
    )
    |> validate_length(:handle, min: 3, max: 30)
    |> unsafe_validate_unique(:handle, Educatium.Repo)
    |> unique_constraint(:handle)
  end

  @doc """
  Confirms the account by setting `confirmed_at`.
  """
  def confirm_changeset(user) do
    now = NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second)
    change(user, confirmed_at: now)
  end

  @doc """
  Verifies the password.

  If there is no user or the user doesn't have a password, we call
  `Argon2.no_user_verify/0` to avoid timing attacks.
  """
  def valid_password?(%Educatium.Accounts.User{hashed_password: hashed_password}, password)
      when is_binary(hashed_password) and byte_size(password) > 0 do
    Argon2.verify_pass(password, hashed_password)
  end

  def valid_password?(_, _) do
    Argon2.no_user_verify()
    false
  end

  @doc """
  Validates the current password otherwise adds an error to the changeset.
  """
  def validate_current_password(changeset, password) do
    if valid_password?(changeset.data, password) do
      changeset
    else
      add_error(changeset, :current_password, "is not valid")
    end
  end

  def roles, do: @roles
end
