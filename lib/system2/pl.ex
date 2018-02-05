# Alexandru Dan(ad5915) and Maurizio Zen(mz4715)
defmodule PL2 do

  def run(peer, app, peer_map) do
    receive do
      {:pl_send, dest, msg} ->
        dest_pl = Map.get(peer_map, dest)
        send dest_pl, {:pl_deliver, peer, msg}

      {:pl_deliver, from, msg} ->
        send app, {:pl_deliver, from, msg}
    end

    run(peer, app, peer_map)
  end

  def start(peer) do
    app = receive do
      {:app, app} ->
        app
    end

    peer_map = receive do
      {:bind, peer_map} ->
        peer_map
    end

    send app, {:bound, Map.keys(peer_map)}

    run(peer, app, peer_map)
  end
end
