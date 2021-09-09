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
  def handle_cast({:set, state}, _state) do
    set_to(state)
    {:noreply, state}
  end

  @impl true
  def handle_call(:get, _from, state) do
    {:reply, state, state}
  end

  @spec get() :: state
  def get() do
    GenServer.call(__MODULE__, :get)
  end

  @spec set(state) :: :ok
  def set(state) do
    GenServer.cast(__MODULE__, {:set, state})
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
end
