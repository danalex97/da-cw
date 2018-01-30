  defmodule Peer1 do
    def centralise(id, peers, recv_messages, sent_messages) do
      results = Enum.reduce(peers, [], fn (peer, results) ->
        sent = Map.get(sent_messages, peer, 0)
        recv = Map.get(recv_messages, peer, 0)

        results ++ [{sent, recv}]
      end)

      IO.puts ["#{inspect id}: ", inspect results]
    end

    def send_broadcast(self, peers, sent_messages, max_messages) do
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

      sent_messages = Enum.reduce(peers, sent_messages, fn (receiver, sent_messages) ->
        # IO.puts ["#{inspect self} SEND: ", inspect receiver]
        send receiver, {:peer_broadcast, self}

        msgs = Map.get(sent_messages, receiver, 0)
        sent_messages = Map.put(sent_messages, receiver, msgs + 1)

        sent_messages
      end)

      send_broadcast(self, peers, sent_messages, max_messages - 1)
    end

    def recv_broadcast(self, peers, recv_messages, timeout, send_process, id) do
      receive do
        {:peer_broadcast, sender} ->
          # IO.puts ["#{inspect self} RECV: ", inspect sender]

          msgs = Map.get(recv_messages, sender, 0)
          recv_messages = Map.put(recv_messages, sender, msgs + 1)

          recv_broadcast(self, peers, recv_messages, timeout, send_process, id)
        {:timeout} ->
          send send_process, :stop
          receive do
            {:stop, sent_messages} ->
              centralise(id, peers, recv_messages, sent_messages)
          end
        {:stop, sent_messages} ->
          centralise(id, peers, recv_messages, sent_messages)
      end
    end

    defp loop do
      loop()
    end

    def start do
      receive do
        {:bind, id, peers} ->
          receive do
            {:broadcast, max_messages, timeout} ->
              sent_messages = %{}
              recv_messages = %{}

              send_process = spawn(Peer1, :send_broadcast, [self(), peers, sent_messages, max_messages])
              :timer.send_after(timeout, self(), {:timeout})

              recv_broadcast(self(), peers, recv_messages, timeout, send_process, id)
          end

          loop()
      end
    end
  end
