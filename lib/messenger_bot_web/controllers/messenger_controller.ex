defmodule MessengerBotWeb.MessengerController do
  use MessengerBotWeb, :controller

  ## Docs - https://developers.facebook.com/docs/messenger-platform/webhooks

  def validate_token(conn, %{"hub.mode" => "subscribe", "hub.challenge" => challenge} = _params) do
    case Integer.parse(challenge) do
      {challenge, ""} ->
        conn
        |> put_status(200)
        |> json(challenge)

      _ ->
        conn
        |> put_status(403)
        |> json(%{status: "error", message: :unauthorized})
    end
  end

  def validate_token(conn, _params) do
    conn
    |> put_status(404)
    |> json(%{status: "error", message: :not_found})
  end

  def handle_message(conn, %{"entry" => [event]} = _params) do
    with {:ok, _resp} <- MessengerBot.handle_event(event) do
      conn
      |> put_status(200)
      |> json(%{status: "ok", message: :received})
    else
      {:error, reason} ->
        conn
        |> put_status(404)
        |> json(%{status: "error", message: inspect(reason)})
    end
  end

  def handle_message(conn, _params) do
    conn
    |> put_status(404)
    |> json(%{status: "error", message: :not_found})
  end
end
