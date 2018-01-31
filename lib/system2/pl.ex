defmodule PL do
  def loop do
    loop()
  end

  def run(id, peers) do
    IO.puts ["start ", inspect id]
    loop()
  end

  def start do
    receive do
      {:bind, id, peers} ->
        run(id, peers)
    end
  end
end
