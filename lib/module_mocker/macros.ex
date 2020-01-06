defmodule ModuleMocker.Macros do
  defmacro define_mock(method, args) do
    quote do
      def unquote(method)(unquote_splicing(args)) do
        invoke(unquote(method), unquote(args))
      end
    end
  end
end
