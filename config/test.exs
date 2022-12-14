import Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :messenger_bot, MessengerBotWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "dWCczaCNLB3sRCmA0xZ14NzdaoNnkYLh8QiiadrxOjilLhLPUhFuu/IsPd51cJau",
  server: false

# Print only warnings and errors during test
config :logger, level: :warn

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime

config :messenger_bot, facebook_client: FacebookMock
config :messenger_bot, coingecko_client: CoingeckoMock
config :messenger_bot, http_adapter: HttpMock
