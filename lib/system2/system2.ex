defmodule System2 do
  @n 5
  @max_messages 1000
  @timeout      3000

  defp loop do
    loop()
  end

  defp local_spawn(_idx) do
    spawn(Peer2, :start, [])
  end

  defp network_spawn(idx) do
    Node.spawn(
        :'peer#{idx}@peer#{idx}.localdomain',
        Peer2,
        :start,
        [])
  end

  defp local_setup() do
  end

  defp network_setup() do
    :timer.sleep(:timer.seconds(10))
  end

  defp start(spawn_function, setup) do
    setup . ()

    peers = Enum.to_list(for idx <- 0..(@n-1), do:
      spawn_function . (idx + 1))

    Enum.map(peers, fn (peer) ->
      send peer, {:who_is_pl, self()}
    end)

    # peer => pl map
    peer_map = Enum.reduce(0..(@n-1), %{}, fn(_idx, mp) ->
      {peer, pl} = receive do
        {:pl_is, peer, pl} ->
          {peer, pl}
      end

      Map.put(mp, peer, pl)
    end)

    # bind pls to pl -- should be from app to pl
    pls = Enum.to_list(for peer <- peers, do:
      Map.get(peer_map, peer))
    Enum.map(pls, fn (pl) ->
      send pl, {:bind, peer_map}
    end)

    #broadcast
    Enum.map(peers, fn (peer) ->
      send peer, {:broadcast, @max_messages, @timeout}
    end)

    loop()
  end

  def local_start() do
    start(&local_spawn/1, &local_setup/0)
  end

  def network_start() do
    start(&network_spawn/1, &network_setup/0)
  end

end
