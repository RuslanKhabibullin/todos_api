defmodule TodosApiWeb.Authorization.Permission do
  @typedoc """
  Permission type for Authorization logic usage
  """

  @type t :: %__MODULE__{
    action: atom,
    entity: struct | nil
  }

  defstruct action: :index, entity: nil
end
