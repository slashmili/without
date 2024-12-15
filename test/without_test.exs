defmodule WithoutTest do
  use ExUnit.Case
  doctest Without

  describe "init/1" do
    test "returns Without struct when value is not a result tuple" do
      assert %Without{result: :ok, value: "foo"} = Without.finit("foo")
    end

    test "returns the same value of input is an ok tuple" do
      assert %Without{result: :ok, value: "foo"} = Without.finit({:ok, "foo"})
    end

    test "returns the same value of input is an error tuple" do
      assert %Without{result: :error, value: :oops} = Without.finit({:error, :oops})
    end
  end

  describe "fresult/1" do
    test "converts :ok result struct to final result format" do
      assert {:ok, "foo"} = {:ok, "foo"} |> Without.finit() |> Without.fresult()
    end

    test "converts :error result struct to final result format" do
      assert {:error, :oops} = {:error, :oops} |> Without.finit() |> Without.fresult()
    end
  end

  describe "fmap_ok/2" do
    test "creates Without struct if the first argument is a value" do
      assert %Without{} = "foo" |> Without.fmap_ok(fn name -> {:ok, "hello #{name}"} end)
    end

    test "skips executing when input is error tuple" do
      assert {:error, :oops} =
               {:error, :oops}
               |> Without.finit()
               |> Without.fmap_ok(fn -> {:ok, "what"} end)
               |> Without.fresult()
    end

    test "executes when previous result is ok and input function has arity of 0" do
      assert {:ok, "bar"} =
               {:ok, "foo"}
               |> Without.finit()
               |> Without.fmap_ok(fn -> {:ok, "bar"} end)
               |> Without.fresult()
    end

    test "executes when previous result is ok and input function has arity of 1" do
      assert {:ok, 16} =
               2
               |> Without.finit()
               |> Without.fmap_ok(fn value -> {:ok, value * 8} end)
               |> Without.fresult()
    end

    test "returns error when fmap_ok result is error" do
      assert {:error, :no_match} =
               "foo"
               |> Without.finit()
               |> Without.fmap_ok(fn arg ->
                 if arg == "bar" do
                   {:ok, :found_match}
                 else
                   {:error, :no_match}
                 end
               end)
               |> Without.fresult()
    end

    @tag :skip
    test "assigns ok results to internal struct" do
      assert result = "foo" |> Without.finit()
    end
  end

  describe "fmap_error/2" do
    test "skips executing when input is ok tuple" do
      assert {:ok, "foo"} =
               {:ok, "foo"}
               |> Without.finit()
               |> Without.fmap_error(fn -> {:error, :oops} end)
               |> Without.fresult()
    end

    test "executes when previous result is error and input function has arity of 0" do
      assert {:error, :file_not_found} =
               {:error, :oops}
               |> Without.finit()
               |> Without.fmap_error(fn -> {:error, :file_not_found} end)
               |> Without.fresult()
    end

    test "executes when previous result is ok and input function has arity of 1" do
      assert {:error, [:wrong, :oops]} =
               {:error, :oops}
               |> Without.finit()
               |> Without.fmap_error(fn value -> {:error, [:wrong, value]} end)
               |> Without.fresult()
    end

    test "returns ok when fmap_error result is ok" do
      assert {:ok, :its_ok} =
               {:error, :oops}
               |> Without.finit()
               |> Without.fmap_error(fn error_msg ->
                 if error_msg == :oops do
                   {:ok, :its_ok}
                 else
                   {:error, :really_bad}
                 end
               end)
               |> Without.fresult()
    end
  end
end
