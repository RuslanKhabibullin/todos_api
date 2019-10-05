defmodule TodosApiWeb.Authorization.HandlerBehaviour do
  @moduledoc """
  Defines interface for Authorization Handler
  """

  @typep conn :: struct
  @typep permission :: struct

  @callback can?(conn, permission) :: boolean
  @callback can(conn, permission) :: {:ok, conn} | {:error, :forbidden}
end
