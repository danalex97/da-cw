# Alexandru Dan(ad5915) and Maurizio Zen(mz4715)
defmodule App4 do
  def centralise(peers, recv_messages, sent_messages) do
    Enum.reduce(peers, [], fn (peer, results) ->
      sent = Map.get(sent_messages, peer, 0)
      recv = Map.get(recv_messages, peer, 0)

      results ++ [{sent, recv}]
    end)
  end

  def broadcast(ctx, max_messages, cnt_broadcasts, recv_messages) do
    # For more comments see System3/app.
    {_, message_queue_len} = :erlang.process_info(ctx[:app], :message_queue_len)

    {cnt_broadcasts, max_messages} = if max_messages > 0 and message_queue_len == 0 do
      send ctx[:beb], {:beb_broadcast, :peer_broadcast}
      {cnt_broadcasts + 1, max_messages - 1}
    else
      {cnt_broadcasts, max_messages}
    end

    receive do
      :stop ->
        {cnt_broadcasts, recv_messages}
      {:beb_deliver, sender, :peer_broadcast} ->
        msgs = Map.get(recv_messages, sender, 0)
        recv_messages = Map.put(recv_messages, sender, msgs + 1)

        broadcast(ctx, max_messages, cnt_broadcasts, recv_messages)
    # We introduce a timeout for receiving messages to avoid communication
    # deadlocks. If the 100ms timeout passes, we are sure the mailbox is
    # empty and we broadcast again. We do this as we can no longer assume
    # perfect point-to-point links.
    after 100 ->
      broadcast(ctx, max_messages, cnt_broadcasts, recv_messages)
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
      :id => id,
      :app  => self(),
      :beb  => beb,
      :peer => peer
    }

    receive do
      {:broadcast, max_messages, timeout} ->

        :timer.send_after(timeout, self(), :stop)
        {cnt_broadcasts, recv_messages} = broadcast(ctx, max_messages, 0, %{})

        sent_messages = Enum.reduce(peers, %{}, fn (peer, sent_messages) ->
          Map.put(sent_messages, peer, cnt_broadcasts)
        end)

        results = centralise(peers, recv_messages, sent_messages)
        IO.puts ["#{inspect id}: ", inspect results]
    end
  end
end
