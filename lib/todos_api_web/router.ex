defmodule TodosApiWeb.Router do
  use TodosApiWeb, :router

  pipeline :api do
    plug CORSPlug, origin: System.get_env("FRONTEND_URL") || "*"
    plug :accepts, ["json"]
  end

  pipeline :authenticated do
    plug TodosApiWeb.Authentication.Pipeline
  end


  scope "/api", TodosApiWeb do
    pipe_through :api
    
    scope "/auth" do
      post "/sign_up", UserController, :create
      post "/sign_in", AuthenticationController, :sign_in
      get "/:provider", AuthenticationController, :request
      get "/:provider/callback", AuthenticationController, :callback
    end

    pipe_through :authenticated

    resources "/users", UserController, only: [:show, :create, :update, :delete]
    resources "/todos", TodoController, only: [:index, :show, :update, :create, :delete]
  end
end
