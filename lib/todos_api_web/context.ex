defmodule TodosApiWeb.Context do
  @moduledoc """
  Contains context `helper` functions, as `current_user/1`
  """

  @doc """
  Get authenticated user
  """
  def current_user(conn) do
    Guardian.Plug.current_resource(conn)
  end
end
