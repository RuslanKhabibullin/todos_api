defmodule TodosApiWeb.Authorization.UserHandler do
  @moduledoc """
  Realize authorization handler interface for User entities
  """

  @behaviour TodosApiWeb.Authorization.HandlerBehaviour

  alias TodosApiWeb.Authorization.Permission

  import TodosApiWeb.Context, only: [current_user: 1]

  def can?(conn, %Permission{entity: entity, action: action}) do
    case action do
      :index -> true
      :show -> current_user(conn) == entity
      :update -> current_user(conn) == entity
      :delete -> current_user(conn) == entity
    end
  end
  
  def can(conn, permission) do
    case can?(conn, permission) do
      true -> {:ok, conn}
      false -> {:error, :forbidden}
    end
  end
end
