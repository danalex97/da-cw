# Alexandru Dan(ad5915) and Maurizio Zen(mz4715)
defmodule Peer1 do
  def centralise(peers, recv_messages, sent_messages) do
    Enum.reduce(peers, [], fn (peer, results) ->
      sent = Map.get(sent_messages, peer, 0)
      recv = Map.get(recv_messages, peer, 0)

      results ++ [{sent, recv}]
    end)
  end

  def send_broadcast(peer, peers, sent_messages, max_messages) do
    if max_messages == 0 do
      send self(), :stop
    end

    # When we receive a stop messages(that is a timeout or max_messages
    # reached) we stop sending and we send back the results 
    state = receive do
      :stop ->
        send peer, {:send_done, sent_messages}
        :stoped
    after 0 ->
      :running
    end

    if state == :running do
      sent_messages = Enum.reduce(peers, sent_messages, fn (receiver, sent_messages) ->
        send receiver, {:peer_broadcast, peer}

        msgs = Map.get(sent_messages, receiver, 0)
        sent_messages = Map.put(sent_messages, receiver, msgs + 1)

        sent_messages
      end)

      send_broadcast(peer, peers, sent_messages, max_messages - 1)
    end
  end

  def recv_broadcast(peer, peers, recv_messages) do
    receive do
      :stop ->
        send peer, {:recv_done, recv_messages}

      {:peer_broadcast, sender} ->
        msgs = Map.get(recv_messages, sender, 0)
        recv_messages = Map.put(recv_messages, sender, msgs + 1)

        recv_broadcast(peer, peers, recv_messages)
    end
  end

  def start do
    receive do
      {:bind, id, peers} ->
        receive do
          {:broadcast, max_messages, timeout} ->
            # We spawn a process that only sends broadcasts. This will
            # execute interleaved with the receiver process.
            send_process = spawn(Peer1, :send_broadcast, [self(), peers, %{}, max_messages])
            :timer.send_after(timeout, send_process, :stop)

            :timer.send_after(timeout, self(), :stop)
            recv_broadcast(self(), peers, %{})

            # Once the sender process(component) receives a timeout, it will
            # send back its results. This happens for the receiver as well.
            sent_messages = receive do
              {:send_done, sent_messages} ->
                sent_messages
            end
            recv_messages = receive do
              {:recv_done, recv_messages} ->
                recv_messages
            end

            # The results are centralized and then printed.
            results = centralise(peers, recv_messages, sent_messages)
            IO.puts ["#{inspect id}: ", inspect results]
        end
    end
  end
end
