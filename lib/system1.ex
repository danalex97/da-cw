defmodule System1 do
  @n 5
  @max_messages 1000
  @timeout      3000

  defp loop do
    loop()
  end

  def start do
    peers = Enum.to_list(for _ <- 0..(@n-1), do:
      spawn(Peer1, :start, []))

    Enum.map(Enum.zip(peers, 1..@n), fn ({peer, id}) ->
      send peer, {:bind, id, peers}
    end)

    Enum.map(peers, fn (peer) ->
      send peer, {:broadcast, @max_messages, @timeout}
    end)

    loop()
  end
end
