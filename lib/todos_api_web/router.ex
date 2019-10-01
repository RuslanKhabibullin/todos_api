defmodule TodosApiWeb.Router do
  use TodosApiWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", TodosApiWeb do
    pipe_through :api
    
    scope "/auth" do
      post "/sign_up", UserController, :create
      post "/sign_in", AuthenticationController, :sign_in
    end

    resources "/users", UserController, except: [:create, :new, :edit]
  end
end
