defmodule TodosApiWeb.Authentication.Guardian do
  @moduledoc """
  JWT token generation logic
  """
  
  use Guardian, otp_app: :todos_api
  alias TodosApi.Accounts

  @doc """
  Contains logic for token payload generation
  """
  def subject_for_token(%{id: id}, _claims) do
    {:ok, to_string(id)}
  end

  def subject_for_token(_, _) do
    {:error, :no_resource_id}
  end

  @doc """
  Contains logic for resource receive from token
  """
  def resource_from_claims(%{"sub" => sub}) do
    {:ok, Accounts.get_user!(sub)}
  end

  def resource_from_claims(_) do
    {:error, :no_claims_sub}
  end
end
