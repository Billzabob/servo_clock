defmodule Clock.Animator do
  alias Clock.Display

  def animate(time) do
    Display.set(clock(time))
  end

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
