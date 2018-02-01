defmodule App6 do
  def centralise(peers, recv_messages, sent_messages) do
    Enum.reduce(peers, [], fn (peer, results) ->
      sent = Map.get(sent_messages, peer, 0)
      recv = Map.get(recv_messages, peer, 0)

      results ++ [{sent, recv}]
    end)
  end

  def send_broadcast(ctx, cnt_broadcasts, max_messages) do
    if max_messages == 0 do
      send self(), :stop
    end

    state = receive do
      :stop ->
        send ctx[:app], {:send_done, cnt_broadcasts}
        :stoped
    after 0 ->
      :running
    end

    if state == :running do
      send ctx[:beb], {:beb_broadcast, :peer_broadcast}
      send_broadcast(ctx, cnt_broadcasts + 1, max_messages - 1)
    end
  end

  def recv_broadcast(ctx, recv_messages) do
    receive do
      :stop ->
        send ctx[:app], {:recv_done, recv_messages}

      {:beb_deliver, sender, :peer_broadcast} ->
        # IO.puts ["#{inspect self} RECV: ", inspect sender]

        msgs = Map.get(recv_messages, sender, 0)
        recv_messages = Map.put(recv_messages, sender, msgs + 1)

        recv_broadcast(ctx, recv_messages)
    end
  end

  def start(peer) do
    beb = receive do
      {:beb, beb} ->
        beb
    end

    id = receive do
      {:id, id} ->
        id
    end

    peers = receive do
      {:peers, peers} ->
        peers
    end

    ctx = %{
      :app  => self(),
      :beb  => beb,
      :peer => peer,
    }

    receive do
      {:broadcast, max_messages, timeout} ->
        send_process = spawn(App6, :send_broadcast,
          [ctx, 0, max_messages])
        :timer.send_after(timeout, send_process, :stop)

        :timer.send_after(timeout, self(), :stop)
        recv_broadcast(ctx, %{})

        cnt_broadcasts = receive do
          {:send_done, cnt_broadcasts} ->
            cnt_broadcasts
        end
        recv_messages = receive do
          {:recv_done, recv_messages} ->
            recv_messages
        end

        sent_messages = Enum.reduce(peers, %{}, fn (peer, sent_messages) ->
          Map.put(sent_messages, peer, cnt_broadcasts)
        end)

        results = centralise(peers, recv_messages, sent_messages)
        IO.puts ["#{inspect id}: ", inspect results]
    end
  end
end
