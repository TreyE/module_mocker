defmodule AllowTestMock do
  use ModuleMocker

  define_mock :some_method, [a, b, c]
end
