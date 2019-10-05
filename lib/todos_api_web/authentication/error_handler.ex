defmodule TodosApiWeb.Authentication.ErrorHandler do
  @moduledoc """
  Module for errors handler from guardian authentication 
  """

  import Plug.Conn
  import Phoenix.Controller, only: [json: 2]

  @doc """
  Receives errors from guardian and return error message with status
  """
  def auth_error(conn, {type, _reason}, _opts) do
    conn
    |> put_status(401)
    |> json(%{message: to_string(type)})
    |> halt()
  end
end
