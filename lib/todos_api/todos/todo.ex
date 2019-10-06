defmodule TodosApi.Todos.Todo do
  use Ecto.Schema
  import Ecto.Changeset

  alias TodosApi.Accounts.User

  schema "todos" do
    field :description, :string
    field :is_finished, :boolean, default: false
    field :title, :string
    belongs_to :user, User

    timestamps()
  end

  @doc false
  def changeset(todo, attrs) do
    todo
    |> cast(attrs, [:title, :description, :is_finished])
    |> validate_required([:title, :description, :is_finished])
  end
end
