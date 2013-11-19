defmodule Wire.Mixfile do
  use Mix.Project

  def project do
    [ app: :wire,
      version: "0.0.1",
      elixir: "~> 0.10.3",
      deps: deps,
      deps_path: Path.expand("~/elixir_deps/wire")
    ]
  end

  # Configuration for the OTP application
  def application do
    [
      mod: { Wire, [] },
      applications: [:cowboy]
    ]
  end

  # Returns the list of dependencies in the format:
  # { :foobar, "~> 0.1", git: "https://github.com/elixir-lang/foobar.git" }
  defp deps do
    [
      { :cowboy, github: "extend/cowboy", tag: "0.8.6" }
    ]
  end
end
