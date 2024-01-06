defmodule DecimalFmt.MixProject do
  use Mix.Project

  def project do
    [
      app: :decimal_fmt,
      version: "0.1.0",
      elixir: "~> 1.15",
      start_permanent: Mix.env() == :prod,
      description: description(),
      package: package(),
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:ex_doc, "~> 0.31.0", only: :dev},
      {:mneme, "~> 0.4.3", only: [:dev, :test]}
    ]
  end

  defp description() do
    """
    Advanced formatting of decimal numbers.
    """
  end

  defp package() do
    [
      files: ["lib", "mix.exs", "README", "LICENSE"],
      maintainers: ["Michael Neumann"],
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/mneumann/elixir-decimal-fmt"}
    ]
  end
end
