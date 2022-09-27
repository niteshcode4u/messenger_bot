# MessengerBot

To start your Phoenix server:

  * Install dependencies with `mix deps.get`
  * Start Phoenix endpoint with `mix phx.server` or inside IEx with `iex -S mix phx.server`

Ready to run in production? Please [check our deployment guides](https://hexdocs.pm/phoenix/deployment.html).

## Prerequisites 
 * A developer account at facebook if not then please create at [Developer at facebook](https://developers.facebook.com/)
 
## Need to set up

 1. Create a messenger app at facebook for this messenger bot (Let's day AutoRespBot)
 2. Need to create a facebook page for which you waant to set up auto response from bot
 3. Set up by subscribing that page from your newly created `appAutoRespBot`
 4. Then at developer facebook page you need to go to messenger settings and generate `FB_PAGE_ACCESS_TOKEN`
 5. Subscribe to `messeges` & `messaging_postbacks` webhook for the page
 6. Add callbacks where you need to provide your application url(`use ngrok if you using locally`) and generated token
 7. Once successful you are ready to make message to the page

## How to send and receive message
 1. Go to your facebook account chat box and send `hi` or `hello` or `hey` to the page you have added to the bot
 2. You will get response (may take little while if running locally) and then type help to get help
 3. Send list <currency> to search top 5 coins maching.
 4. Any point of time you cna type help to get suggestions

## Test coverage
![image](https://user-images.githubusercontent.com/20892499/191776489-f9892e9a-bc85-4ea9-9fcc-c3a29cf1d29a.png)


## Docker deployment

 ### Build
  ```
  docker build ./ -t messenger_bot
  ```
 ### Run
  ```
  docker run -it -e SECRET_KEY_BASE='<Your Base Here>' -e FB_PAGE_ACCESS_TOKEN='<Your PAT Here>' -p 4000:4000 messenger_bot

  ```
