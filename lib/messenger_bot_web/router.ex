defmodule MessengerBotWeb.Router do
  use MessengerBotWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", MessengerBotWeb do
    pipe_through :api

    get "/messenger_webhook", MessengerController, :validate_token
    post "/messenger_webhook", MessengerController, :handle_message
  end
end
