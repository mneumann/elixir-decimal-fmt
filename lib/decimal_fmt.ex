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

defmodule DecimalFmt.DecimalRepr do
  @type digit() :: 0..9
  @type t() :: {nonempty_list(digit()), list(digit())}

  @spec from_string(String.t()) :: t()

  @doc """
  Converts a decimal string into internal decimal representation, maintaining leading and trailing zeros.
  """

  def from_string(str) when is_binary(str) do
    case String.split(str, ".") do
      [integral] ->
        {parse_digits(integral), []}

      [integral, fractional] ->
        {parse_digits(integral), parse_digits(fractional)}
    end
  end

  defp char_to_digit(ch) when ch in ?0..?9, do: ch - ?0
  defp parse_digits(s), do: s |> to_charlist() |> Enum.map(&char_to_digit/1)
end

defmodule DecimalFmt do
  @moduledoc """
  Documentation for `DecimalFmt`.
  """

  @type digit() :: 0..9
  @type decimal() :: {nonempty_list(digit()), list(digit())}

  @doc """
  Formats the decimal number of the default format spec.

  ## Examples

      iex> DecimalFmt.fmt({[1], [1,2,0]})
      "1.120"

  """
  def fmt(number) do
    fmt(number, DecimalFmt.Formats.default())
  end

  def fmt(number, fmt_spec) do
    formatter = &fmt_insn(&1, fmt_spec)

    number
    |> decimal_to_fmt_instructions(fmt_spec.chunk_every)
    |> Enum.reduce(<<>>, fn insn, acc -> acc <> formatter.(insn) end)
  end

  @type fmt_instruction() ::
          digit()
          | :chunk_separator_integral
          | :chunk_separator_fractional
          | :fraction_separator
          | :trailing_zeros_start
          | :trailing_zeros_end

  @spec fmt_insn(fmt_instruction(), DecimalFmt.FormatSpec.t()) :: binary()
  defp fmt_insn(insn, _fmt_spec) when is_integer(insn), do: to_string(insn)
  defp fmt_insn(insn, fmt_spec) when is_atom(insn), do: Map.get(fmt_spec, insn)

  @spec decimal_to_fmt_instructions(DecimalFmt.DecimalRepr.t(), pos_integer()) ::
          nonempty_list(fmt_instruction())

  def decimal_to_fmt_instructions({[_ | _] = integral, fractional}, chunk_every) do
    integral_insn =
      integral
      |> Enum.reverse()
      |> Enum.chunk_every(chunk_every)
      |> Enum.intersperse(:chunk_separator_integral)
      |> List.flatten()
      |> Enum.reverse()

    fractional_insn =
      fractional
      |> Enum.chunk_every(chunk_every)
      |> Enum.intersperse(:chunk_separator_fractional)
      |> List.flatten()
      |> mark_trailing(&zero_or_instruction/1, :trailing_zeros_start, :trailing_zeros_end)

    case fractional_insn do
      [] -> integral_insn
      _ -> integral_insn ++ [:fraction_separator] ++ fractional_insn
    end
  end

  defp mark_leading(lst, while, mark_start, mark_end) do
    case Enum.split_while(lst, while) do
      {[], rest} -> rest
      {leading, rest} -> [mark_start] ++ leading ++ [mark_end] ++ rest
    end
  end

  defp mark_trailing(lst, while, mark_start, mark_end) do
    lst |> Enum.reverse() |> mark_leading(while, mark_end, mark_start) |> Enum.reverse()
  end

  defp zero_or_instruction(0), do: true
  defp zero_or_instruction(insn) when is_atom(insn), do: true
  defp zero_or_instruction(_), do: false
end
