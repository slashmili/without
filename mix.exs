defmodule Without.MixProject do
  use Mix.Project

  @version "0.1.0"

  def project do
    [
      app: :without,
      version: @version,
      elixir: "~> 1.12",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      name: "Without",
      description: "Error handling made readable",
      package: package(),
      docs: [source_ref: "v#{@version}"],
      source_url: "https://github.com/slashmili/without"
    ]
  end

  def application do
    [extra_applications: [:logger]]
  end

  def deps do
    [{:ex_doc, "~> 0.34", only: :dev, runtime: false}]
  end

  def package do
    [
      maintainers: ["Milad Rastian"],
      name: "without",
      licenses: ["Apache-2.0"],
      links: %{"GitHub" => "https://github.com/slashmili/without"}
    ]
  end
end
