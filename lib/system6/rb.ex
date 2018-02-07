# Alexandru Dan(ad5915) and Maurizio Zen(mz4715)
defmodule RB do
  def run(beb, app, peer, delivered) do
    receive do
      {:rb_broadcast, m} ->
        send beb, {:beb_broadcast, {:rb_data, peer, m}}
        run(beb, app, peer, delivered)
      {:beb_deliver, _from, {:rb_data, sender, m} = rb_m} ->
        if MapSet.member?(delivered, m) do
          # We prevent duplicate messages to be delivered.
          run(beb, app, peer, delivered)
        else
          # When we receive a beb_deliver, we reboradcast the message.
          # This ensures that messages originating from processes that will
          # fail will be delivered to all correct processes.
          send app, {:rb_deliver, sender, m}
          send beb, {:beb_broadcast, rb_m}
          run(beb, app, peer, MapSet.put(delivered, m))
        end
    end
  end

  def start(peer) do
    beb = receive do
      {:beb, beb} ->
        beb
    end

    app = receive do
      {:app, app} ->
        app
    end

    run(beb, app, peer, MapSet.new())
  end
end
