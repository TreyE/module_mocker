defmodule ExpectTestMock do
  use ModuleMocker

  define_mock :expected_method, [a, b, c]
end
