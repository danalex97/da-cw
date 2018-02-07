defmodule PFD do
  @timeout 1000

  def run(pl, lrb, peer, processes, alive, detected) do
    # IO.puts ["detected ", inspect detected]
    # IO.puts ["alive ", inspect alive]

    receive do
      {:pl_deliver2, from, :heartbeat_request} ->
        send pl, {:pl_send2, from, :heartbeat_reply}
        run(pl, lrb, peer, processes, alive, detected)

      {:pl_deliver2, from, :heartbeat_reply} ->
        run(pl, lrb, peer, processes, alive ++ [from], detected)
      :timeout ->
        new_detected_failures =
          for p <- processes,
            not Enum.member?(alive, p) and
            not Enum.member?(detected, p),
          do: p

        Enum.map(new_detected_failures, fn(p) ->
          send lrb, {:pfd_crash, p}
        end)
        Enum.map(alive, fn(p) ->
          send pl, {:pl_send2, p, :heartbeat_request}
        end)

        :timer.send_after(@timeout, self(), :timeout)
        run(pl, lrb, peer, alive, [], detected ++ new_detected_failures)
    end
  end

  def start(peer) do
    pl = receive do
      {:pl, pl} ->
        pl
    end

    lrb = receive do
      {:rb, rb} ->
        rb
    end

    peers = receive do
      {:peers, peers} ->
        peers
    end

    :timer.send_after(@timeout, self(), :timeout)
    run(pl, lrb, peer, peers, peers, [])
  end
end
