# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

# Configures the endpoint
config :messenger_bot, MessengerBotWeb.Endpoint,
  url: [host: "localhost"],
  render_errors: [view: MessengerBotWeb.ErrorView, accepts: ~w(json), layout: false],
  pubsub_server: MessengerBot.PubSub,
  live_view: [signing_salt: "pU8B/ncu"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Configuration for messenger_bot dependents
config :messenger_bot,
  face_book: %{
    base_url: "https://graph.facebook.com",
    version: "v14.0",
    send_api: "me/messages",
    page_access_token: System.get_env("FB_PAGE_ACCESS_TOKEN")
  },
  coingecko: %{
    base_url: "https://api.coingecko.com/api",
    version: "v3",
    search_api: "search"
  }

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
