defmodule DecimalFmt.Formats do
  @default_fmt %DecimalFmt.FormatSpec{
    precision: nil,
    fill_with_zeros: false,
    group_digits: 3,
    integral_group_separator: ",",
    fraction_group_separator: ",",
    fraction_separator: ".",
    trailing_zeros_start_marker: "",
    trailing_zeros_end_marker: ""
  }

  def default() do
    @default_fmt
  end
end
