defmodule Ig.InstagramAgent do
  use Agent

  @external_resource ".env"
  @app_id System.get_env("INSTAGRAM_V2_APP_ID", "")
  @app_secret System.get_env("INSTAGRAM_V2_SECRET", "")
  @app_oauth_url System.get_env("INSTAGRAM_V2_APP_URL", "https://localhost:4000/api/v2/instagram/authorize")

  def start_maybe() do
    case GenServer.whereis(__MODULE__) do
      nil -> start_link(nil)
      _ -> :ok
    end
  end

  def start_link(_) do
    Agent.start_link(fn -> %{token: "", id: "", posts: []} end, name: __MODULE__)
    :ok
  end

  def get_app_id(), do: @app_id
  def get_app_oauth_url(), do: @app_oauth_url

  def set_id(id) do
    start_maybe()
    Agent.update(__MODULE__, fn state -> %{state | id: id} end)
  end

  def set_token(token) do
    start_maybe()
    Agent.update(__MODULE__, fn state -> %{state | token: token} end)
  end

  def set_posts(posts) do
    start_maybe()
    Agent.update(__MODULE__, fn state -> %{state | posts: posts} end)
  end

  def get_long_token() do
    start_maybe()
    Agent.get(__MODULE__, fn s -> s.token end)
  end

  def get_posts() do
    start_maybe()
    Agent.get(__MODULE__, fn s -> Map.get(s, :posts, []) end)
  end

  def posts_url(), do: "https://graph.instagram.com/me/media?fields=id,caption,media_type,media_url,timestamp&access_token=#{get_long_token()}"
  def access_token_url(short_token), do: "https://graph.instagram.com/access_token?grant_type=ig_exchange_token&client_secret=#{@app_secret}&access_token=#{short_token}"
  def refresh_access_token_url(long_lived_token), do: "https://graph.instagram.com/refresh_access_token?grant_type=ig_refresh_token&access_token=#{long_lived_token}"

  def get_token_from_code(code) do
    # https://stackoverflow.com/a/60753048
    with {:ok, response} <-
           HTTPoison.post(
             "https://api.instagram.com/oauth/access_token",
             URI.encode_query(%{
               client_id: @app_id,
               client_secret: @app_secret,
               grant_type: "authorization_code",
               redirect_uri: @app_oauth_url,
               code: code
             }),
             [{"Content-Type", "application/x-www-form-urlencoded"}]
           ),
         %{"access_token" => token, "user_id" => user} <- Jason.decode!(response.body) do
      set_id(user)
      get_long_lived_token_from_short_token(token)
    else
      _ -> IO.inspect("Failed to obtain a short lived access token")
    end
  end

  def get_long_lived_token_from_short_token(short_token) do
    with {:ok, response} <- HTTPoison.get(access_token_url(short_token)),
      %{"access_token" => token, "expires_in" => expires} <- Jason.decode!(response.body) do
      set_token(token)
      Ig.InstagramScheduler.schedule_refresh(Integer.floor_div(expires, 2))
      Ig.InstagramScheduler.schedule_fetch_posts(5)
      else
        _ -> IO.inspect("Failed to get long lived access token")
      end
  end

  def refresh_long_lived_token() do
    with {:ok, response} <- HTTPoison.get(refresh_access_token_url(get_long_token())),
         %{"access_token" => token, "expires_in" => expires} <- Jason.decode!(response.body) do
            set_token(token)
            Ig.InstagramScheduler.schedule_refresh(Integer.floor_div(expires, 2))
            Ig.InstagramScheduler.schedule_fetch_posts(5)
         else
          _ -> IO.inspect("Failed to refresh long lived access token")
         end
  end

  def fetch_posts() do
    {:ok, response} = HTTPoison.get(posts_url())
    %{"data" => posts} = Jason.decode!(response.body)
    add_posts(posts |> Enum.map(&Ig.InstagramPost.to_ig_post_struct/1))
  end

  def add_posts(ig_posts) do
    old_posts = get_posts()
    old_posts ++ ig_posts
      |> Enum.filter(fn a -> !is_nil(a) end)
      |> Enum.uniq_by(fn a -> a.id end)
      |> Enum.sort_by(fn a -> a.timestamp end)
      |> set_posts
  end
end
