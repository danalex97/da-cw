# Alexandru Dan(ad5915) and Maurizio Zen(mz4715)
defmodule System1 do
  defp loop do
    loop()
  end

  defp local_spawn(_idx) do
    spawn(Peer1, :start, [])
  end

  defp network_spawn(idx) do
    Node.spawn(
        :'peer#{idx}@peer#{idx}.localdomain',
        Peer1,
        :start,
        [])
  end

  defp local_setup() do
  end

  defp network_setup() do
    :timer.sleep(:timer.seconds(10))
  end

  defp start(spawn_function, setup) do
    [n, max_messages, timeout, _rel] = Enum.map(System.argv(), fn(arg) ->
      {i, _} = Integer.parse(arg)
      i
    end)

    setup . ()

    peers = Enum.to_list(for idx <- 0..(n-1), do:
      spawn_function . (idx + 1))

    Enum.map(Enum.zip(peers, 1..n), fn ({peer, id}) ->
      send peer, {:bind, id, peers}
    end)

    Enum.map(peers, fn (peer) ->
      send peer, {:broadcast, max_messages, timeout}
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
