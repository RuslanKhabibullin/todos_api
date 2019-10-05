defmodule TodosApiWeb.UserControllerTest do
  use TodosApiWeb.ConnCase

  alias TodosApi.Accounts
  alias TodosApi.Accounts.User
  alias TodosApiWeb.Authentication.Guardian

  @create_attrs %{
    email: "user@email.com",
    password: "password"
  }
  @update_attrs %{
    email: "updated_user@email.com",
    password: "updated_password"
  }
  @another_user_attrs %{
    email: "another_user@email.com",
    password: "password"
  }
  @invalid_attrs %{email: nil, password: nil}

  def fixture(:user) do
    {:ok, user} = Accounts.create_user(@create_attrs)
    user
  end

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    setup [:create_user, :authenticate_user]

    test "lists all users", %{conn: conn, user: user} do
      conn = get(conn, Routes.user_path(conn, :index))
      assert json_response(conn, 200)["data"] == [%{"email" => "user@email.com", "id" => user.id}]
    end
  end

  describe "get user without token" do
    setup [:create_user]

    test "renders 401 status", %{conn: conn, user: user} do
      conn = get(conn, Routes.user_path(conn, :show, user))

      assert response(conn, 401)
    end
  end

  describe "get user with token" do
    setup [:create_user, :authenticate_user]

    test "get user data", %{conn: conn, user: user} do
      conn = get(conn, Routes.user_path(conn, :show, user))

      assert %{"id" => user.id, "email" => "user@email.com"} == json_response(conn, 200)["data"]
    end

    test "get another user data", %{conn: conn} do
      {:ok, another_user} = Accounts.create_user(@another_user_attrs)
      conn = get(conn, Routes.user_path(conn, :show, another_user))

      assert response(conn, 403)
    end
  end

  describe "create user" do
    test "renders user and token when data is valid", %{conn: conn} do
      conn = post(conn, Routes.user_path(conn, :create), user: @create_attrs)
      creation_response_data = json_response(conn, 201)["data"]

      assert %{"id" => id} = creation_response_data["user"]
      assert is_bitstring(creation_response_data["token"]) == true
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.user_path(conn, :create), user: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "user without token calls update endpoint" do
    setup [:create_user]

    test "renders 401 status", %{conn: conn, user: user} do
      conn = put(conn, Routes.user_path(conn, :update, user), user: @update_attrs)
      assert response(conn, 401)
    end
  end

  describe "user with token calls update endpoint" do
    setup [:create_user, :authenticate_user]

    test "renders user when data is valid", %{conn: conn, user: %User{id: id} = user} do
      conn = put(conn, Routes.user_path(conn, :update, user), user: @update_attrs)
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get(conn, Routes.user_path(conn, :show, id))

      assert %{
                "id" => id,
                "email" => "updated_user@email.com"
              } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn, user: user} do
      conn = put(conn, Routes.user_path(conn, :update, user), user: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end

    test "update another user", %{conn: conn} do
      {:ok, another_user} = Accounts.create_user(@another_user_attrs)
      conn = put(conn, Routes.user_path(conn, :update, another_user), user: @update_attrs)

      assert response(conn, 403)
    end
  end

  describe "delete user without token" do
    setup [:create_user]

    test "deletes chosen user", %{conn: conn, user: user} do
      conn = delete(conn, Routes.user_path(conn, :delete, user))
      assert response(conn, 401)
    end
  end

  describe "delete user with token" do
    setup [:create_user, :authenticate_user]

    test "deletes chosen user", %{conn: conn, user: user} do
      conn = delete(conn, Routes.user_path(conn, :delete, user))
      assert response(conn, 204)

      assert_error_sent 404, fn ->
        get(conn, Routes.user_path(conn, :show, user))
      end
    end

    test "deletes another user", %{conn: conn} do
      {:ok, another_user} = Accounts.create_user(@another_user_attrs)
      conn = delete(conn, Routes.user_path(conn, :delete, another_user))

      assert response(conn, 403)
    end
  end

  defp create_user(_) do
    user = fixture(:user)
    {:ok, user: user}
  end

  defp authenticate_user(%{conn: conn, user: user}) do
    {:ok, jwt, _} = Guardian.encode_and_sign(user)
    {:ok, conn: put_req_header(conn, "authorization", "Bearer #{jwt}")}
  end
end
