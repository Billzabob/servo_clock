defmodule Clock.Animator do
  import Clock.Display

  require Logger

  def set_time(hour, minute) do
    Logger.info("Setting time to #{hour}:#{minute}")
    set(D2, hour |> div(10) |> digit())
    set(D3, hour |> rem(10) |> digit())
    set(D4, minute |> div(10) |> digit())
    set(D1, minute |> rem(10) |> digit())
  end

  def count() do
    Enum.each(0..9, fn num ->
      Enum.each([D1, D2, D3, D4], fn display ->
        set(display, digit(num))
        delay(display, 500)
      end)
    end)
  end

  def digit(0), do: [1, 1, 1, 0, 1, 1, 1]
  def digit(1), do: [0, 0, 1, 0, 0, 1, 0]
  def digit(2), do: [1, 0, 1, 1, 1, 0, 1]
  def digit(3), do: [1, 0, 1, 1, 0, 1, 1]
  def digit(4), do: [0, 1, 1, 1, 0, 1, 0]
  def digit(5), do: [1, 1, 0, 1, 0, 1, 1]
  def digit(6), do: [1, 1, 0, 1, 1, 1, 1]
  def digit(7), do: [1, 0, 1, 0, 0, 1, 0]
  def digit(8), do: [1, 1, 1, 1, 1, 1, 1]
  def digit(9), do: [1, 1, 1, 1, 0, 1, 0]
end
