defmodule LobarTest do
  use ExUnit.Case, async: true

  import Lobar

  defmodule Person do
    defstruct first: nil
  end

  test "arity returns the arity of the passed function" do
    assert 0 == arity(fn -> "foo" end)
    assert 1 == arity(fn a -> a end)
    assert 2 == arity(fn a, b -> a + b end)
  end

  test "pluck extracts the right values from structs" do
    people = [%Person{first: "Alice"}, %Person{first: "Bob"}]  
    assert people |> pluck(:first) == ["Alice", "Bob"]
  end

  test "pluck extracts the right values from maps" do
    people = [ %{:first => "Alice"}, %{:first => "Bob"} ]
    assert people |> pluck(:first) == ["Alice", "Bob"]
  end
  
  test "pluck returns nil for missing keys" do
    people = [ %{:first => "Alice"}, %{:last => "Smith"} ]
    assert people |> pluck(:first) == ["Alice", nil]
  end

  test "pluck can work with nested values, returns nil for missing" do
    people = [
      %{:first => "Alice", :address => %{:city => "Minneapolis"}},
      %{:first => "Bob",   :address => %{:city => "St. Paul"}},
      %{:first => "Carol", :address => %{}},
      %{:first => "Dan"},
    ]

    assert people |> pluck([:address, :city]) == ["Minneapolis", "St. Paul", nil, nil]
  end

  test "extract gets nested values from maps" do
      person = %{:first => "Bob", :address => %{:city => "St. Paul"}}
      assert "St. Paul" == person |> extract [:address, :city]
  end

  test "extract returns nil if a key is missing" do
      person = %{:first => "Bob", :address => %{:city => "St. Paul"}}
      assert nil == person |> extract [:address, :state]
  end

  test "partial application on function/1" do
    echo = fn a -> a end
    partial_one = partial(echo, [1])
    assert partial_one.() == 1
  end

  test "partial application on function/2" do
    sum = fn a, b -> a + b end

    partial_one = partial(sum, [1])
    assert partial_one.(2) == 3

    partial_two = partial(sum, [1, 2])
    assert partial_two.() == 3
  end

  test "partial application on function/3" do
    sum = fn a, b, c -> a + b + c end

    partial_one = partial(sum, [1])
    assert partial_one.(2, 3) == 6

    partial_two = partial(sum, [1, 2])
    assert partial_two.(3) == 6

    partial_three = partial(sum, [1, 2, 3])
    assert partial_three.() == 6
  end

end
