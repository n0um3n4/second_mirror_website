Application.put_env(
  :raw_dogged_phoenix_live_view, 
  RawDoggedPhoenixLiveView.Endpoint,
  http: [ip: {0, 0, 0, 0}, port: 4000],
  server: true,
  live_view: [signing_salt: "unhackable"],
  secret_key_base: "YouWillNeverBeThisHackerman"
)

Mix.install([
  {:plug_cowboy, "~> 2.5"},
  {:jason, "~> 1.0"},
  {:phoenix, "~> 1.7.0"},
  {:phoenix_live_view, "~> 0.19.0"}
])

defmodule RawDoggedPhoenixLiveView.ErrorView do
  def render(template, _) do
    Phoenix.Controller.status_message_from_template(template)
  end
end

defmodule RawDoggedPhoenixLiveView.Router do
  use Phoenix.Router
  import Phoenix.LiveView.Router

  pipeline :browser do
    plug(:accepts, ["html"])
  end

  scope "/", RawDoggedPhoenixLiveView do
    pipe_through(:browser)

    live("/", HomeLive, :index)
  end
end

defmodule RawDoggedPhoenixLiveView.HomeLive do
  alias __MODULE__, as: HomeLive

  use Phoenix.LiveView, layout: {HomeLive, :live}

  defp phx_vsn, do: Application.spec(:phoenix, :vsn)
  defp lv_vsn, do: Application.spec(:phoenix_live_view, :vsn)

  @impl true
  def mount(_params, _session, socket), do: {:ok, socket}

  def render("live.html", assigns) do
    ~H"""
    <script src={"https://cdn.jsdelivr.net/npm/phoenix@#{phx_vsn()}/priv/static/phoenix.min.js"}></script>
    <script src={"https://cdn.jsdelivr.net/npm/phoenix_live_view@#{lv_vsn()}/priv/static/phoenix_live_view.min.js"}></script>
    <script>
      let liveSocket = new window.LiveView.LiveSocket("/live", window.Phoenix.Socket)
      liveSocket.connect()
    </script>
    <%= @inner_content %>
    """
  end
end

defmodule RawDoggedPhoenixLiveView.Endpoint do
  use Phoenix.Endpoint, otp_app: :raw_dogged_phoenix_live_view

  socket("/live", Phoenix.LiveView.Socket)

  plug(RawDoggedPhoenixLiveView.Router)
end

{:ok, _} = Supervisor.start_link([RawDoggedPhoenixLiveView.Endpoint], strategy: :one_for_one)

Process.sleep(:infinity)
