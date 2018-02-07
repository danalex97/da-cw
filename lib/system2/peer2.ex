# Alexandru Dan(ad5915) and Maurizio Zen(mz4715)
defmodule Peer2 do
  def loop do
    loop()
  end

  def start do
    pl  = spawn(PL2, :start, [self()])
    app = spawn(App2, :start, [self()])

    send pl, {:app, app}
    send app, {:pl, pl}

    receive do
      {:id, id} ->
        send app, {:id, id}
    end

    # Once the pl component is created, we send back its identity
    # to the system such that the system has to bind the pl components.
    receive do
      {:who_is_pl, system} ->
        send system, {:pl_is, self(), pl}
    end

    # The broadcast request is routed to the app component so that the
    # System is not aware of the app component.
    receive do
      {:broadcast, max_messages, timeout} ->
        send app, {:broadcast, max_messages, timeout}
    end

    loop()
  end
end
