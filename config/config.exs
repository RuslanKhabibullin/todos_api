use Mix.Config

config :todos_api,
  ecto_repos: [TodosApi.Repo]

# Configures the endpoint
config :todos_api, TodosApiWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "bEsOIkp1aSTWPTXgrLmWaN93NGejadGzucUfoPZzA5Pi3LS/C3VT7s+cZLAhaRSK",
  render_errors: [view: TodosApiWeb.ErrorView, accepts: ~w(json)],
  pubsub: [name: TodosApi.PubSub, adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

config :phoenix, :json_library, Jason

config :ueberauth, Ueberauth,
  providers: [
    google: {Ueberauth.Strategy.Google, [default_scope: "email profile"]}
  ],
  base_path: "/api/auth"

config :ueberauth, Ueberauth.Strategy.Google.OAuth,
  client_id: System.get_env("GOOGLE_CLIENT_ID"),
  client_secret: System.get_env("GOOGLE_CLIENT_SECRET")

config :todos_api, TodosApiWeb.Authentication.Guardian,
  issuer: "TodosApi",
  secret_key: System.get_env("SECRET_KEY_BASE")

# Configure the authentication plug pipeline
config :todos_api, TodosApiWeb.Authentication.Pipeline,
  module: TodosApiWeb.Authentication.Guardian,
  error_handler: TodosApiWeb.Authentication.ErrorHandler

import_config "#{Mix.env()}.exs"
