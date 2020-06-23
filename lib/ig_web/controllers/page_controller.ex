defmodule IgWeb.PageController do
  use IgWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
