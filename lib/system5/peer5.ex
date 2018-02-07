# Alexandru Dan(ad5915) and Maurizio Zen(mz4715)
defmodule Peer5 do
  def start do
    pl  = spawn(LPL5,  :start, [self()])
    beb = spawn(Beb5, :start, [self()])
    app = spawn(App5, :start, [self()])

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

    # When we receive an exit message, we kill all the components.
    receive do
      :exit ->
        Process.exit(app, :kill)
        Process.exit(pl, :kill)
        Process.exit(beb, :kill)
    end
  end
end
