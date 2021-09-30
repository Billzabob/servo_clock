defmodule Clock.Display do
  use GenServer

  require Logger

  @min_duty_cycle 2.7
  @max_duty_cycle 12.0
  @min_angle 0
  @max_angle 186

  defstruct(
    calibration: List.duplicate(0, 7),
    servo: nil,
    channel_offset: 0,
    state: List.duplicate(0, 7)
  )

  def start_link(opts),
    do: GenServer.start_link(__MODULE__, opts, name: opts[:name] || __MODULE__)

  def get(name), do: GenServer.call(name, :get)
  def set(name, state, milliseconds \\ 100), do: GenServer.cast(name, {:set, state, milliseconds})
  def get_calibration(name), do: GenServer.call(name, :get_calibration)
  def set_calibration(name, offsets), do: GenServer.cast(name, {:set_calibration, offsets})
  def adjust_calibration(name, index, angle), do: GenServer.cast(name, {:adjust_calibration, index, angle})
  def delay(name, milliseconds \\ 100), do: GenServer.cast(name, {:set, List.duplicate(nil, 7), milliseconds})

  def init(opts) do
    state =
      __struct__(
        calibration: opts[:calibration],
        servo: opts[:servo],
        channel_offset: opts[:channel_offset],
        state: List.duplicate(0, 7)
      )

    start_up_sequence(opts[:name])
    set_to(state.state, state)
    {:ok, state}
  end

  def handle_cast({:set, end_state, milliseconds}, state) do
    end_state = display(state, end_state, milliseconds)
    {:noreply, end_state}
  end

  def handle_cast({:set_calibration, offsets}, state) do
    {:noreply, %{state | calibration: offsets}}
  end

  def handle_cast({:adjust_calibration, index, angle}, state) do
    adjusted_calibration = List.update_at(state.calibration, index, &(&1 + angle))
    {:noreply, %{state | calibration: adjusted_calibration}}
  end

  def handle_call(:get, _from, state), do: {:reply, state, state}
  def handle_call(:get_calibration, _from, state), do: {:reply, state.calibration, state}

  defp display(state, end_state, milliseconds) do
    start_time = System.monotonic_time(:millisecond)
    end_time = start_time + milliseconds

    end_state =
      end_state
      |> Enum.zip(state.state)
      |> Enum.map(fn {e, s} -> if e, do: e, else: s end)

    if would_collide?(state.state, end_state) do
      # Moves the sides out of the way, moves the middle to its final position, continue
      display(state, [nil, 0, 0, nil, nil, nil, nil], milliseconds)
      |> display([nil, nil, nil, Enum.at(end_state, 3), nil, nil, nil], milliseconds)
      |> display(end_state, milliseconds)
    else
      display(state, end_state, start_time, end_time, start_time)
    end
  end

  defp display(state, end_state, start_time, end_time, current_time)
       when current_time < end_time do
    state.state
    |> Enum.zip(end_state)
    |> Enum.map(fn {c, n} ->
      map(current_time, {start_time, end_time}, {c, n})
    end)
    |> set_to(state)

    current_time = System.monotonic_time(:millisecond)
    display(state, end_state, start_time, end_time, current_time)
  end

  defp display(state, end_state, _start_time, _end_time, _current_time) do
    set_to(end_state, state)
    %{state | state: end_state}
  end

  defp would_collide?(start_state, end_state) do
    Enum.at(start_state, 3) != Enum.at(end_state, 3) &&
      ((Enum.at(start_state, 1) == 1 && Enum.at(end_state, 1) == 1) ||
         (Enum.at(start_state, 2) == 1 && Enum.at(end_state, 2) == 1))
  end

  defp set_to(end_state, state) do
    end_state
    |> invert_some()
    |> Enum.map(fn n -> n * 90 + 45 end)
    |> Enum.zip_with(state.calibration, &+/2)
    |> Enum.with_index()
    |> Enum.each(fn {n, ch} ->
      ServoKit.set_pwm_duty_cycle(state.servo, angle_to_duty_cycle(n), ch: ch + state.channel_offset)
    end)
  end

  defp invert_some(state) do
    state
    |> List.update_at(1, fn _ -> 1 - Enum.at(state, 1) end)
    |> List.update_at(5, fn _ -> 1 - Enum.at(state, 5) end)
    |> List.update_at(6, fn _ -> 1 - Enum.at(state, 6) end)
  end

  defp angle_to_duty_cycle(angle),
    do: angle |> map({@min_angle, @max_angle}, {@min_duty_cycle, @max_duty_cycle})

  defp map(x, {in_min, in_max}, {out_min, out_max})
       when is_number(x) and
              is_number(in_min) and is_number(in_max) and
              is_number(out_min) and is_number(out_max) do
    (x - in_min) * (out_max - out_min) / (in_max - in_min) + out_min
  end

  defp start_up_sequence(name) do
    set(name, List.duplicate(0, 7))
    set(name, update_index(6, 1))
    set(name, update_index(5, 1))
    set(name, update_index(4, 1))
    set(name, update_index(3, 1))
    set(name, update_index(2, 1))
    set(name, update_index(1, 1))
    set(name, update_index(0, 1))
    delay(name, 500)
    set(name, update_index(0, 0))
    set(name, update_index(1, 0))
    set(name, update_index(2, 0))
    set(name, update_index(3, 0))
    set(name, update_index(4, 0))
    set(name, update_index(5, 0))
    set(name, update_index(6, 0))
  end

  defp update_index(index, value), do: List.duplicate(nil, 7) |> List.insert_at(index, value)
end
