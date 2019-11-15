defmodule TodosApiWeb.AuthenticationControllerTest do
  use TodosApiWeb.ConnCase

  alias TodosApi.Accounts

  @user_attrs %{
    email: "user@email.com",
    password: "password"
  }

  def fixture(:user) do
    {:ok, user} = Accounts.create_user(@user_attrs)
    user
  end

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "sign_in" do
    test "sign in when user not present", %{conn: conn} do
      params = %{"user" => @user_attrs}
      conn = post(conn, Routes.authentication_path(conn, :sign_in, params))
      assert json_response(conn, 401) == %{"message" => "User not found"}
    end

    test "sign in when user mismatch password", %{conn: conn} do
      fixture(:user)
      params = %{"user" => %{"email" => "user@email.com", "password" => "mismatch"}}
      conn = post(conn, Routes.authentication_path(conn, :sign_in, params))
      assert json_response(conn, 401) == %{"message" => "User not found"}
    end

    test "sign in with valid params", %{conn: conn} do
      fixture(:user)
      params = %{"user" => @user_attrs}
      conn = post(conn, Routes.authentication_path(conn, :sign_in, params))
      response = json_response(conn, 200)["data"]
      assert %{"id" => id} = response["user"]
      assert is_bitstring(response["token"]) == true
    end
  end
end
