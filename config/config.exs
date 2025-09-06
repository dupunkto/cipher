import Config

config :cipher,
  ecto_repos: [Cipher.Repo],
  generators: [timestamp_type: :utc_datetime]

config :cipher, CipherWeb.Endpoint,
  url: [host: "localhost"],
  adapter: Bandit.PhoenixAdapter,
  render_errors: [
    formats: [html: CipherWeb.ErrorHTML, json: CipherWeb.ErrorJSON],
    layout: false
  ],
  pubsub_server: Cipher.PubSub,
  live_view: [signing_salt: "WfNSTWTN"]

config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

config :phoenix, :json_library, Jason

import_config "#{config_env()}.exs"
