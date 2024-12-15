defmodule Without do
  defstruct [:value, :result, :assigns]

  def finit({:ok, value}), do: %Without{value: value, result: :ok, assigns: %{}}
  def finit({:error, value}), do: %Without{value: value, result: :error, assigns: %{}}
  def finit(value), do: %Without{value: value, result: :ok, assigns: %{}}

  def fresult(%Without{result: result, value: value}) do
    {result, value}
  end

  def fmap_ok(context, func, opts \\ [])

  def fmap_ok(%Without{result: :error} = context, _func, _opts) do
    context
  end

  def fmap_ok(%Without{} = context, func, opts) when is_function(func, 0) do
    case func.() do
      {:ok, value} ->
        context
        |> put_ok_result(value)
        |> maybe_assign(value, opts)

      {:error, error} ->
        %{context | result: :error, value: error}
    end
  end

  def fmap_ok(%Without{} = context, func, opts) when is_function(func, 1) do
    case func.(context.value) do
      {:ok, value} ->
        context
        |> put_ok_result(value)
        |> maybe_assign(value, opts)

      {:error, error} ->
        %{context | result: :error, value: error}
    end
  end

  def fmap_ok(value, func, opts) do
    value
    |> finit
    |> fmap_ok(func, opts)
  end

  defp put_ok_result(context, value) do
    %{context | result: :ok, value: value}
  end

  defp maybe_assign(context, value, opts) do
    if assign_key = Keyword.get(opts, :assign) do
      assigns = Map.put(context.assigns, assign_key, value)
      %{context | assigns: assigns}
    else
      context
    end
  end

  def fmap_error(%Without{result: :ok} = context, _func) do
    context
  end

  def fmap_error(%Without{} = context, func) when is_function(func, 0) do
    case func.() do
      {:ok, value} -> %{context | result: :ok, value: value}
      {:error, error} -> %{context | result: :error, value: error}
    end
  end

  def fmap_error(%Without{} = context, func) when is_function(func, 1) do
    case func.(context.value) do
      {:ok, value} -> %{context | result: :ok, value: value}
      {:error, error} -> %{context | result: :error, value: error}
    end
  end
end
