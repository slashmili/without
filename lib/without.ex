defmodule Without do
  @moduledoc ~S"""
  `Without` is a tiny module to ease the usage of result tuple.

  Using `case` once is convenient, using it more than twice, makes the code less readable, consider this snippet

  ```
  case find_user(email) do
    {:ok, user} -> 
      case find_friends(user) do
        {:ok, friends} -> "#{user} is friends of #{Enum.join(",", friends)}"
        {:error, :friends_not_found} -> "#{user} doesn't have any friends"
      end
    {:error, :user_not_found} -> "user not found"
  end
  ```

  You might ask maybe `with` could help on that?
  ```
  with {:ok, user} <- find_user(email),
       {:ok, friends} <- find_friends(user) do
      "#{user} is friends of #{Enum.join(",", friends)}"

  else
    {:error, :user_not_found} -> "user not found"
    {:error, :friends_not_found} -> "#{user} doesn't have any friends"
  end
  ```
  But the issue here is that variable `user` is not available in the last else case!


  Now that you feel the pain, let me introduce you to `Without`!
  ```
  email
  |> Without.fmap_ok(&find_user/1, assign: :user)
  |> Without.fmap_ok(&find_friends/1)
  |> Without.fmap_error(fn error, assigns ->
    case error do
    :user_not_found -> "user not found"
    :friends_not_found, assigns -> "#{assigns[:user]} doesn't have any friends" 
  end)
  |> Without.fresult
  ```

  If you are a functional programming aficionado, it might resemble monadic error handling.
  """
  defstruct [:value, :result, :assigns]

  @type t :: %Without{value: any, result: :ok | :error, assigns: map}
  @type options :: [assign: atom]

  @type error :: {:error, any()}
  @type ok :: {:ok, any()}
  @type result :: error() | ok()

  @type map_func :: (-> result) | (any() -> result) | (any(), map() -> result)

  @spec finit(ok | error | any) :: t
  def finit({:ok, value}), do: %Without{value: value, result: :ok, assigns: %{}}
  def finit({:error, value}), do: %Without{value: value, result: :error, assigns: %{}}
  def finit(value), do: %Without{value: value, result: :ok, assigns: %{}}

  @spec fresult(t) :: {:ok, any} | {:error, any}
  def fresult(%Without{result: result, value: value}) do
    {result, value}
  end

  @spec fmap_ok(any | t, map_func, options) :: t
  def fmap_ok(context, func, opts \\ [])

  def fmap_ok(%Without{result: :error} = context, _func, _opts) do
    context
  end

  def fmap_ok(%Without{} = context, func, opts) when is_function(func, 0) do
    process_result(func.(), context, opts)
  end

  def fmap_ok(%Without{} = context, func, opts) when is_function(func, 1) do
    process_result(func.(context.value), context, opts)
  end

  def fmap_ok(%Without{} = context, func, opts) when is_function(func, 2) do
    process_result(func.(context.value, context.assigns), context, opts)
  end

  def fmap_ok(value, func, opts)
      when is_function(func, 0) or is_function(func, 1) or is_function(func, 2) do
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

  @spec fmap_error(t, map_func) :: t
  def fmap_error(%Without{result: :ok} = context, _func) do
    context
  end

  def fmap_error(%Without{} = context, func) when is_function(func, 0) do
    process_result(func.(), context)
  end

  def fmap_error(%Without{} = context, func) when is_function(func, 1) do
    process_result(func.(context.value), context)
  end

  defp process_result(result, context, opts \\ []) do
    case result do
      {:ok, value} ->
        context
        |> put_ok_result(value)
        |> maybe_assign(value, opts)

      {:error, error} ->
        %{context | result: :error, value: error}
    end
  end
end
