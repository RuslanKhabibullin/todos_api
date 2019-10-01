use Mix.Config

config :todos_api, TodosApiWeb.Endpoint,
  url: [scheme: "https", host: System.get_env("HOST") || "example.com", port: 443],
  force_ssl: [rewrite_on: [:x_forwarded_proto]],
  cache_static_manifest: "priv/static/cache_manifest.json"

config :logger, level: :info

import_config "prod.secret.exs"
