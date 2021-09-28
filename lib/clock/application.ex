defmodule Clock.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Clock.Supervisor]

    children =
      [
        # Children for all targets
        Supervisor.child_spec({ServoKit, name: ServoKit2, address: 0x41}, id: ServoKit2),
        Supervisor.child_spec({ServoKit, name: ServoKit1, address: 0x40}, id: ServoKit1),
        Clock.Calibration,
        Clock.Display,
        Clock
      ] ++ children(target())

    Supervisor.start_link(children, opts)
  end

  # List all child processes to be supervised
  def children(:host) do
    [
      # Children that only run on the host
      # Starts a worker by calling: Clock.Worker.start_link(arg)
      # {Clock.Worker, arg},
    ]
  end

  def children(_target) do
    [
      # Children for all targets except host
      # Starts a worker by calling: Clock.Worker.start_link(arg)
      # {Clock.Worker, arg},
    ]
  end

  def target() do
    Application.get_env(:clock, :target)
  end
end
