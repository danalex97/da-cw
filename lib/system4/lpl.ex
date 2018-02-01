defmodule LPL do
  @reliablity 50

  def run(peer, beb, peer_map) do
    receive do
      {:pl_send, dest, msg} ->
        dest_pl = Map.get(peer_map, dest)

        if :rand.uniform <= @reliablity / 100.0 do
          send dest_pl, {:pl_deliver, peer, msg}
        end

      {:pl_deliver, from, msg} ->
        send beb, {:pl_deliver, from, msg}
    end

    run(peer, beb, peer_map)
  end

  def start(peer) do
    beb = receive do
      {:beb, beb} ->
        beb
    end

    peer_map = receive do
      {:bind, peer_map} ->
        peer_map
    end

    send beb, {:peers, Map.keys(peer_map)}

    run(peer, beb, peer_map)
  end
end
