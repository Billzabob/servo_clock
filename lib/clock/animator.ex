defmodule Clock.Animator do
  alias Clock.Display

  def animate(time) do
    Display.set(clock(time))
  end

  def clock(0), do: [1, 1, 1, 0, 1, 1, 1]
  def clock(1), do: [0, 0, 1, 0, 0, 1, 0]
  def clock(2), do: [1, 0, 1, 1, 1, 0, 1]
  def clock(3), do: [1, 0, 1, 1, 0, 1, 1]
  def clock(4), do: [0, 1, 1, 1, 0, 1, 0]
  def clock(5), do: [1, 1, 0, 1, 0, 1, 1]
  def clock(6), do: [1, 1, 0, 1, 1, 1, 1]
  def clock(7), do: [1, 0, 1, 0, 0, 1, 0]
  def clock(8), do: [1, 1, 1, 1, 1, 1, 1]
  def clock(9), do: [1, 1, 1, 1, 0, 1, 0]

  def fun_stuff() do
    Display.set(List.duplicate(0, 7))
    Display.set(update_index(6, 1))
    Display.set(update_index(5, 1))
    Display.set(update_index(4, 1))
    Display.set(update_index(3, 1))
    Display.set(update_index(2, 1))
    Display.set(update_index(1, 1))
    Display.set(update_index(0, 1))
    Display.set(update_index(0, 0))
    Display.set(update_index(1, 0))
    Display.set(update_index(2, 0))
    Display.set(update_index(3, 0))
    Display.set(update_index(4, 0))
    Display.set(update_index(5, 0))
    Display.set(update_index(6, 0))
  end

  def update_index(index, value) do
    List.duplicate(nil, 7) |> List.insert_at(index, value)
  end
end
