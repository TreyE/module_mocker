defmodule AllowTest do
  use ExUnit.Case, async: false

  test "errors on a non-allowed mock" do
    AllowTestMock.setup()
    assert_raise(MatchError, fn() ->
      AllowTestMock.some_method(1,2,3)
    end)
    AllowTestMock.verify()
  end

  test "is ok with an allowed mock" do
    AllowTestMock.setup()
    AllowTestMock.allow(:some_method, [1,2,3], 1)
    1 = AllowTestMock.some_method(1,2,3)
    AllowTestMock.verify()
  end
end
