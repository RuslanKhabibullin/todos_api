defmodule TodosApi.Repo.Migrations.CreateOauths do
  use Ecto.Migration

  def change do
    create table(:oauths) do
      add :provider, :string
      add :uid, :string
      add :user_id, references(:users, on_delete: :delete_all)

      timestamps()
    end

    create index(:oauths, [:user_id])
    create unique_index(:oauths, [:provider, :uid], name: :user_id_provider_oauths_unique_idx)
  end
end
