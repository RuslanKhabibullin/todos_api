defmodule TodosApiWeb.Authorization.TodoHandler do
  @moduledoc """
  Realize authorization handler interface for Todo entities
  """

  @behaviour TodosApiWeb.Authorization.HandlerBehaviour

  alias TodosApiWeb.Authorization.Permission
  alias TodosApi.Repo

  import TodosApiWeb.Context, only: [current_user: 1]

  def can?(conn, %Permission{entity: entity, action: action}) do
    entity = Repo.preload(entity, :user)

    case action do
      :index -> true
      :show -> current_user(conn) == entity.user
      :update -> current_user(conn) == entity.user
      :delete -> current_user(conn) == entity.user
    end
  end
  
  def can(conn, permission) do
    case can?(conn, permission) do
      true -> {:ok, conn}
      false -> {:error, :forbidden}
    end
  end
end
