defmodule App do
  def centralise(peers, recv_messages, sent_messages) do
    IO.puts ["sent: ", inspect sent_messages]
    IO.puts ["recv: ", inspect recv_messages]

    results = Enum.reduce(peers, [], fn (peer, results) ->
      sent = Map.get(sent_messages, peer, 0)
      recv = Map.get(recv_messages, peer, 0)

      results ++ [{sent, recv}]
    end)

    IO.puts ["#{inspect self()}: ", inspect results]
  end

  def send_broadcast(self, pl, peer_map, sent_messages, max_messages) do
    receive do
      :stop ->
        send self, {:stop, sent_messages}
        Process.exit(self(), :kill)
    after 10 ->
      :ok
    end

    if max_messages == 0 do
      send self, {:stop, sent_messages}
      Process.exit(self(), :kill)
    end

    peers = Map.keys(peer_map)

    sent_messages = Enum.reduce(peers, sent_messages, fn (receiver, sent_messages) ->
      # IO.puts ["#{inspect self} SEND: ", inspect receiver]

      dest = Map.get(peer_map, receiver)
      send pl, {:pl_send, dest, :peer_broadcast}

      msgs = Map.get(sent_messages, receiver, 0)
      sent_messages = Map.put(sent_messages, receiver, msgs + 1)

      sent_messages
    end)

    send_broadcast(self, pl, peer_map, sent_messages, max_messages - 1)
  end

  def recv_broadcast(self, pl, peer_map, recv_messages, timeout, send_process) do
    peers = Map.keys(peer_map)

    receive do
      {:pl_deliver, sender, :peer_broadcast} ->
        # IO.puts ["#{inspect self} RECV: ", inspect sender]

        msgs = Map.get(recv_messages, sender, 0)
        recv_messages = Map.put(recv_messages, sender, msgs + 1)

        recv_broadcast(self, pl, peer_map, recv_messages, timeout, send_process)
      {:timeout} ->
        send send_process, :stop
        receive do
          {:stop, sent_messages} ->
            centralise(peers, recv_messages, sent_messages)
        end
      {:stop, sent_messages} ->
        centralise(peers, recv_messages, sent_messages)
    end
  end

  def loop do
    loop()
  end

  def run(pl, peer_map) do
    receive do
      {:pl_deliver, _from, {:broadcast, max_messages, timeout}} ->
        sent_messages = %{}
        recv_messages = %{}

        send_process = spawn(App, :send_broadcast, [self(), pl, peer_map, sent_messages, max_messages])
        :timer.send_after(timeout, self(), {:timeout})

        recv_broadcast(self(), pl, peer_map, recv_messages, timeout, send_process)
    end

    loop()
  end

  def start do
    pl = receive do
      {:pl, pl} ->
        pl
    end

    peer_map = receive do
      {:pl_deliver, _from, {:peer_map, peer_map}} ->
        peer_map
    end

    IO.puts ["app.pl:", inspect pl]
    IO.puts ["app.pls:", inspect peer_map]

    run(pl, peer_map)
  end
end
