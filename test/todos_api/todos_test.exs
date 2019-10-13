defmodule TodosApi.TodosTest do
  use TodosApi.DataCase

  alias TodosApi.Todos
  alias TodosApi.Accounts

  describe "todos" do
    alias TodosApi.Todos.Todo

    @valid_attrs %{description: "some description", is_finished: true, title: "some title"}
    @update_attrs %{description: "some updated description", is_finished: false, title: "some updated title"}
    @invalid_attrs %{description: nil, is_finished: nil, title: nil}

    def todo_fixture(attrs \\ %{}) do
      attrs = attrs |> Enum.into(@valid_attrs)
      {:ok, todo} = Todos.create_todo(user_fixture(), attrs)

      todo
    end

    def user_fixture(attrs \\ %{email: "todo_user@email.com", password: "password"}) do
      {:ok, user} = Accounts.create_user(attrs)
      user
    end

    test "list_todos/0 returns all todos" do
      todo = todo_fixture()
      assert Todos.list_todos() == [todo]
    end

    test "list_user_todos/1 returns user todos" do
      _another_user_todo = todo_fixture()
      user = user_fixture(%{email: "some_user@email.com", password: "password"})
      {:ok, user_todo} = Todos.create_todo(user, @valid_attrs)

      assert Todos.list_user_todos(user) == [user_todo]
    end

    test "get_todo!/1 returns the todo with given id" do
      todo = todo_fixture()
      assert Todos.get_todo!(todo.id) == todo
    end

    test "create_todo/2 with valid data creates a todo" do
      assert {:ok, %Todo{} = todo} = Todos.create_todo(user_fixture(), @valid_attrs)
      assert todo.description == "some description"
      assert todo.is_finished == true
      assert todo.title == "some title"
    end

    test "create_todo/2 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Todos.create_todo(user_fixture(), @invalid_attrs)
    end

    test "update_todo/2 with valid data updates the todo" do
      todo = todo_fixture()
      assert {:ok, %Todo{} = todo} = Todos.update_todo(todo, @update_attrs)
      assert todo.description == "some updated description"
      assert todo.is_finished == false
      assert todo.title == "some updated title"
    end

    test "update_todo/2 with invalid data returns error changeset" do
      todo = todo_fixture()
      assert {:error, %Ecto.Changeset{}} = Todos.update_todo(todo, @invalid_attrs)
      assert todo == Todos.get_todo!(todo.id)
    end

    test "delete_todo/1 deletes the todo" do
      todo = todo_fixture()
      assert {:ok, %Todo{}} = Todos.delete_todo(todo)
      assert_raise Ecto.NoResultsError, fn -> Todos.get_todo!(todo.id) end
    end

    test "change_todo/1 returns a todo changeset" do
      todo = todo_fixture()
      assert %Ecto.Changeset{} = Todos.change_todo(todo)
    end
  end
end
