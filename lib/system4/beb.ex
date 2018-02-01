defmodule Beb4 do
  def run(peers, pl, app) do
    receive do
      {:beb_broadcast, msg} ->
        Enum.map(peers, fn (peer) ->
          send pl, {:pl_send, peer, msg}
        end)
      {:pl_deliver, from, msg} ->
        send app, {:beb_deliver, from, msg}
    end

    run(peers, pl, app)
  end

  def start(_peer) do
    pl = receive do
      {:pl, pl} ->
        pl
    end

    app = receive do
      {:app, app} ->
        app
    end

    peers = receive do
      {:peers, peers} ->
        peers
    end
    send app, {:peers, peers}

    run(peers, pl, app)
  end
end
