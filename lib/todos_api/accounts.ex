defmodule TodosApi.Accounts do
  @moduledoc """
  The Accounts context.
  """

  import Ecto.Query, warn: false
  alias TodosApi.Repo

  alias TodosApi.Accounts.User

  @doc """
  Returns the list of users.

  ## Examples

      iex> list_users()
      [%User{}, ...]

  """
  def list_users do
    Repo.all(User)
  end

  @doc """
  Gets a single user.

  Raises `Ecto.NoResultsError` if the User does not exist.

  ## Examples

      iex> get_user!(123)
      %User{}

      iex> get_user!(456)
      ** (Ecto.NoResultsError)

  """
  def get_user!(id), do: Repo.get!(User, id)

  @doc """
  Gets a single user by email and password

  ## Examples

      iex> get_user_by_email_and_password!(nil, "1234")
      {:error, :invalid}

      iex> get_user_by_email_and_password("user@email.com", "qweqweqwe")
      {:ok, %User{}}

      iex> get_user_by_email_and_password("user@email2.com", "12345")
      {:error, :unauthorised}

  """
  def get_user_by_email_and_password(nil, _password), do: {:error, :invalid}
  def get_user_by_email_and_password(_email, nil), do: {:error, :invalid}
  def get_user_by_email_and_password(email, password) do
    case Repo.get_by(User, email: String.downcase(email)) do
      nil -> {:error, :unauthorised}
      user ->
        is_password_valid = Argon2.verify_pass(password, user.password_hash)
        if is_password_valid, do: {:ok, user}, else: {:error, :unauthorised}
    end
  end

  @doc """
  Creates a user.

  ## Examples

      iex> create_user(%{field: value})
      {:ok, %User{}}

      iex> create_user(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_user(attrs \\ %{}) do
    %User{}
    |> User.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Same as `create_user` but throws exception if cant create user
  """
  def create_user!(attrs \\ %{}) do
    %User{}
    |> User.changeset(attrs)
    |> Repo.insert!()
  end

  @doc """
  Updates a user.

  ## Examples

      iex> update_user(user, %{field: new_value})
      {:ok, %User{}}

      iex> update_user(user, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_user(%User{} = user, attrs) do
    user
    |> User.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Same as `update_user` but throws exception if cant create user
  """
  def update_user!(%User{} = user, attrs) do
    user
    |> User.changeset(attrs)
    |> Repo.update!()
  end

  @doc """
  Deletes a User.

  ## Examples

      iex> delete_user(user)
      {:ok, %User{}}

      iex> delete_user(user)
      {:error, %Ecto.Changeset{}}

  """
  def delete_user(%User{} = user) do
    Repo.delete(user)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking user changes.

  ## Examples

      iex> change_user(user)
      %Ecto.Changeset{source: %User{}}

  """
  def change_user(%User{} = user) do
    User.changeset(user, %{})
  end
end
