# ♻️ 🐇 Rabbits and Recurrence Relations

[Original Problem](https://rosalind.info/problems/fib/)

!!! warning "The Problem"
    _Given_: Positive integers ``n≤40``
    and $k≤5$.

    _Return_: The total number of rabbit pairs
    that will be present after ``n`` months,
    if we begin with 1 pair and in each generation,
    every pair of reproduction-age rabbits produces a litter of ``k``
    rabbit pairs (instead of only 1 pair).

    Sample Dataset
    ```txt
    5 3
    ```
    Sample Output
    ```
    19
    ```

## Recursion in julia

This is a classic computer science problem,
and performing recursion in julia is pretty easy -
we simply have a function call itself.

The key is to have a bail-out condition
to avoid infinite recursion.

In this case, the bail-out is when you reach ``1``,
and it's also helpful to avoid invalid inputs.

```@example fib
function fib(n::Int, k::Int)
    # validate inputs
    n >= 0 || error("N must be greater than or equal to 0")
    k > 1 || error("K must be at least 2")

    # once we reach 1 or 0, we just return 1 or 0
    if n <= 1
        return n
    else
        # otherwise, recursively call on the previous 2 integers
        return fib(n - 1, k) + k * fib(n - 2, k)
    end
end
```

Let's go through each piece:

## Multiple dispatch

```julia
function fib(n::Int, k::Int)
```

Here, we're defining a function with 2 arguments,
``n`` and ``k``.
The `::Int` syntax forces the arguments to have the type `Int`,
which is short-hand for a 64-bit integer.

As we saw in previous problems,
julia makes use of "multiple dispatch",
which means we can define the same function with multiple "methods",
each of which takes different types of arguments.

In this case,
if we try to call the function with different arguments,
we'll get a `MethodError`, telling us that there isn't
a version that works on that combination of types:


```julia-repl
julia> fib("5", "3")
ERROR: MethodError: no method matching fib(::String, ::String)
The function `fib` exists, but no method is defined for this combination of argument types.

Closest candidates are:
  fib(::Int64, ::Int64)
```

If we'd like, we could define a version
that takes `String`s as arguments,
and tries to convert them into integers.
To do that, we use the `parse()` function.

```@example fib
parse(Int, "5")
```

