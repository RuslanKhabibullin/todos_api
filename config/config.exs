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

config :todos_api, TodosApi.Guardian,
  issuer: "TodosApi",
  secret_key: System.get_env("SECRET_KEY_BASE")

import_config "#{Mix.env()}.exs"
