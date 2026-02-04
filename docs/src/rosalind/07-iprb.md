# Mendel's First Law

🤔 [Problem link](https://rosalind.info/problems/iprb/)

!!! warning "The Problem"

    Probability is the mathematical study of randomly occurring phenomena. 
    
    We will model such a phenomenon with a random variable, 
    
    which is simply a variable that can take a number of different distinct outcomes 
    
    depending on the result of an underlying random process.

    For example, say that we have a bag containing 3 red balls and 2 blue balls. 
    
    If we let X represent the random variable corresponding to the color of a drawn ball,
    
    then the probability of each of the two outcomes is given by Pr(X=red)=35 and Pr(X=blue)=25.

    Random variables can be combined to yield new random variables. 
    
    Returning to the ball example, let Y model the color of a second ball drawn from the bag (without replacing the first ball). 
    
    The probability of Y being red depends on whether the first ball was red or blue. 
    
    To represent all outcomes of X and Y, we therefore use a probability tree diagram. 
    
    This branching diagram represents all possible individual probabilities for X and Y, 
    
    with outcomes at the endpoints ("leaves") of the tree. 
    
    The probability of any outcome is given by the product of probabilities along the path from the beginning of the tree.

    An event is simply a collection of outcomes. 
    
    Because outcomes are distinct, the probability of an event can be written as the sum of the probabilities of its constituent outcomes. 
    
    For our colored ball example, let A be the event "Y is blue."
    
    Pr(A) is equal to the sum of the probabilities of two different outcomes: 
    
    Pr(X=blue and Y=blue)+Pr(X=red and Y=blue), or 310+110=25.

    Given: Three positive integers k, m, and n, 
    
    representing a population containing k+m+n organisms: 
    
    k individuals are homozygous dominant for a factor, m are heterozygous, and n are homozygous recessive.

    Return: The probability that two randomly selected mating organisms will produce an individual possessing a dominant allele (and thus displaying the dominant phenotype). 
    
    Assume that any two organisms can mate.

There are two main ways we can solve this problem: deriving an algorithm or simulation. 

### Deriving an Algorithm

Using the information above, we can derive an algorithm using the variables k, m, and n that will calculate the probability of a progeny possessing a dominant allele. 

We could calculate the probability of a progeny having a dominant allele, 

but in this case, it is easier to calculate the likelihood of a progeny having the recessive phenotype.

 This is a relatively rarer event, and the calculation will be straightforward. 
 
 We just have to subtract this probability from 1 to get the overall likelihood of having a progeny with a dominant trait. 

To demonstrate how to derive this algorithm, we can use H and h to signify dominant and recessive alleles, respectively.

Out of all the possible combinations, we will only get a progeny with a recessive trait in three situations: Hh x Hh, Hh x hh, and hh x hh. 

For all of these situations, we must calculate the probability of these mating combinations occuring (based on k, m, and n), 

as well as the probability of these events leading to a progeny with a recessive trait. 

To calculate this, we must calculate the probability of picking the first mating pair and then the second mating pair.

For the combination Hh x Hh, this is $\frac{m}{(k+m+n)}$ multiplied by $\frac{(m-1)}{(k+m+n-1)}$.

 Selecting the second Hh individual is equal to the number of Hh individuals left after 1 was already picked (m-1),
 
 divided by the total individuals left in the population (k+m+n-1). 

A similar calculation is performed for the rest of the combinations. 

However, it is important to note that the probability of selecting Hh x hh as a mating pair is $\frac{2*m*n}{(k+m+n)(k+m+n-1)}$,

 as there are two ways to choose this combination.
 
Hh x hh can be selected, as well as hh x Hh. Order matters!

| Probability of combination occuring | Hh x Hh | Hh x hh | hh x hh |
| --- |---|---|---|
| | $\frac{m(m-1)}{(k+m+n)(k+m+n-1)}$ |  $\frac{2*m*n}{(k+m+n)(k+m+n-1)}$| $\frac{n(n-1)}{(k+m+n)(k+m+n-1)}$|

<br>
<br>

The probability of these combinations leading to a recessive trait can be calculated using Punnet Squares.

| Probability of recessive trait | Hh x Hh | Hh x hh | hh x hh |
| --- |---|---|---|
| | 0.25 | 0.50 | 1 |

<br>
<br>


Now, we just have to sum the multiply the probability of each combination occuring by the probability of this combination leading to a recessive trait. 

This leads to the following formula:

Pr(recessive trait) = 
$\frac{m(m-1)}{(k+m+n)(k+m+n-1)}$ x 0.25 + $\frac{m*n}{(k+m+n)(k+m+n-1)}$ + $\frac{n(n-1)}{(k+m+n)(k+m+n-1)}$

Therefore, the probability of selecting an individual with a *dominant* trait is 1 - Pr(recessive trait). 

Now that we've derived this formula, let's turn this into code!

```julia
function mendel(k,m,n)

    total = (k+m+n)*(k+m+n-1)
    return 1-(
        (0.25*m*(m-1))/total + 
        m*n/total + 
        n*(n-1)/total)
end

mendel(2,2,2)
```

Deriving and using this algorithm is a clean solution. 

However, it is also narrowly tailored to a specific problem. 

What happens if we want to solve a more complicated problem or if there are additional requirements tacked on? 

For example, what if we wanted to solve a question like "What's the probability of a heterozygous offspring?"

We would need to derive another alogorithm for this similar, yet slightly different problem. 

Algorithms work in certain cases, but also don't scale up if we add another trait.

Another approach would be to use a statistics based solution. 

For instance, we can use a simulation that can broadly calculate the likelihood of a given offspring based on a set of given probabilities.

This solution is generic and can be used to ask more types of questions. 

<br>

### Simulation Method