defmodule ModuleMocker do
  defmacro __using__(_) do
    quote do
      use GenServer
      import ModuleMocker.Macros

      def setup(args \\ []) do
        GenServer.start(__MODULE__, args, name: __MODULE__)
      end

      def init(args) do
        {:ok, %{called: %{}, allows: %{}, expects: %{}}}
      end

      def handle_call(:verify, _from, state) do
        reply = ModuleMocker.Interface.verify_calls(state.expects, state.called)
        {:reply, reply, state}
      end

      def handle_call({:allow, method, args, value}, _from, state) do
        new_allows = ModuleMocker.Interface.extend_allows(state.allows, method, args, value)
        {:reply, :ok, %{state | allows: new_allows}}
      end

      def handle_call({:call, method, args}, _from, state) do
        reply = ModuleMocker.Interface.check_allowed(state.allows, method, args)
        {:reply, reply, state}
      end

      def handle_call({:called, method, args}, _from, state) do
        new_called = ModuleMocker.Interface.add_call(state.called, method, args)
        {:reply, :ok, %{state | called: new_called}}
      end

      def handle_call({:expect, method, args}, _from, state) do
        new_expects = ModuleMocker.Interface.add_expect(state.expects, method, args)
        {:reply, :ok, %{state | expects: new_expects}}
      end

      def verify do
        result = GenServer.call(__MODULE__, :verify)
        GenServer.stop(__MODULE__)
        :ok = result
      end

      def allow(method, args, result) do
        GenServer.call(__MODULE__, {:allow, method, args, result})
      end

      def invoke(method, args) do
        {:ok, result} = GenServer.call(__MODULE__, {:call, method, args})
        GenServer.call(__MODULE__, {:called, method, args})
        result
      end

      def expect(method, args) do
        GenServer.call(__MODULE__, {:expect, method, args})
      end
    end
  end
end
