defmodule TodosApiWeb.Router do
  use TodosApiWeb, :router

  pipeline :api do
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

    resources "/users", UserController, except: [:create, :new, :edit]
    resources "/todos", TodoController, except: [:new, :edit]
  end
end
