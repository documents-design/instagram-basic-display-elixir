defmodule Ig.InstagramPost do
  defstruct caption: "", id: "", media_type: "", media_url: "", timestamp: ""

  def to_ig_post_struct(%{"caption" => c, "id" => i, "media_type" => mt, "media_url" => mu, "timestamp" => t}) do
    %__MODULE__{
      id: i,
      caption: c,
      media_type: mt,
      media_url: mu,
      timestamp: t
    }
  end
  def to_ig_post_struct(_), do: nil
end
