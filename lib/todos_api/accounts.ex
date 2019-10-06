defmodule TodosApi.Accounts do
  @moduledoc """
  The Accounts context.
  """

  import Ecto.Query, warn: false
  alias TodosApi.Repo

  alias TodosApi.Accounts.User
  alias TodosApi.Accounts.Oauth

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
  Gets a user by email

  ### Examples

        iex> get_user_by_email("test@email.com")
        %User{}

        iex> get_user_by_email("non_existing_email@email.com")
        nil

  """
  def get_user_by_email(email) do
    Repo.get_by(User, email: String.downcase(email))
  end

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
    case get_user_by_email(email) do
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

  @doc """
  Create user entity with associated oauth from given map with email, provider and uid

  ## Examples

      iex> create_user_with_oauth(%{email: value, provider: provider, uid: uid})
      {:ok, %{user: %User{}, oauth: %Oauth{}}}

  """
  def create_user_with_oauth(%{email: email, provider: provider, uid: uid}) do
    user_changeset = User.changeset(%User{}, %{email: email, password: User.generate_password()})
    oauth_changeset = Oauth.changeset(%Oauth{}, %{provider: provider, uid: uid})

    Ecto.Multi.new()
    |> Ecto.Multi.insert(:user, user_changeset)
    |> Ecto.Multi.run(:oauth, fn(repo, %{user: user}) ->
      oauth_changeset
      |> Ecto.Changeset.put_change(:user_id, user.id)
      |> repo.insert()
    end)
    |> Repo.transaction()
  end

  @doc """
  Returns the list of oauths.

  ## Examples

      iex> list_oauths()
      [%Oauth{}, ...]

  """
  def list_oauths do
    Repo.all(Oauth)
  end

  @doc """
  Gets a single oauth.

  Raises `Ecto.NoResultsError` if the Oauth does not exist.

  ## Examples

      iex> get_oauth!(123)
      %Oauth{}

      iex> get_oauth!(456)
      ** (Ecto.NoResultsError)

  """
  def get_oauth!(id), do: Repo.get!(Oauth, id)

  @doc """
  Gets a user by oauth provider and uid

  ### Examples

        iex> get_user_by_provider_and_uid("provider", "uid")
        {:ok, %User{}}

  """
  def get_user_by_provider_and_uid(nil, _uid), do: {:error, :invalid}
  def get_user_by_provider_and_uid(_provider, nil), do: {:error, :invalid}
  def get_user_by_provider_and_uid(provider, uid) do
    case Repo.get_by(Oauth, provider: provider, uid: uid) do
      nil -> {:error, :not_found}
      oauth ->
        oauth = Repo.preload(oauth, :user) 
        {:ok, oauth.user}
    end
  end

  @doc """
  Creates a oauth for given user.

  ## Examples

      iex> create_oauth(%User{id: 1}, %{field: value})
      {:ok, %Oauth{}}

      iex> create_oauth(%User{id: 1}, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_oauth(%User{} = user, attrs \\ %{}) do
    %Oauth{}
    |> Oauth.changeset(attrs)
    |> Ecto.Changeset.put_change(:user_id, user.id)
    |> Repo.insert()
  end

  @doc """
  Updates a oauth.

  ## Examples

      iex> update_oauth(oauth, %{field: new_value})
      {:ok, %Oauth{}}

      iex> update_oauth(oauth, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_oauth(%Oauth{} = oauth, attrs) do
    oauth
    |> Oauth.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Oauth.

  ## Examples

      iex> delete_oauth(oauth)
      {:ok, %Oauth{}}

      iex> delete_oauth(oauth)
      {:error, %Ecto.Changeset{}}

  """
  def delete_oauth(%Oauth{} = oauth) do
    Repo.delete(oauth)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking oauth changes.

  ## Examples

      iex> change_oauth(oauth)
      %Ecto.Changeset{source: %Oauth{}}

  """
  def change_oauth(%Oauth{} = oauth) do
    Oauth.changeset(oauth, %{})
  end
end
