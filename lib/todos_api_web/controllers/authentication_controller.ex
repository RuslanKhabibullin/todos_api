defmodule TodosApiWeb.AuthenticationController do  
  use TodosApiWeb, :controller

  alias TodosApi.Accounts
  alias TodosApiWeb.Authentication.Guardian

  plug Ueberauth

  action_fallback TodosApiWeb.FallbackController

  def callback(%{assigns: %{ueberauth_auth: auth}} = conn, _params) do
    %{extra: %{raw_info: %{user: %{"email" => email, "sub" => uid}}}} = auth
  
    %{email: email, uid: uid, provider: to_string(auth.provider)}
    |> handle_oauth
    |> handle_user_conn(conn)
  end

  def callback(%{assigns: %{ueberauth_failure: fail_auth}} = conn, _params) do
    conn
    |> put_status(:unauthorized)
    |> json(%{message: "Bad request from #{fail_auth.provider}"})
  end

  def sign_in(conn, %{"user" => %{"email" => email, "password" => password}}) do
    Accounts.get_user_by_email_and_password(email, password)
    |> handle_user_conn(conn)
  end

  defp handle_oauth(%{email: email, uid: uid, provider: provider} = oauth_data) do
    with {:error, :not_found} <- Accounts.get_user_by_provider_and_uid(provider, uid) do
      case Accounts.get_user_by_email(email) do
        nil ->
          {:ok, %{user: user}} = Accounts.create_user_with_oauth(oauth_data)
          {:ok, user}
        user ->
          {:ok, _oauth} = Accounts.create_oauth(user, %{uid: uid, provider: provider})
          {:ok, user}
      end
    end
  end

  defp handle_user_conn(user, conn) do
    case user do
      {:ok, user} ->
        {:ok, jwt, _claims} = Guardian.encode_and_sign(user)
        json(conn, %{data: %{token: jwt, user: %{id: user.id, email: user.email}}})
      {:error, _reason} ->
        conn
        |> put_status(:unauthorized)
        |> json(%{message: "User not found"})
    end
  end
end
