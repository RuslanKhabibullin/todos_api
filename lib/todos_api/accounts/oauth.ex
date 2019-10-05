defmodule TodosApi.Accounts.Oauth do
  use Ecto.Schema
  import Ecto.Changeset

  alias TodosApi.Accounts.User

  schema "oauths" do
    field :provider, :string
    field :uid, :string
    belongs_to :user, User

    timestamps()
  end

  @doc false
  def changeset(oauth, attrs) do
    oauth
    |> cast(attrs, [:provider, :uid])
    |> validate_required([:provider, :uid])
    |> unique_constraint(:uid_provider, name: :user_id_provider_oauths_unique_idx)
  end
end
