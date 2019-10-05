defmodule TodosApi.AccountsTest do
  use TodosApi.DataCase

  alias TodosApi.Accounts
  alias TodosApi.Accounts.User
  alias TodosApi.Accounts.Oauth

  @user_attrs %{email: "user@email.com", password: "password"}

  def user_fixture(attrs \\ %{}) do
    {:ok, user} =
      attrs
      |> Enum.into(@user_attrs)
      |> Accounts.create_user()

    %{user | password: nil}
  end

  describe "users" do
    @update_attrs %{email: "updated_user@email.com", password: "updated_password"}
    @invalid_attrs %{email: nil, password: nil}

    test "list_users/0 returns all users" do
      user = user_fixture()
      assert Accounts.list_users() == [user]
    end

    test "get_user!/1 returns the user with given id" do
      user = user_fixture()
      assert Accounts.get_user!(user.id) == user
    end

    test "create_user/1 with valid data creates a user" do
      assert {:ok, %User{} = user} = Accounts.create_user(@user_attrs)
      assert user.email == "user@email.com"
    end

    test "create_user/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Accounts.create_user(@invalid_attrs)
    end

    test "update_user/2 with valid data updates the user" do
      user = user_fixture()
      assert {:ok, %User{} = user} = Accounts.update_user(user, @update_attrs)
      assert user.email == "updated_user@email.com"
    end

    test "update_user/2 with invalid data returns error changeset" do
      user = user_fixture()
      assert {:error, %Ecto.Changeset{}} = Accounts.update_user(user, @invalid_attrs)
      assert user == Accounts.get_user!(user.id)
    end

    test "delete_user/1 deletes the user" do
      user = user_fixture()
      assert {:ok, %User{}} = Accounts.delete_user(user)
      assert_raise Ecto.NoResultsError, fn -> Accounts.get_user!(user.id) end
    end

    test "change_user/1 returns a user changeset" do
      user = user_fixture()
      assert %Ecto.Changeset{} = Accounts.change_user(user)
    end

    test "get_user_by_email_and_password/2 get user by email and password" do
      user = user_fixture()
      assert {:ok, user} == Accounts.get_user_by_email_and_password("user@email.com", "password")
    end
  end

  describe "oauths" do
    @valid_attrs %{provider: "google", uid: "uid"}
    @update_attrs %{provider: "vk", uid: "vk_uid"}
    @invalid_attrs %{provider: nil, uid: nil}

    def oauth_fixture(attrs \\ %{}) do
      oauth_params = Enum.into(attrs, @valid_attrs)
  
      {:ok, oauth} = Accounts.create_oauth(user_fixture(), oauth_params)
      oauth
    end

    test "list_oauths/0 returns all oauths" do
      oauth = oauth_fixture()
      assert Accounts.list_oauths() == [oauth]
    end

    test "get_oauth!/1 returns the oauth with given id" do
      oauth = oauth_fixture()
      assert Accounts.get_oauth!(oauth.id) == oauth
    end

    test "create_oauth/2 with valid data creates a oauth" do
      assert {:ok, %Oauth{} = oauth} = Accounts.create_oauth(user_fixture(), @valid_attrs)
      assert oauth.provider == "google"
      assert oauth.uid == "uid"
    end

    test "create_oauth/2 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Accounts.create_oauth(user_fixture(), @invalid_attrs)
    end

    test "update_oauth/2 with valid data updates the oauth" do
      oauth = oauth_fixture()
      assert {:ok, %Oauth{} = oauth} = Accounts.update_oauth(oauth, @update_attrs)
      assert oauth.provider == "vk"
      assert oauth.uid == "vk_uid"
    end

    test "update_oauth/2 with invalid data returns error changeset" do
      oauth = oauth_fixture()
      assert {:error, %Ecto.Changeset{}} = Accounts.update_oauth(oauth, @invalid_attrs)
      assert oauth == Accounts.get_oauth!(oauth.id)
    end

    test "delete_oauth/1 deletes the oauth" do
      oauth = oauth_fixture()
      assert {:ok, %Oauth{}} = Accounts.delete_oauth(oauth)
      assert_raise Ecto.NoResultsError, fn -> Accounts.get_oauth!(oauth.id) end
    end

    test "change_oauth/1 returns a oauth changeset" do
      oauth = oauth_fixture()
      assert %Ecto.Changeset{} = Accounts.change_oauth(oauth)
    end

    test "get_user_by_provider_and_uid/2 returns nil when oauth not exists" do
      oauth_fixture()
      assert Accounts.get_user_by_provider_and_uid("linkedin", "uid") == nil
    end

    test "get_user_by_provider_and_uid/2 returns oauth user" do
      oauth_fixture()
      assert Accounts.get_user_by_provider_and_uid("google", "uid").email == "user@email.com"
    end

    test "create_user_with_oauth/1 creates user with oauth" do
      {:ok, %{user: user, oauth: oauth}} = Accounts.create_user_with_oauth(
        %{email: "tester@email.com", provider: "twitter", uid: "twitter_uid"}
      )
      assert user.email == "tester@email.com"
      assert oauth.provider == "twitter"
    end

    test "create_user_with_oauth/1 return error when cant create user" do
      assert {:error, :user, _, _} = Accounts.create_user_with_oauth(
        %{email: "", provider: "twitter", uid: "twitter_uid"}
      )
    end

    test "create_user_with_oauth/1 return error when cant create oauth" do
      assert {:error, :oauth, _, _} = Accounts.create_user_with_oauth(
        %{email: "tester@email.com", provider: "", uid: "twitter_uid"}
      )

      assert TodosApi.Repo.get_by(User, %{email: "tester@email.com"}) == nil
    end
  end
end
