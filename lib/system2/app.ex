defmodule App do
  defp loop do
    loop()
  end

  def start(_peer) do
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
      {:broadcast, _max_messages, _timeout} ->
        IO.puts ["broadcast"]
    end

    loop()
  end
end
