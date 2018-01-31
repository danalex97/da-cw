defmodule Peer2 do
  def loop do
    loop()
  end

  def start do
    pl  = spawn(PL, :start, [])
    _app = spawn(App, :start, [])

    receive do
      {:bind, id, peers} ->
        send pl, {:bind, id, peers}
    end

    loop()
  end
end
