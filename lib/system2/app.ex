defmodule App do
  def loop do
    loop()
  end

  def start do
    pl = receive do
      {:pl, pl} ->
        pl
    end

    peers = receive do
      {:bound, peers} ->
        peers
    end

    IO.puts ["app.pl:", inspect pl]
    IO.puts ["app.peers:", inspect peers]

    receive do
      {:broadcast, max_messages, timeout} ->
        IO.puts ["broadcast"]
    end

    loop()
  end
end
