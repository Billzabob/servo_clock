defmodule Clock.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  alias Clock.Display

  def start(_type, _args) do
    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Clock.Supervisor]

    children = [
      # Children for all targets
      Supervisor.child_spec({ServoKit, name: S2, address: 0x41}, id: S2),
      Supervisor.child_spec({ServoKit, name: S1, address: 0x40}, id: S1),
      Supervisor.child_spec(
        {Display,
         name: D1,
         servo: S1,
         channel_offset: 0,
         calibration_max: [8.85, 9.15, 9.45, 9.65, 9.25, 9.75, 9.76],
         calibration_min: [4.05, 4.65, 4.95, 4.95, 4.35, 5.05, 4.35]},
        id: D1
      ),
      Supervisor.child_spec(
        {Display,
         name: D2,
         servo: S1,
         channel_offset: 8,
         calibration_max: List.duplicate(9.45, 7),
         calibration_min: List.duplicate(4.95, 7)},
        id: D2
      ),
      Supervisor.child_spec(
        {Display,
         name: D3,
         servo: S2,
         channel_offset: 0,
         calibration_max: [8.65, 9.15, 9.75, 9.75, 9.75, 9.95, 9.15],
         calibration_min: [4.35, 4.65, 5.25, 4.95, 4.95, 5.25, 4.55]},
        id: D3
      ),
      Supervisor.child_spec(
        {Display,
         name: D4,
         servo: S2,
         channel_offset: 8,
         calibration_max: [9.75, 9.45, 9.45, 8.55, 9.75, 8.55, 8.25],
         calibration_min: [4.95, 4.55, 4.35, 3.95, 4.95, 3.95, 4.05]},
        id: D4
      ),
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
