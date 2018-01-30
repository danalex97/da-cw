  defmodule Peer1 do
    def send_broadcast(self, peers, sent_messages) do
      Enum.map(peers, fn (receiver) ->
        IO.puts ["#{inspect self} SEND: ", inspect receiver]
        send receiver, {:peer_broadcast, self}

        msgs = Map.get(sent_messages, receiver, 0)
        Map.put(sent_messages, receiver, msgs + 1)
      end)

      send_broadcast(self, peers, sent_messages)
    end

    def recv_broadcast(self, peers, recv_messages) do
      receive do
        {:peer_broadcast, sender} ->
          IO.puts ["#{inspect self} RECV: ", inspect sender]

          msgs = Map.get(recv_messages, sender, 0)
          Map.put(recv_messages, sender, msgs + 1)
      end

      recv_broadcast(self, peers, recv_messages)
    end

    defp loop do
      loop()
    end

    def start do
      receive do
        {:bind, peers} ->
          IO.puts ["#{inspect self()}: ", inspect peers]

          receive do
            {:broadcast, _max_messages, _timeout} ->
              sent_messages = %{}
              recv_messages = %{}

              spawn(Peer1, :send_broadcast, [self(), peers, sent_messages])
              recv_broadcast(self(), peers, recv_messages)
          end

          loop()
      end
    end
  end
