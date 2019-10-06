defmodule TodosApiWeb.TodoControllerTest do
  use TodosApiWeb.ConnCase

  alias TodosApi.Accounts
  alias TodosApiWeb.Authentication.Guardian
  alias TodosApi.Todos
  alias TodosApi.Todos.Todo

  @create_attrs %{
    description: "some description",
    is_finished: true,
    title: "some title"
  }
  @update_attrs %{
    description: "some updated description",
    is_finished: false,
    title: "some updated title"
  }
  @invalid_attrs %{description: nil, is_finished: nil, title: nil}

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    setup [:create_user_and_todo, :authenticate_user]
  
    test "lists all todos", %{conn: conn, todo: todo} do
      conn = get(conn, Routes.todo_path(conn, :index))
      assert json_response(conn, 200)["data"] == [
        %{
          "description" => "some description",
          "id" => todo.id,
          "is_finished" => true,
          "title" => "some title"
        }
      ]
    end
  end

  describe "create todo" do
    setup [:create_user_and_todo, :authenticate_user]

    test "renders todo when data is valid", %{conn: conn} do
      conn = post(conn, Routes.todo_path(conn, :create), todo: @create_attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, Routes.todo_path(conn, :show, id))

      assert %{
               "id" => id,
               "description" => "some description",
               "is_finished" => true,
               "title" => "some title"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.todo_path(conn, :create), todo: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update todo" do
    setup [:create_user_and_todo, :authenticate_user]

    test "renders todo when data is valid", %{conn: conn, todo: %Todo{id: id} = todo} do
      conn = put(conn, Routes.todo_path(conn, :update, todo), todo: @update_attrs)
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get(conn, Routes.todo_path(conn, :show, id))

      assert %{
               "id" => id,
               "description" => "some updated description",
               "is_finished" => false,
               "title" => "some updated title"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn, todo: todo} do
      conn = put(conn, Routes.todo_path(conn, :update, todo), todo: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete todo" do
    setup [:create_user_and_todo, :authenticate_user]

    test "deletes chosen todo", %{conn: conn, todo: todo} do
      conn = delete(conn, Routes.todo_path(conn, :delete, todo))
      assert response(conn, 204)

      assert_error_sent 404, fn ->
        get(conn, Routes.todo_path(conn, :show, todo))
      end
    end
  end

  defp create_user_and_todo(_) do
    with {:ok, user} <- Accounts.create_user(%{email: "user@email.com", password: "password"}),
         {:ok, todo} <- Todos.create_todo(user, @create_attrs) do
      {:ok, todo: todo, user: user}
    end
  end

  defp authenticate_user(%{conn: conn, user: user}) do
    {:ok, jwt, _} = Guardian.encode_and_sign(user)
    {:ok, conn: put_req_header(conn, "authorization", "Bearer #{jwt}")}
  end
end
