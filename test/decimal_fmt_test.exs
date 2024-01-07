defmodule DecimalFmtTest do
  use ExUnit.Case, async: true
  use Mneme
  doctest DecimalFmt
  alias DecimalFmt.DecimalRepr

  test "it converts string into decimal representation" do
    auto_assert {[1], []} <- DecimalRepr.from_string("1")
    auto_assert {[1], [0]} <- DecimalRepr.from_string("1.0")
    auto_assert {[1], [0, 1, 0]} <- DecimalRepr.from_string("1.010")
    auto_assert {[0, 0, 1], [0, 1, 0, 0, 0]} <- DecimalRepr.from_string("001.01000")

    auto_assert {[1, 2, 3, 4, 5, 6], [0, 1, 0, 0, 0, 1, 1, 1, 2, 3, 4, 0, 0]} <-
                  DecimalRepr.from_string("123456.0100011123400")

    auto_assert_raise BadFunctionError, DecimalRepr.from_string("")
    auto_assert_raise BadFunctionError, DecimalRepr.from_string("123456.")
    auto_assert_raise BadFunctionError, DecimalRepr.from_string(".1")
    auto_assert_raise FunctionClauseError, DecimalRepr.from_string("1.2a")
  end

  test "it formats decimals" do
    format_spec = %DecimalFmt.FormatSpec{
      precision: nil,
      fill_with_zeros: false,
      chunk_every: 3,
      chunk_separator_integral: ",",
      chunk_separator_fractional: " ",
      fraction_separator: ".",
      trailing_zeros_start: "[",
      trailing_zeros_end: "]"
    }

    auto_assert "1.12[0]" <-
                  DecimalFmt.fmt!(DecimalRepr.from_string("1.120"), format_spec)

    auto_assert "12,345,678.112 233 44[0 000]" <-
                  DecimalFmt.fmt!(
                    "12345678.112233440000",
                    format_spec
                  )

    auto_assert "12,345,678.123 456 7[0]" <-
                  DecimalFmt.fmt!(
                    "12345678.1234567",
                    %{format_spec | precision: 8, fill_with_zeros: true}
                  )

    auto_assert "12,345,678.123[ 00]" <-
                  DecimalFmt.fmt!(
                    "12345678.123",
                    %{format_spec | precision: 5, fill_with_zeros: true}
                  )

    auto_assert "12,345,678.123" <-
                  DecimalFmt.fmt!(
                    "12345678.123",
                    %{format_spec | precision: 5, fill_with_zeros: false}
                  )
  end
end
