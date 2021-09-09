defmodule Clock.Display do
  use GenServer
  @min_duty_cycle 2.7
  @max_duty_cycle 12.0
  @min_angle 0
  @max_angle 186

  @type state :: [0 | 1, ...]

  def start_link(_) do
    GenServer.start_link(__MODULE__, [0, 0, 0, 0, 0, 0, 0], name: __MODULE__)
  end

  @impl true
  @spec init(state) :: {:ok, state}
  def init(state) do
    set_to(state)
    {:ok, state}
  end

  @impl true
  def handle_cast({:set, :num, num}, _state) do
    new_state = clock(num)
    set_to(new_state)
    {:noreply, new_state}
  end

  @impl true
  def handle_call(:get, _from, state) do
    {:reply, state, state}
  end

  @spec get_state() :: state
  def get_state() do
    GenServer.call(__MODULE__, :get)
  end

  @spec set_to_num(0 | 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 | 9) :: :ok
  def set_to_num(num) do
    GenServer.cast(__MODULE__, {:set, :num, num})
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
    do: angle |> ServoKit.map({@min_angle, @max_angle}, {@min_duty_cycle, @max_duty_cycle})

  defp clock(0), do: [1, 1, 1, 0, 1, 1, 1]
  defp clock(1), do: [0, 0, 1, 0, 0, 1, 0]
  defp clock(2), do: [1, 0, 1, 1, 1, 0, 1]
  defp clock(3), do: [1, 0, 1, 1, 0, 1, 1]
  defp clock(4), do: [0, 1, 1, 1, 0, 1, 0]
  defp clock(5), do: [1, 1, 0, 1, 0, 1, 1]
  defp clock(6), do: [1, 1, 0, 1, 1, 1, 1]
  defp clock(7), do: [1, 0, 1, 0, 0, 1, 0]
  defp clock(8), do: [1, 1, 1, 1, 1, 1, 1]
  defp clock(9), do: [1, 1, 1, 1, 0, 1, 0]
end
