defmodule Wire.Hub do
  use GenServer.Behaviour

  def start_link do
    :gen_server.start_link({:local, :hub}, __MODULE__, [], [])
  end


  def init(state) do
    ets_options = [:set, :named_table, {:read_concurrency, true}, {:write_concurrency, true}]
    ets_id = :ets.new(:hub, ets_options)
    {:ok, state}
  end


  def handle_call({:connect, channel_id, client_id}, from, state) do
    unless :ets.member(:hub, channel_id) do
      :ets.insert(:hub, {channel_id, [client_id]})
    else
      {_, clients} = :ets.lookup(:hub, channel_id)
      :ets.insert(:hub, {channel_id, [client_id | clients]})
    end
  end


  def handle_call({:clients, channel_id}, from, state) do
    result = :ets.lookup(:hub, channel_id)
    if result == [] do
      {:reply, [], state}
    else
      {_, clients} = result
      {:reply, clients, state}
    end
  end


  def handle_call(:greet, from, state) do
    {:reply, "Hello from #{self |> pid_to_list}", state}
  end
end
