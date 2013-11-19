defmodule Wire.WebsocketHandler do

  @behaviour :cowboy_websocket_handler

  def init({:tcp, :http}, _req, _opts) do
    {:upgrade, :protocol, :cowboy_websocket}
  end


  def websocket_init(transport, req, opts) do
    {channel_id, req} = :cowboy_req.binding(:channel_id, req)
    {origin_header, req} = :cowboy_req.header("origin", req)

    # IO.inspect origin_header # => "http://localhost:3000"
    #TODO allow/block requests by origin_header
    #TODO Refresh every few seconds to check for last time stamp. If time greater than few seconds. Kill it.
    # :erlang.send_after(1000, self(), "Hello!")

    add_client(channel_id, self)
    # {:ok, req, :undefined_state, 50000}
    {:ok, req, :undefined_state}
  end


  def websocket_handle({:text, msg}, req, state) do
    {channel_id, req} = :cowboy_req.binding(:channel_id, req)
    send_message_to_channel(channel_id, msg)
    {:reply, {:text, "#{channel_id} -> #{self |> pid_to_list}: #{msg}"}, req, state}
  end


  def websocket_handle(_frame, req, state) do
    {:ok, req, state}
  end


  def websocket_info({:text, msg}, req, state) do
    {:reply, {:text, msg}, req, state}
  end

  def websocket_info({timeout, _ref, msg}, req, state) do
    {:reply, {:text, state}, req, state}
  end

  def websocket_info(_info, req, state) do
    {:ok, req, state}
  end


  def websocket_terminate(reason, req, state) do
    :ok
  end


  def send_message_to_channel(channel_id, msg) do
    Enum.map(clients_of_channel(channel_id), fn(client_pid)->
      client_pid <- {:text, msg}
    end)
  end


  def clients_of_channel(channel_id) do
    result = :ets.lookup(:hub, channel_id)
    if result == [] do
      []
    else
      [{_, clients}] = result
      clients
    end
  end


  def add_client(channel_id, client_id) do
    unless :ets.member(:hub, channel_id) do
      :ets.insert(:hub, {channel_id, [client_id]})
    else
      [{_, clients}] = :ets.lookup(:hub, channel_id)
      :ets.insert(:hub, {channel_id, [client_id | clients]})
    end
  end

end
