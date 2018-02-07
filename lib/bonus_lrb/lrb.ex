# Alexandru Dan(ad5915) and Maurizio Zen(mz4715)
defmodule LRB do
  def run(beb, app, peer, correct, process_msgs) do
    # For details on the component's implementation see the report.
    receive do
      {:rb_broadcast, m} ->
        send beb, {:beb_broadcast, {:rb_data, peer, m}}
        run(beb, app, peer, correct, process_msgs)
      {:pfd_crash, crashed} ->
        IO.puts ["Crashed process detected: ", inspect crashed]

        Enum.map(process_msgs[crashed], fn(msg) ->
          send beb, {:beb_broadcast, {:rb_data, crashed, msg}}
        end)
        correct = MapSet.delete(correct, crashed)
        run(beb, app, peer, correct, process_msgs)

      {:beb_deliver, _from, {:rb_data, sender, m} = rb_m} ->
        if MapSet.member?(process_msgs[sender], m) do
          run(beb, app, peer, correct, process_msgs)
        else
          send app, {:rb_deliver, sender, m}
          sender_msgs = MapSet.put(process_msgs[sender], m)
          process_msgs = Map.put(process_msgs, sender, sender_msgs)

          if not Enum.member?(correct, sender) do
            send beb, {:beb_broadcast, rb_m}
          end

          run(beb, app, peer, correct, process_msgs)
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

    correct = receive do
      {:peers, peers} ->
        Enum.reduce(peers, MapSet.new(), fn(p, result) ->
          MapSet.put(result, p)
        end)
    end

    process_msgs = Map.new(correct, fn (p) ->
      {p, MapSet.new()}
    end)

    run(beb, app, peer, correct, process_msgs)
  end
end
