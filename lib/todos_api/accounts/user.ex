defmodule TodosApi.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset

  alias TodosApi.Accounts.Oauth
  alias TodosApi.Todos.Todo

  schema "users" do
    field :email, :string
    field :password_hash, :string
    field :password, :string, virtual: true
    has_many :oauths, Oauth
    has_many :todos, Todo

    timestamps()
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:email, :password])
    |> validate_required([:email, :password])
    |> unique_constraint(:email)
    |> put_hash_password()
  end

  @doc """
  Generates random password with given length (default - 8)

  ## Examples

      iex> generate_password()
      "RandPass"

  """
  def generate_password(length \\ 8) do
    :crypto.strong_rand_bytes(length)
    |> Base.encode64
    |> binary_part(0, length)
  end

  defp put_hash_password(%{valid?: true, changes: %{password: password}} = changeset) do
    put_change(changeset, :password_hash, Argon2.hash_pwd_salt(password))
  end

  defp put_hash_password(changeset), do: changeset
end
