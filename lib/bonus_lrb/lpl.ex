# Alexandru Dan(ad5915) and Maurizio Zen(mz4715)
defmodule LPL7 do
  def run(peer, beb, pfd, peer_map, reliablity) do
    receive do
      {:pl_send, dest, msg} ->
        dest_pl = Map.get(peer_map, dest)

        if :rand.uniform <= reliablity / 100.0 do
          send dest_pl, {:pl_deliver, peer, msg}
        end

      {:pl_deliver, from, msg} ->
        send beb, {:pl_deliver, from, msg}

      {:pl_send2, dest, msg} ->
        dest_pl = Map.get(peer_map, dest)

        if :rand.uniform <= reliablity / 100.0 do
          send dest_pl, {:pl_deliver2, peer, msg}
        end

      {:pl_deliver2, from, msg} ->
        send pfd, {:pl_deliver2, from, msg}
    end

    run(peer, beb, pfd, peer_map, reliablity)
  end

  def start(peer) do
    beb = receive do
      {:beb, beb} ->
        beb
    end

    rb = receive do
      {:rb, rb} ->
        rb
    end

    pfd = receive do
      {:pfd, pfd} ->
        pfd
    end

    {peer_map, reliablity} = receive do
      {:bind, peer_map, reliablity} ->
        {peer_map, reliablity}
    end

    send beb, {:peers, Map.keys(peer_map)}
    send rb, {:peers, Map.keys(peer_map)}
    send pfd, {:peers, Map.keys(peer_map)}

    run(peer, beb, pfd, peer_map, reliablity)
  end
end
