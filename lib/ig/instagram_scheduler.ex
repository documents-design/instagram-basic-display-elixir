defmodule Ig.InstagramScheduler do
  @refresh_interval :timer.minutes(30)

  use GenServer

  def init(init_arg) do
    {:ok, init_arg}
  end

  def start_maybe() do
    case GenServer.whereis(__MODULE__) do
      nil -> start_link(nil)
      _ -> :ok
    end
  end

  def start_link(_) do
    GenServer.start_link(__MODULE__, nil)
  end

  def handle_info(:fetch_posts, s) do
    IO.inspect("Fetching Instagram posts")
    Ig.InstagramAgent.fetch_posts()
    schedule_fetch_posts(@refresh_interval)
    {:noreply, s}
  end

  def handle_info(:refresh_token, s) do
    IO.inspect("Refreshing long-lived Instagram access token")
    Ig.InstagramAgent.refresh_long_lived_token()
    {:noreply, s}
  end

  def schedule_fetch_posts(after_s) do
    start_maybe()
    Process.send_after(self(), :fetch_posts, :timer.seconds(after_s))
  end

  def schedule_refresh(after_s) do
    start_maybe()
    Process.send_after(self(), :refresh_token, :timer.seconds(after_s))
  end
end
