defmodule PL do

  def run(app, pls) do
    receive do
      {:pl_send, dest, msg} ->
        send dest, {:pl_deliver, app, msg}

      {:pl_deliver, from, msg} ->
        send app, {:pl_deliver, from, msg}
    end

    run(app, pls)
  end

  def start do
    app = receive do
      {:app, app} ->
        app
    end

    pls = receive do
      {:bind, pls} ->
        pls
    end

    IO.puts ["pl.app:", inspect app]
    IO.puts ["pl.pls:", inspect pls]

    run(app, pls)
  end
end
