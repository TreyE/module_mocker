defmodule ModuleMocker.Interface do
  def add_call(called, method, args) do
    current_call_list = Map.get(called, method, [])
    Map.put(called, method, [{args}|current_call_list])
  end

  def add_expect(expects, method, args) do
    current_expect_list = Map.get(expects, method, [])
    Map.put(expects, method, [{args}|current_expect_list])
  end

  def extend_allows(allows, method, args, value) do
    current_arg_map = Map.get(allows, method, %{})
    updated_arg_map = Map.put(current_arg_map, {args}, value)
    Map.put(allows, method, updated_arg_map)
  end

  def check_allowed(allowed, method, args) do
    case Map.get(allowed, method, nil) do
      nil -> {:error, {:function_not_allowed, method}}
      arg_mapping ->
        case Map.has_key?(arg_mapping, {args}) do
          false -> {:error, {:no_matching_call, method, args}}
          _ -> {:ok, Map.fetch!(arg_mapping, {args})}
        end
    end
  end

  def verify_calls(expect, called) do
    case Enum.any?(expect) do
      false -> :ok
      _ -> verify_against_expected(expect, called)
    end
  end

  defp verify_against_expected(expects, called) do
    expected_function_names = Map.keys(expects)
    actual_function_names = Map.keys(called)
    never_called = expected_function_names -- actual_function_names
    never_called_errors = Enum.map(never_called, fn(f_name) ->
      {:function_never_called, f_name}
    end)
    check_arg_calls = expected_function_names -- never_called
    select_missing_invocations = Enum.map(check_arg_calls, fn(m_name) ->
      expected_calls = Map.fetch!(expects, m_name)
      calls_for_method = Map.fetch!(called, m_name)
      missing_calls = expected_calls -- calls_for_method
      {m_name, missing_calls}
    end)
    remaining_arg_issues = Enum.reject(select_missing_invocations, fn({_, missing}) ->
      Enum.empty?(missing)
    end)
    wrong_arg_errors = Enum.map(remaining_arg_issues, fn(x) ->
      {:function_called_with_other_args, x}
    end)
    total_missing_expects = never_called_errors ++ wrong_arg_errors
    case Enum.any?(total_missing_expects) do
      false -> :ok
      _ -> {:error, total_missing_expects}
    end
  end
end
