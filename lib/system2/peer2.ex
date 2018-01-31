defmodule Peer2 do
  def loop do
    loop()
  end

  def start do
    pl  = spawn(PL, :start, [self()])
    app = spawn(App, :start, [self()])

    send pl, {:app, app}
    send app, {:pl, pl}

    receive do
      {:who_is_pl, system} ->
        send system, {:pl_is, self(), pl}
    end

    receive do
      {:broadcast, max_messages, timeout} ->
        send app, {:broadcast, max_messages, timeout}
    end

    loop()
  end
end
