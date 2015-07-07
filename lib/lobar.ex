defmodule Lobar do

  def arity(fun) do
    {:arity, arity} = :erlang.fun_info(fun, :arity)
    arity
  end

  def extract(val, []), do: val
  def extract(val, [head | tail]) do
    case Map.get(val, head) do
      nil -> nil
      child_val -> extract(child_val, tail)
    end
  end
  def extract(val, key), do: Map.get(val, key)

  def pluck(collection, field) do
    collection 
    |> Enum.map(fn elem -> extract(elem, field) end)
  end
  
  # def once(fun) do
    # TODO
    # end

  # TODO partial for all versions
  # might be able to have multiple versions and have a guard clause that checks if it's a fuction and that the arity is the right one
  # http://elixir-lang.org/docs/v1.0/elixir/Kernel.html#is_function/2
  # apply could also be used: http://elixir-lang.org/docs/v1.0/elixir/Kernel.html#apply/2

  # feels like we'd need to define a fun for each combination of currying
  # so if we go from 0 to 10 arguments, we'd have to have versions that check
  # the arity of the passed in fun, and accept 1..n parameters, so we'd
  # end up with ~50 funs...

  # feels like we might be able to do something clever with macros and apply
  # might still need to create a version for each arity of partial we want to
  # support, but that'd be only 10 funs

  # might be able to do it all with a single macro
  # would be nice if we could also use a `_` as a placeholder for values that we
  # don't want to fix in this version of the partial
  #
  # would also like to make an autoCurry that is a fun/macro that lets us
  # specify the values that we know and returns a curried partial fun if
  # it doesn't have all the parameters yet
  #
  # could potentially have 2nd parameter be a list of the arguments that we want to use
  # that'd get past the arity issue and appears to be how the if/2 macro is defined
  

  def brute_partial(fun, arg1) when is_function(fun, 1) do
    fn -> fun.(arg1) end
  end

  def brute_partial(fun, arg1) when is_function(fun, 2) do
    fn a -> fun.(arg1, a) end
  end

  def brute_partial(fun, arg1) when is_function(fun, 3) do
    fn a, b -> fun.(arg1, a, b) end
  end
  
  def brute_partial(fun, arg1, arg2) when is_function(fun, 2) do
    fn -> fun.(arg1, arg2) end
  end

  def brute_partial(fun, arg1, arg2) when is_function(fun, 3) do
    fn a -> fun.(arg1, arg2, a) end
  end

  def brute_partial(fun, arg1, arg2, arg3) when is_function(fun, 3) do
    fn -> fun.(arg1, arg2, arg3) end
  end

  # defmacro apply(fun, args) do
  #   quote do
  #     :erlang.apply(unquote(fun), unquote(args))
  #   end
  # end

  defmacrop re_arity(new_arity, do: block) when is_integer(new_arity) do
    args = (0..(new_arity - 1)) |> Enum.map &{ :"arg#{&1}", [], nil }
    IO.puts "re_arity args #{args}"
 
    quote do
      fun = fn(var!(arguments)) -> unquote(block) end
      fn(unquote_splicing(args)) -> fun.(unquote(args)) end
    end
  end

  # partial/adapt! tweaked from: https://gist.github.com/meh/7990856

  # TODO changes/enhancements: 
  # - don't require a list, let it take 1..20ish varargs
  # - throw a nice warning when someone gives too many variables

  defp adapt!(fun, 0) do
    fn -> fun.([]) end
  end
 
  # the max number of arguments for anonymous functions is 20
  Enum.reduce 1 .. 20, [], fn i, args ->
    args = [{ :"arg#{i}", [], nil } | args]
 
    defp adapt!(fun, unquote(i)) do
      fn unquote_splicing(args) -> fun.(unquote(args)) end
    end
 
    args
  end
 
  defmacrop adapt(arity, do: block) do
    quote do
      fn(var!(arguments)) -> unquote(block) end |> adapt!(unquote(arity))
    end
  end
 
  def partial(fun, partial) do
    adapt arity(fun) - length(partial) do
      fun |> apply(partial ++ arguments)
    end
  end

end
