defmodule ExpectTest do
  use ExUnit.Case, async: false

  test "has an error when the expectation is never called" do
    ExpectTestMock.setup()
    ExpectTestMock.expect(:expected_method, [1,2,3])
    me = assert_raise(MatchError, fn() ->
      ExpectTestMock.verify()
    end)
    {:error, [{:function_never_called,_}]} = me.term
  end

  test "has an error when the expectation is called with non-matching arguments" do
    ExpectTestMock.setup()
    ExpectTestMock.allow(:expected_method, [1,2,3], 1)
    ExpectTestMock.expect(:expected_method, [1,2,5])
    1 = ExpectTestMock.expected_method(1,2,3)
    me = assert_raise(MatchError, fn() ->
      ExpectTestMock.verify()
    end)
    {:error, [{:function_called_with_other_args,_}]} = me.term
  end

  test "is ok with an expected mock" do
    ExpectTestMock.setup()
    ExpectTestMock.allow(:expected_method, [1,2,3], 1)
    ExpectTestMock.expect(:expected_method, [1,2,3])
    1 = ExpectTestMock.expected_method(1,2,3)
    ExpectTestMock.verify()
  end
end
