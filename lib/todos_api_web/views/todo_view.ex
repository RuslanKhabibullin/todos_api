defmodule TodosApiWeb.TodoView do
  use TodosApiWeb, :view
  alias TodosApiWeb.TodoView

  def render("index.json", %{todos: todos}) do
    %{data: render_many(todos, TodoView, "todo.json")}
  end

  def render("show.json", %{todo: todo}) do
    %{data: render_one(todo, TodoView, "todo.json")}
  end

  def render("todo.json", %{todo: todo}) do
    %{id: todo.id,
      title: todo.title,
      description: todo.description,
      is_finished: todo.is_finished}
  end
end
