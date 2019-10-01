defmodule TodosApiWeb.AuthenticationController do
  use TodosApiWeb, :controller

  alias TodosApi.Accounts
  alias TodosApi.Guardian

  action_fallback TodosApiWeb.FallbackController

  def sign_in(conn, %{"user" => %{"email" => email, "password" => password}}) do
    Accounts.get_user_by_email_and_password(email, password)
    |> handle_user_conn(conn)
  end

  defp handle_user_conn(user, conn) do
    case user do
      {:ok, user} ->
        {:ok, jwt, _claims} = Guardian.encode_and_sign(user)
        json(conn, %{data: %{token: jwt}})
      {:error, _reason} ->
        conn
        |> put_status(:unauthorized)
        |> json(%{message: "User not found"})
    end
  end
end
