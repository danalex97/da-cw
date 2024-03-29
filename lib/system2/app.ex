# Alexandru Dan(ad5915) and Maurizio Zen(mz4715)
defmodule App2 do
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
        send ctx[:pl], {:pl_send, receiver, :peer_broadcast}

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
        msgs = Map.get(recv_messages, sender, 0)
        recv_messages = Map.put(recv_messages, sender, msgs + 1)

        recv_broadcast(ctx, peers, recv_messages)
    end
  end

  def start(peer) do
    # binding the components
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

    # The rest is similar to System1/peer1.
    ctx = %{
      :app  => self(),
      :pl   => pl,
      :peer => peer,
    }

    receive do
      {:broadcast, max_messages, timeout} ->
        send_process = spawn(App2, :send_broadcast,
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
