defmodule TodosApiWeb.Authentication.Pipeline do
  @moduledoc """
  Authentication pipeline
  """

  use Guardian.Plug.Pipeline, otp_app: :todos_api

  plug Guardian.Plug.VerifyHeader, claims: %{"typ" => "access"}
  plug Guardian.Plug.EnsureAuthenticated
  plug Guardian.Plug.LoadResource, ensure: true
end
