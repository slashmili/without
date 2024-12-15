defmodule Without do
  defstruct [:value, :result, :assigns]

  def finit({:ok, value}), do: %Without{value: value, result: :ok, assigns: %{}}
  def finit({:error, value}), do: %Without{value: value, result: :error, assigns: %{}}
  def finit(value), do: %Without{value: value, result: :ok, assigns: %{}}

  def fresult(%Without{result: result, value: value}) do
    {result, value}
  end

  def fmap_ok(%Without{result: :error} = context, _func) do
    context
  end

  def fmap_ok(%Without{} = context, func) when is_function(func, 0) do
    case func.() do
      {:ok, value} -> %{context | result: :ok, value: value}
      {:error, error} -> %{context | result: :error, value: error}
    end
  end

  def fmap_ok(%Without{} = context, func) when is_function(func, 1) do
    case func.(context.value) do
      {:ok, value} -> %{context | result: :ok, value: value}
      {:error, error} -> %{context | result: :error, value: error}
    end
  end

  def fmap_ok(value, func) do
    value
    |> finit
    |> fmap_ok(func)
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
