defmodule DecimalFmt.FormatSpec do
  @type t() :: %__MODULE__{
          precision: non_neg_integer() | nil,
          fill_with_zeros: boolean(),
          group_digits: pos_integer(),
          integral_group_separator: binary(),
          fraction_group_separator: binary(),
          fraction_separator: binary(),
          trailing_zeros_start_marker: binary(),
          trailing_zeros_end_marker: binary()
        }
  defstruct [
    :precision,
    :fill_with_zeros,
    :group_digits,
    :integral_group_separator,
    :fraction_group_separator,
    :fraction_separator,
    :trailing_zeros_start_marker,
    :trailing_zeros_end_marker
  ]
end
