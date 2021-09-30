defmodule Clock.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  import Supervisor

  alias Clock.Display

  def start(_type, _args) do
    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Clock.Supervisor]

    children = [
      # Children for all targets
      child_spec({ServoKit, name: S2, address: 0x41}, id: S2),
      child_spec({ServoKit, name: S1, address: 0x40}, id: S1),
      child_spec({Display, name: D1, servo: S1, channel_offset: 0, calibration: [-11, -7, 5, 1, -1, -2, -8]}, id: D1),
      child_spec({Display, name: D2, servo: S1, channel_offset: 8, calibration: [0, 0, 0, 0, 0, 0, 0]}, id: D2),
      child_spec({Display, name: D3, servo: S2, channel_offset: 0, calibration: [0, 0, 0, 0, 0, 0, 0]}, id: D3),
      child_spec({Display, name: D4, servo: S2, channel_offset: 8, calibration: [0, 0, 0, 0, 0, 0, 0]}, id: D4),
      Clock
    ]

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
