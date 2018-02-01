defmodule App3 do
  def centralise(peers, recv_messages, sent_messages) do
    Enum.reduce(peers, [], fn (peer, results) ->
      sent = Map.get(sent_messages, peer, 0)
      recv = Map.get(recv_messages, peer, 0)

      results ++ [{sent, recv}]
    end)
  end

  def send_broadcast(ctx, peers, sent_messages, max_messages) do
    if max_messages == 0 do
      send self(), :stop
    end

    state = receive do
      :stop ->
        send ctx[:app], {:send_done, sent_messages}
        :stoped
    after 0 ->
      :running
    end

    if state == :running do
      sent_messages = Enum.reduce(peers, sent_messages, fn (receiver, sent_messages) ->
        # IO.puts ["#{inspect self} SEND: ", inspect receiver]
        send ctx[:pl], {:pl_deliver, receiver, :peer_broadcast}

        msgs = Map.get(sent_messages, receiver, 0)
        sent_messages = Map.put(sent_messages, receiver, msgs + 1)

        sent_messages
      end)

      send_broadcast(ctx, peers, sent_messages, max_messages - 1)
    end
  end

  def recv_broadcast(ctx, peers, recv_messages) do
    receive do
      :stop ->
        send ctx[:app], {:recv_done, recv_messages}

      {:pl_deliver, sender, :peer_broadcast} ->
        # IO.puts ["#{inspect self} RECV: ", inspect sender]

        msgs = Map.get(recv_messages, sender, 0)
        recv_messages = Map.put(recv_messages, sender, msgs + 1)

        recv_broadcast(ctx, peers, recv_messages)
    end
  end

  def start(peer) do
    pl = receive do
      {:pl, pl} ->
        pl
    end

    id = receive do
      {:id, id} ->
        id
    end

    peers = receive do
      {:bound, peers} ->
        peers
    end

    # IO.puts ["app.pl:", inspect pl]
    # IO.puts ["app.peers:", inspect peers]

    ctx = %{
      :app  => self(),
      :pl   => pl,
      :peer => peer,
    }

    receive do
      {:broadcast, max_messages, timeout} ->
        send_process = spawn(App3, :send_broadcast,
          [ctx, peers, %{}, max_messages])
        :timer.send_after(timeout, send_process, :stop)

        :timer.send_after(timeout, self(), :stop)
        recv_broadcast(ctx, peers, %{})

        sent_messages = receive do
          {:send_done, sent_messages} ->
            sent_messages
        end
        recv_messages = receive do
          {:recv_done, recv_messages} ->
            recv_messages
        end

        results = centralise(peers, recv_messages, sent_messages)
        IO.puts ["#{inspect id}: ", inspect results]
    end
  end
end
