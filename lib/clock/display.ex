defmodule Clock.Display do
  use GenServer

  require Logger

  @min_duty_cycle 2.7
  @max_duty_cycle 12.0
  @min_angle 0
  @max_angle 186

  @type state :: [0 | 1, ...]

  def start_link(_) do
    GenServer.start_link(__MODULE__, [0, 0, 0, 0, 0, 0, 0], name: __MODULE__)
  end

  @spec get() :: state
  def get() do
    GenServer.call(__MODULE__, :get)
  end

  @spec set(state, integer) :: :ok
  def set(state, milliseconds \\ 300) do
    GenServer.cast(__MODULE__, {:set, state, milliseconds})
  end

  @impl true
  @spec init(state) :: {:ok, state}
  def init(state) do
    set_to(state)
    {:ok, state}
  end

  @impl true
  def handle_cast({:set, end_state, milliseconds}, start_state) do
    end_state = display(start_state, end_state, milliseconds)
    {:noreply, end_state}
  end

  defp display(start_state, end_state, milliseconds) do
    start_time = System.monotonic_time(:millisecond)
    end_time = start_time + milliseconds

    end_state =
      end_state
      |> Enum.zip(start_state)
      |> Enum.map(fn {e, s} -> if e, do: e, else: s end)

    if would_collide?(start_state, end_state) do
      # Moves the sides out of the way, moves the middle to its final position, continue
      display(start_state, [nil, 0, 0, nil, nil, nil, nil], milliseconds)
      |> display([nil, nil, nil, Enum.at(end_state, 3), nil, nil, nil], milliseconds)
      |> display(end_state, start_time, end_time, start_time)
    else
      display(start_state, end_state, start_time, end_time, start_time)
    end
  end

  defp display(start_state, end_state, start_time, end_time, current_time)
       when current_time <= end_time do
    start_state
    |> Enum.zip(end_state)
    |> Enum.map(fn {c, n} ->
      map(current_time, {start_time, end_time}, {c, n})
    end)
    |> set_to()

    current_time = System.monotonic_time(:millisecond)
    display(start_state, end_state, start_time, end_time, current_time)
  end

  defp display(_start_state, end_state, _start_time, _end_time, _current_time) do
    set_to(end_state)
    end_state
  end

  defp would_collide?(start_state, end_state) do
    Enum.at(start_state, 3) != Enum.at(end_state, 3) &&
      ((Enum.at(start_state, 1) == 1 && Enum.at(end_state, 1) == 1) ||
         (Enum.at(start_state, 2) == 1 && Enum.at(end_state, 2) == 1))
  end

  @impl true
  def handle_call(:get, _from, state) do
    {:reply, state, state}
  end

  @spec set_to(state) :: :ok
  defp set_to(state) do
    state
    |> Enum.with_index()
    |> Enum.each(fn {n, ch} ->
      (n * 90 + 45)
      |> angle_to_duty_cycle()
      |> ServoKit.set_pwm_duty_cycle(ch: ch)
    end)
  end

  defp angle_to_duty_cycle(angle),
    do: angle |> map({@min_angle, @max_angle}, {@min_duty_cycle, @max_duty_cycle})

  defp map(x, {in_min, in_max}, {out_min, out_max})
       when is_number(x) and
              is_number(in_min) and is_number(in_max) and
              is_number(out_min) and is_number(out_max) do
    (x - in_min) * (out_max - out_min) / (in_max - in_min) + out_min
  end
end
