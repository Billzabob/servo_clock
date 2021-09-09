defmodule Clock do
  use Task, restart: :permanent

  alias Clock.Animator

  def start_link(_) do
    Task.start_link(__MODULE__, :run, [])
  end

  def run() do
    %{minute: minute, second: second, microsecond: {microsecond, _}} = Time.utc_now()
    Animator.animate(rem(minute, 10))
    time_to_wait_seconds = 60 - second - 1
    time_to_wait_micro = 1_000_000 - microsecond
    time_to_wait_milliseconds = time_to_wait_seconds * 1000 + ceil(time_to_wait_micro / 1000)
    :timer.sleep(time_to_wait_milliseconds)
    run()
  end
end
