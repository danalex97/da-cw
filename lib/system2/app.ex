defmodule App do
  def loop do
    loop()
  end

  def run(_pl, _peer_map) do
    loop()
  end

  def start do
    pl = receive do
      {:pl, pl} ->
        pl
    end

    peer_map = receive do
      {:pl_deliver, _from, {:peer_map, peer_map}} ->
        peer_map
    end

    IO.puts ["app.pl:", inspect pl]
    IO.puts ["app.pls:", inspect peer_map]

    run(pl, peer_map)
  end
end
