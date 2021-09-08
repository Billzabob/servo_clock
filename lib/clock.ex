defmodule Clock do
  alias Clock.Display

  def test() do
    Display.set_to_num(0)
    :timer.sleep(1000)
    Display.set_to_num(1)
    :timer.sleep(1000)
    Display.set_to_num(2)
    :timer.sleep(1000)
    Display.set_to_num(3)
    :timer.sleep(1000)
    Display.set_to_num(4)
    :timer.sleep(1000)
    Display.set_to_num(5)
    :timer.sleep(1000)
    Display.set_to_num(6)
    :timer.sleep(1000)
    Display.set_to_num(7)
    :timer.sleep(1000)
    Display.set_to_num(8)
    :timer.sleep(1000)
    Display.set_to_num(9)
  end
end
