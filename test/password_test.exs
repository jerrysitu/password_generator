defmodule PasswordGenerator.PasswordTest do
  alias PasswordGenerator.Password
  use ExUnit.Case

  describe "generate/3" do
    test "generats a password containing at least one number when number? is true" do
      {:ok, password} = Password.generate(8, true, false)

      assert password
             |> String.codepoints()
             |> Enum.any?(fn pw_char ->
               Enum.any?(numbers(), fn number ->
                 number == pw_char
               end)
             end) ==
               true
    end

    test "generats a password containing contains at least one special_character when special_char? is true" do
      {:ok, password} = Password.generate(8, false, true)

      assert password
             |> String.codepoints()
             |> Enum.any?(fn pw_char ->
               Enum.any?(special_characters(), fn special_char ->
                 special_char == pw_char
               end)
             end) ==
               true
    end

    test "generates a password with specified length" do
      length = 2..50 |> Enum.random()
      {:ok, password} = Password.generate(length, true, true)

      assert password |> String.length() == length
    end
  end

  defp special_characters() do
    ~S"""
    !"#$%&'()*+,-./:;<=>?@[]^_`{|}~
    """
    |> String.codepoints()
    |> List.delete_at(-1)
  end

  defp numbers() do
    0..9 |> Enum.map(fn x -> x |> Integer.to_string() end)
  end
end
