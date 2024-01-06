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
