# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

# Configures the endpoint
config :ig, IgWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "Rr/P3JUqDwB1N8GM4UnbkdPz7Y4+0ZOlEiuKy7SL4pESH+IQinAPgMZLJuz6SgRp",
  render_errors: [view: IgWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: Ig.PubSub,
  live_view: [signing_salt: "BDWlufMF"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
