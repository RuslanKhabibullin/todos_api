use Mix.Config

config :todos_api, TodosApi.Repo,
  database: "todos_api_test",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox

if postgres_user = System.get_env("POSTGRES_USER") do
  config :todos_api, TodosApi.Repo, username: postgres_user
  config :todos_api, TodosApi.Repo, password: System.get_env("POSTGRES_PASSWORD")
end

config :todos_api, TodosApiWeb.Endpoint,
  http: [port: 4002],
  server: false

config :logger, level: :warn
