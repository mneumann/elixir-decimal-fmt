defmodule DecimalFmt do
  @moduledoc """
  Documentation for `DecimalFmt`.
  """

  alias DecimalFmt.{DecimalRepr, FormatSpec, Formats}

  @doc """
  Formats the decimal number according to the given format spec.

  ## Examples

      iex> DecimalFmt.fmt!("1.120", :default)
      "1.120"

  """

  @spec fmt!(String.t() | float() | non_neg_integer(), FormatSpec.t() | :default) ::
          String.t()

  def fmt!(number, fmt_spec) when is_binary(number),
    do: fmt!(number |> DecimalRepr.from_string(), fmt_spec)

  def fmt!(number, fmt_spec) when is_float(number) and number >= 0.0,
    do: fmt!(number |> to_string(), fmt_spec)

  def fmt!(number, fmt_spec) when is_integer(number) and number > 0,
    do: fmt!(number |> to_string(), fmt_spec)

  def fmt!(number, :default), do: fmt!(number, Formats.default())

  def fmt!(number, fmt_spec) do
    number
    |> DecimalRepr.with_precision(fmt_spec.precision, fmt_spec.fill_with_zeros)
    |> decimal_to_fmt_instructions(fmt_spec.chunk_every)
    |> fmt_instructions(fmt_spec)
  end

  @type fmt_instruction() ::
          0..9
          | :chunk_separator_integral
          | :chunk_separator_fractional
          | :fraction_separator
          | :trailing_zeros_start
          | :trailing_zeros_end

  @spec fmt_instructions([fmt_instruction()], FormatSpec.t()) :: binary()
  defp fmt_instructions(instructions, fmt_spec) do
    formatter = &fmt_insn(&1, fmt_spec)

    instructions
    |> Enum.reduce(<<>>, fn insn, acc -> acc <> formatter.(insn) end)
  end

  @spec fmt_insn(fmt_instruction(), FormatSpec.t()) :: binary()
  defp fmt_insn(insn, _fmt_spec) when is_integer(insn), do: to_string(insn)
  defp fmt_insn(insn, fmt_spec) when is_atom(insn), do: Map.get(fmt_spec, insn)

  @spec decimal_to_fmt_instructions(DecimalRepr.t(), pos_integer()) ::
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
