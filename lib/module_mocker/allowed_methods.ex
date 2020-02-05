defmodule ModuleMocker.AllowedMethods do
  defstruct [
    exact_allows: %{},
    fn_allows: %{}
  ]

  def new() do
    %__MODULE__{

    }
  end

  def add(rec, method, args, value) when is_list(args) do
    current_arg_map = Map.get(rec.exact_allows, method, %{})
    updated_arg_map = Map.put(current_arg_map, {args}, value)
    updated_exact_map = Map.put(rec.exact_allows, method, updated_arg_map)
    %__MODULE__{
      rec |
        exact_allows: updated_exact_map
    }
  end

  def add(rec, method, args, value) when is_function(args) do
    current_arg_map = Map.get(rec.fn_allows, method, %{})
    update_arg_fns = [{args, value}|current_arg_map]
    updated_fn_map = Map.put(current_arg_map, method, update_arg_fns)
    %__MODULE__{
      rec |
        fn_allows: updated_fn_map
    }
  end

  def check(rec, method, args) do
    case match_criteria(rec, method) do
      :none -> {:error, {:function_not_allowed, method}}
      {:exact_allowed, ex_a} -> match_exact_only(ex_a, method, args)
      {:fn_allowed, fn_a} -> match_fn_only(fn_a, method, args)
      {:both, ex_a, fn_a} -> match_both(ex_a, fn_a, method, args)
    end
  end

  defp match_criteria(rec, method) do
    e_allowed = Map.get(rec.exact_allows, method, nil)
    fn_allowed = Map.get(rec.fn_allows, method, nil)
    case {e_allowed, fn_allowed} do
      {nil, nil} -> :none
      {nil, fn_a} -> {:fn_allowed, fn_a}
      {ex_a, nil} -> {:exact_allowed, ex_a}
      {ex_a, fn_a} -> {:both, ex_a, fn_a}
    end
  end

  def match_exact_only(arg_mapping, method, args) do
    case Map.has_key?(arg_mapping, {args}) do
      false -> {:error, {:no_matching_call, method, args}}
      _ -> {:ok, Map.fetch!(arg_mapping, {args})}
    end
  end

  def match_fn_only(arg_mapping, method, args) do
    found_fn_mapping = Enum.find(arg_mapping, nil, fn({tf,_}) ->
      apply(tf, [args])
    end)
    case found_fn_mapping do
      {_, result} -> {:ok, result}
      _ -> {:error, {:no_matching_call, method, args}}
    end
  end

  defp match_both(ex_a, fn_a, method, args) do
    case match_exact_only(ex_a, method, args) do
      {:error, _} -> match_fn_only(fn_a, method, args)
      a -> a
    end
  end
end
