defmodule App do
  def run(pl, pls) do


    run(pl, pls)
  end

  def start do
    pl = receive do
      {:pl, pl} ->
        pl
    end

    pls = receive do
      {:pl_deliver, _from, {:pls, pls}} ->
        pls
    end

    IO.puts ["app.pl:", inspect pl]
    IO.puts ["app.pls:", inspect pls]

    run(pl, pls)
  end
end
