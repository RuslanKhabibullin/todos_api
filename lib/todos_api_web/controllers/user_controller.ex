defmodule TodosApiWeb.UserController do
  use TodosApiWeb, :controller

  alias TodosApi.Accounts
  alias TodosApi.Accounts.User
  alias TodosApiWeb.Authentication.Guardian
  alias TodosApiWeb.Authorization.Permission
  
  import TodosApiWeb.Authorization.UserHandler, only: [can: 2]

  action_fallback TodosApiWeb.FallbackController

  def create(conn, %{"user" => user_params}) do
    with {:ok, %User{} = user} <- Accounts.create_user(user_params) do
      {:ok, jwt, _claims} = Guardian.encode_and_sign(user)
      conn
      |> put_status(:created)
      |> json(%{data: %{token: jwt, user: %{id: user.id, email: user.email}}})
    end
  end

  def show(conn, %{"id" => id}) do
    user = Accounts.get_user!(id)

    with {:ok, conn} <- can(conn, %Permission{action: :show, entity: user}) do
      render(conn, "show.json", user: user)
    end
  end

  def update(conn, %{"id" => id, "user" => user_params}) do
    user = Accounts.get_user!(id)

    with {:ok, conn} <- can(conn, %Permission{action: :update, entity: user}),
         {:ok, %User{} = user} <- Accounts.update_user(user, user_params) do
      render(conn, "show.json", user: user)
    end
  end

  def delete(conn, %{"id" => id}) do
    user = Accounts.get_user!(id)

    with {:ok, conn} <- can(conn, %Permission{action: :delete, entity: user}),
         {:ok, %User{}} <- Accounts.delete_user(user) do
      send_resp(conn, :no_content, "")
    end
  end
end
