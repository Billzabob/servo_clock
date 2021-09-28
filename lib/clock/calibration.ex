defmodule Clock.Calibration do
  use Agent

  def start_link(_opts) do
    Agent.start_link(fn -> [-11, -7, 5, 10, -1, -2, -8] end, name: __MODULE__)
  end

  def get_offsets(), do: Agent.get(__MODULE__, fn state -> state end)

  def set_offsets(offsets), do: Agent.update(__MODULE__, fn _offsets -> offsets end)

  def adjust_offset(index, angle) do
    Agent.update(__MODULE__, fn state ->
      List.update_at(state, index, &(&1 + angle))
    end)
  end
end
