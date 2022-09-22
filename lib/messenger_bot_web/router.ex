defmodule MessengerBotWeb.Router do
  use MessengerBotWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", MessengerBotWeb do
    pipe_through :api
  end
end
