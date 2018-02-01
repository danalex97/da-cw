defmodule Peer4 do
  def loop do
    loop()
  end

  def start do
    pl  = spawn(LPL,  :start, [self()])
    beb = spawn(Beb4, :start, [self()])
    app = spawn(App4, :start, [self()])

    send pl,  {:beb, beb}
    send beb, {:pl, pl}

    send app, {:beb, beb}
    send beb, {:app, app}

    receive do
      {:id, id} ->
        send app, {:id, id}
    end

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