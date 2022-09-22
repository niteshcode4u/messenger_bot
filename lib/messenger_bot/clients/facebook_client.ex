defmodule MessengerBot.Clients.FacebookClient do
  @moduledoc """
  Facebook interface implementation
  """

  require Logger

  alias MessengerBot.Behaviours.Http, as: HTTPAdapter

  @behaviour MessengerBot.Behaviours.Facebook

  def post_message(message) do
    get_face_book_env()
    |> get_send_message_endpoint()
    |> send_message(message)
    |> case do
      {:ok, response} ->
        {:ok, Jason.decode!(response.body)}

      {:error, error} ->
        Logger.error("Error in sending message to bot, #{inspect(error)}")
        {:error, error}
    end
  end

  def fetch_profile(customer_id) do
    get_face_book_env()
    |> get_fetch_profile_endpoint(customer_id)
    |> HTTPAdapter.get()
    |> case do
      {:ok, response} ->
        {:ok, Jason.decode!(response.body)}

      {:error, error} ->
        Logger.error("Error fetching profile, #{inspect(error)}")
        {:error, error}
    end
  end

  ################################ Private Functions ################################

  defp get_face_book_env do
    %{
      base_url: base_url,
      version: version,
      send_api: send_api,
      page_access_token: page_access_token
    } = Application.get_env(:messenger_bot, :face_book)

    {base_url, version, send_api, page_access_token}
  end

  defp get_send_message_endpoint({base_url, version, send_api, page_access_token}) do
    Path.join([base_url, version, send_api, "?access_token=#{page_access_token}"])
  end

  defp get_fetch_profile_endpoint({base_url, version, _send_api, page_access_token}, sender_id) do
    Path.join([base_url, version, sender_id, "?access_token=#{page_access_token}"])
  end

  defp send_message(endpoint, message) do
    headers = [{"Content-type", "application/json"}]

    with {:ok, json_msg} <- Jason.encode(message) do
      HTTPAdapter.post(endpoint, json_msg, headers)
    end
  end
end
