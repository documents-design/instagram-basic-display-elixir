defmodule IgWeb.InstagramController do
  use IgWeb, :controller

  def posts(conn, _) do
    json(conn, Ig.InstagramAgent.get_posts())
  end

  defp generate_link() do
    app_id = Ig.InstagramAgent.get_app_id()
    app_oauth_url = Ig.InstagramAgent.get_app_oauth_url()
    "https://api.instagram.com/oauth/authorize?client_id=#{app_id}&redirect_uri=#{app_oauth_url}&scope=user_profile,user_media&response_type=code"
  end

  def start_authorization(conn, _) do
    json(conn, %{link: generate_link()})
  end

  def authorize(conn, %{"code" => code}) do
    Ig.InstagramAgent.get_token_from_code(code)
    json(conn, [])
  end
end
