# Finding a Motif in DNA

🤔 [Problem link](https://rosalind.info/problems/subs/)

!!! warning "The Problem"

    Given two strings s and t, 
    t is a substring of s if t is contained as a contiguous collection of symbols in s 
    (as a result, t must be no longer than s).

    The position of a symbol in a string is the total number of symbols found to its left, including itself.    
    (e.g., the positions of all occurrences of 'U' in "AUGCUUCAGAAAGGUCUUACG" are 2, 5, 6, 15, 17, and 18).   
    The symbol at position i of s is denoted by s[i].

    A substring of s can be represented as s[j:k],   
    where j and k represent the starting and ending positions of the substring in s;    
    for example, if s= "AUGCUUCAGAAAGGUCUUACG",   
    then s[2:5]= "UGCU".

    The location of a substring s[j:k]is its beginning position j;   
    note that t will have multiple locations in s
    if it occurs more than once as a substring of s.
    (see the Sample below).

    Given: 
    Two DNA strings s and t.  
    (each of length at most 1 kbp).

    Return: 
    All locations of t as a substring of s.  

    Sample Dataset
    `GATATATGCATATACTTATAT`
    
    Sample Output
    `2 4 10`

### Handwritten solution
Let's start off with the most verbose solution.  
We can loop over every character within the input string and  
check if we can find the substring in the subsequent characters.  

In the first solution,   
we will check each index for an exact match to the substring we are searching for. 

```julia
dataset = "GATATATGCATATACTTATAT"
search_string = "ATAT"

function haystack(substring, string)
    # check if the strings are empty
    if isempty(substring) || isempty(string)
        throw(ErrorException("empty sequences"))
    end

    # check that string exists in data
    if ! occursin(substring, string)
        return []
    end

    output = []
    for i in eachindex(string)
        # check if first letter of string matches character at the index
        if string[i] == substring[1]
            # check if full substring matches at index
            # make sure not to search index past string 
            if i + length(substring) - 1 <= length(string) && string[i:i+length(substring)-1] == substring
                push!(output, i)
            end
        end
    end
    return output
end

haystack(search_string, dataset)
```
We can also use the [`findnext`](https://docs.julialang.org/en/v1/base/strings/#Base.findnext) function in Julia.   

There are similar `findfirst` and `findlast` functions,   
but since we want to find all matches,  
we will use `findnext`.

Currently, there isn't a `findall` function that allows us to avoid a loop.  
We'll still also loop over every character in the string,   
as there could be overlapping substrings.



```julia
function haystack_findnext(substring, string)
    # check if the strings are empty
    if isempty(substring) || isempty(string)
        throw(ErrorException("empty sequences"))
    end

    # check that string exists in data
    if ! occursin(substring, string)
        return []
    end

    output = []
    i = 1
    # while index is less than the length of string
    while i < length(string)
        result = findnext(substring, string, i)
        if result == nothing
            break
        end

        if result != nothing
            push!(output, first(result))
            i = first(result) + 1
        end
    end
    return output
end
    

haystack_findnext(search_string, dataset)
```

Lastly, we can also use Regex's search function,
which produces quite the elegant solution!


```julia
function haystack_regex(substring, string)
    if isempty(substring) || isempty(string)
        throw(ErrorException("emptysequences"))                            
    end                                                                                                                             
    if !occursin(substring, string)            
          return[]    
    end    
    
    return [m.offset for m in eachmatch(Regex(substring), string, overlap=true) ] 
end

haystack_findnext(search_string, dataset)
```

### Biojulia solution

Lastly, we can leverage some functions in the Kmers Biojulia package to help us!

```julia


```


