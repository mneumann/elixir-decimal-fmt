defmodule DecimalFmt.Formats do
  @default_fmt %DecimalFmt.FormatSpec{
    chunk_every: 3,
    chunk_separator_integral: ",",
    chunk_separator_fractional: ",",
    fraction_separator: ".",
    trailing_zeros_start: "",
    trailing_zeros_end: ""
  }

  def default() do
    @default_fmt
  end
end
