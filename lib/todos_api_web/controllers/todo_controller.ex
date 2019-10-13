defmodule TodosApiWeb.TodoController do
  use TodosApiWeb, :controller

  alias TodosApi.Todos
  alias TodosApi.Todos.Todo
  alias TodosApiWeb.Authorization.Permission

  import TodosApiWeb.Context, only: [current_user: 1]
  import TodosApiWeb.Authorization.TodoHandler, only: [can: 2]

  action_fallback TodosApiWeb.FallbackController

  def index(conn, _params) do
    todos = conn
    |> current_user
    |> Todos.list_user_todos

    render(conn, "index.json", todos: todos)
  end

  def create(conn, %{"todo" => todo_params}) do
    with {:ok, %Todo{} = todo} <- Todos.create_todo(current_user(conn), todo_params) do
      conn
      |> put_status(:created)
      |> render("show.json", todo: todo)
    end
  end

  def show(conn, %{"id" => id}) do
    todo = Todos.get_todo!(id)

    with {:ok, conn} <- can(conn, %Permission{action: :show, entity: todo}) do
      render(conn, "show.json", todo: todo)
    end
  end

  def update(conn, %{"id" => id, "todo" => todo_params}) do
    todo = Todos.get_todo!(id)

    with {:ok, conn} <- can(conn, %Permission{action: :update, entity: todo}),
         {:ok, %Todo{} = todo} <- Todos.update_todo(todo, todo_params) do
      render(conn, "show.json", todo: todo)
    end
  end

  def delete(conn, %{"id" => id}) do
    todo = Todos.get_todo!(id)

    with {:ok, conn} <- can(conn, %Permission{action: :delete, entity: todo}),
         {:ok, %Todo{}} <- Todos.delete_todo(todo) do
      send_resp(conn, :no_content, "")
    end
  end
end
