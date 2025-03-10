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

This is a classic computer science problem,
but not _directly_ biology focused.
Instead, we'll use it to showcase some other julia features.

## Recursion in julia

Recursion in julia is pretty easy -
we simply have a function call itself.
As in any language, the key is to have a bail-out condition
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

```julia
function fib(n::Int, k::Int)
```

is the function definition.
It takes two arguments, `n` and `k`, both of type `Int`.

```julia
n >= 0 || error("N must be greater than or equal to 0")
k > 1 || error("K must be at least 2")
```

are what we call "short-circuit" evaluation.
The `||` operator is a logical OR operator,
and so if the first condition is true, the second condition is not evaluated
(because `true` OR anything is true).
The same things could have been written with the short-circuiting `&&`
or as an `if` statement:

```julia
!(n >= 0) && error("N must be greater than or equal to 0")
# or
n < 0 && error("N must be greater than or equal to 0")
# or
if n < 0
    error("N must be greater than or equal to 0")
end
```

```julia
if n <= 1
    return n
```

This is our recursion bail-out or "base case".
Once we reach ``1`` or ``0``, we don't want to recurse any more,
we just return that value.

```julia
else
    return fib(n - 1, k) + k * fib(n - 2, k)
end
```

If we're not at the base case, we recurse.
We call the function again, but with ``n - 1``
for the previous generation,
and ``n - 2`` for the generation before that.
We also multiply the second call by ``k``
to handle the fact that each pair of rabbits
from two generations ago (the ones that have matured)
produce ``k`` pairs of rabbits when they breed.

## Multiple dispatch

So that solves the recursion problem,
but one thing you might notice
if you try to read the inputs from rosalind.info directly
is that we read the files as `String`s,
but we've defined our function to operate on `Int`s.

```julia
function fib(n::Int, k::Int)
```

Here, we're defining a function with 2 arguments,
``n`` and ``k``.
The `::Int` syntax forces the arguments to have the type `Int`,
which is short-hand for a 64-bit integer.

In something like python,
you would probably write the function without type annotations,
and then check inside the function
with an `if` statement to deal with
the case where the arguments are not integers:

```python
def fib(n, k):
    if not isinstance(n, int):
        n = int(n)
    if not isinstance(k, str):
        k = int(k)

    # do stuff
```

In julia, we can handle this instead by
defining different "methods" of `fib`, each of which
takes different types of arguments.
In a previous problem,
when we defined a function to operate on `String`s or on `BioSequence`s,
we saw that julia makes use of "multiple dispatch",
though we didn't name it as such.

In this case,
if we try to call the function with different argument types,
say `String`s, we'll get a `MethodError`, telling us that there isn't
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
For example:

```@example fib
parse(Int, "5")
```

So, here's a version of `fib` that takes `String`s as arguments:

```@example fib
function fib(n::String, k::String)
    nint = parse(Int, n)
    kint = parse(Int, k)
    fib(nint, kint)
end

fib("5", "3")
```

Ok, but this still doesn't work:

```julia-repl
julia> fib("2", 3)
ERROR: MethodError: no method matching fib(::String, ::Int64)
The function `fib` exists, but no method is defined for this combination of argument types.

Closest candidates are:
  fib(::String, ::String)
   @ Main REPL[2]:1
  fib(::Int64, ::Int64)
   @ Main REPL[1]:1
```

We could now go through and define methods
of `fib` that take different types of arguments.
For example:

```@example fib
function fib(n::String, k::Int)
    nint = parse(Int, n)
    fib(nint, k)
end
```

or

```@example fib
function fib(n::Int, k::String)
    kint = parse(Int, k)
    fib(n, kint)
end
```

Now, we can call `fib` with an `Int` and a `String`:

```@example fib
fib(2, "3")
```

## Parsing files

When you do a problem on Rosalind,
the file you download contains your problem input.
Up to now,
I've just assumed you'll be copy-pasting
the input into your Julia REPL.

However, it's often more convenient to read the input from a file,
and in this case, a little additional parsing is required,
since the input comes in the form of two integers separated by a space,
and when you read in the file, it will be a `String`.

There are a number of ways to read files in julia,
including the `readlines()` function,
which loads all of the lines of the file into `Vector{String}`.

When you have really large files, this can be annoying,
and you can instead use the `eachline()` function,
so you can do something like `for line in readlines("input.txt")`
and deal with each line separately.

But in this case (and the previous rosalind.info problems we've looked at),
each problem comes in as a single line,
so we'll use the `read()` function instead.
By default, `read()` reads the entire file into a vector of bytes,
that is a `Vector{UInt8}`.
This can be converted to a `String` using the `String()` function,
but this is a common enough use-case that we can just tell `read()` to return a `String`
by passing the `String` type as an argument.

```julia
read("rosalind_fib.txt", String)
```

One tricky gotcha is that the rosalind text files
have a trailing newline character at the end of the file.
This can be removed using the `strip()` function.

Finally, because of the format of this input in particular,
we'll use the `split()` function to split the string into two parts,
and then convert each part to an integer using the `parse()` function.

```@example fib
function read_fib(file)
    numbers = read(file, String)
    numbers = strip(numbers) # remove trailing newline
    n_str, k_str = split(numbers, ' ') # split on spaces
    return parse(Int, n_str), parse(Int, k_str)
end

(n,k) = read_fib("problem_inputs/rosalind_fib.txt")
fib(n, k)
```
