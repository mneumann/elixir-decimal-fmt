defmodule DecimalFmt.FormatSpec do
  @type t() :: %__MODULE__{
          chunk_every: pos_integer(),
          chunk_separator_integral: binary(),
          chunk_separator_fractional: binary(),
          fraction_separator: binary(),
          trailing_zeros_start: binary(),
          trailing_zeros_end: binary()
        }
  defstruct [
    :chunk_every,
    :chunk_separator_integral,
    :chunk_separator_fractional,
    :fraction_separator,
    :trailing_zeros_start,
    :trailing_zeros_end
  ]
end
