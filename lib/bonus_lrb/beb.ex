# Alexandru Dan(ad5915) and Maurizio Zen(mz4715)
defmodule Beb7 do
  def run(peers, pl, rb) do
    receive do
      {:beb_broadcast, msg} ->
        Enum.map(peers, fn (peer) ->
          send pl, {:pl_send, peer, msg}
        end)
      {:pl_deliver, from, msg} ->
        send rb, {:beb_deliver, from, msg}
    end

    run(peers, pl, rb)
  end

  def start(_peer) do
    pl = receive do
      {:pl, pl} ->
        pl
    end

    rb = receive do
      {:rb, rb} ->
        rb
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

    run(peers, pl, rb)
  end
end
