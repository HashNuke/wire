defmodule Wire do
  use Application.Behaviour

  # See http://elixir-lang.org/docs/stable/Application.Behaviour.html
  # for more information on OTP Applications
  def start(_type, _args) do
    {:ok, cowboy_pid} = :cowboy.start_http(
      :http,
      100,
      [port: 8080],
      [env: [dispatch: Wire.app_dispatch()] ]
    )
    ets_options = [:set, :public, :named_table, {:read_concurrency, true}, {:write_concurrency, true}]
    ets_id = :ets.new(:hub, ets_options)
    Wire.Supervisor.start_link
  end


  def app_dispatch do
    :cowboy_router.compile([
      {
        :_,
        [ {"/websocket/:channel_id", Wire.WebsocketHandler, []} ]
      }
    ])
  end

end
