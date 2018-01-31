defmodule Peer2 do
  def loop do
    loop()
  end

  def start do
    pl  = spawn(PL, :start, [])
    app = spawn(App, :start, [])

    send pl, {:peer, self()}
    send pl, {:app, app}
    send app, {:pl, pl}

    receive do
      {:who_is_pl, system} ->
        send system, {:pl_is, self(), pl}
    end

    loop()
  end
end
