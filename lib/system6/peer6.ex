# Alexandru Dan(ad5915) and Maurizio Zen(mz4715)
defmodule Peer6 do
  def start do
    pl  = spawn(LPL6, :start, [self()])
    beb = spawn(Beb6, :start, [self()])
    app = spawn(App6, :start, [self()])
    rb = spawn(RB, :start, [self()])

    send pl,  {:beb, beb}
    send beb, {:pl, pl}

    send rb, {:beb, beb}
    send beb, {:rb, rb}
    send beb, {:app, app}

    send app, {:rb, rb}
    send rb, {:app, app}

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

    receive do
      :exit ->
        Process.exit(app, :kill)
        Process.exit(pl, :kill)
        Process.exit(beb, :kill)
    end
  end
end
