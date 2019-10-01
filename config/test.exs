use Mix.Config

config :todos_api, TodosApi.Repo,
  database: "todos_api_test",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox

config :todos_api, TodosApiWeb.Endpoint,
  http: [port: 4002],
  server: false

config :logger, level: :warn
