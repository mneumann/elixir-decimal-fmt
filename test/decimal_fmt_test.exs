defmodule DecimalFmtTest do
  use ExUnit.Case, async: true
  use Mneme
  doctest DecimalFmt

  test "greets the world" do
    auto_assert :world <- DecimalFmt.hello()
  end
end
