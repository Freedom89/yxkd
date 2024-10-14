---
toc: true
mermaid: true
hidden: true
math: true
---


### Modular Arithmetic (RA1)

Short overview of topics:

* Math primer 
  * modular Arithmetic
  * multiplicative inverses
  * Euclid's GCD algorithm
* Fermat's little theorem 
  * RSA algorithm
* Primality testing
  * is a number a prime number? or a composite number
  * Generate random prime numbers

#### Huge integers

For huge n, consider n-bit integers, x,y, N, in the order of 1024 or even 2048 bits. 

#### Modular Arithmetic

For integer x, x mod 2 = least significant bit of x, which tells you if x is even or odd. We can also do this by x/2 and get the remainder.

For integer $N \geq 1: x mod N$ is the remainder of x when divided by N.

Some additional notation:

$$
X \equiv Y \bmod N
$$

means $\frac{X}{N}, \frac{Y}{N}$ have same remainder, another way of writing this is:

$$
x \bmod N = r \iff x = qN + r, q,r \in \mathbb{Z}
$$

Then we have the following:

if $x \equiv y \bmod N $ and $a \equiv b \bmod N$ then $x+a \equiv y+b \bmod N$ and $xa \equiv yb \bmod N$

#### Modular Exponentiation

n-bit numbers, compute $x^y \bmod N$.

Consider the simple algorithm:

$$
\begin{aligned}
x \bmod N &= a_1 \\
x^2 \equiv a_1x \bmod N &= a_2 \\
\vdots \\
x^y = a_{y-1}x \bmod N &= a_n
\end{aligned}
$$

Multiplying two n-bit numbers and dividing by a n-bit number takes $O(n^2)$ per round, since we have y rounds where $y \leq 2^n$, the overall time complexity is $O(n^2 2^n)$ which is horrible

$$
\begin{aligned}
x \bmod N &= a_1 \\
x^2 \equiv (a_1)^2 \bmod N &= a_2 \\
x^4 \equiv (a_2)^2 \bmod N &= a_4 \\
x^8 \equiv (a_4)^2 \bmod N &= a_8 \\
\vdots \\
\end{aligned}
$$

Then we can look at the binary representation of $y$ and find the appropriate $a_i$. For example if $y=25 = 11001$, then we need $a_{2^4=16} \ast a_{a^3 = 8} \ast a_{2^0=1} = a_{25}$

#### Mod-Exp algorithm

Note that for even $y$, $x^y = (x^{y/2})^2$, and for odd $y$, $x^y = x(x^{\lfloor y/2 \rfloor})^2$

```
mod-exp(x,y,N)
  Input: n-bit integers, x,y N >= 0
  Output: pow(x,y) mod N
  if y = 0, return(1)
  z = mod-exp(x, floor(y/2), N)
  if y is even:
    return (z^2 mod N)
  else:
    return (xz^2 mod N)
```

#### Multiplicative inverses

x is the multiplicative inverse of $z \bmod N$ if $xz \equiv 1 \bmod N$, which can be re-written as :

$$
x \equiv z^{-1} \bmod N
$$

Note that the $z$ is also the inverse of x, i.e $z \equiv x^{-1} \bmod N$

Note that the inverse is not guaranteed to exists, consider $N=14$, what is the inverse of $4 \mod 14$?

#### Inverse: Existence

The key idea here is if $x,N$ shares a common divisor, then it has no inverse.

Theorem: $x^{-1} \bmod N$ exists if and only if $gcd(x,N)=1$, gcd stands for greatest common divisor. This also means x and N are relatively prime.

In addition, if we always report $x^{-1} \bmod N$ in $0,1,...,N-1$ if it exists, it is unique and does not exists otherwise. For instance, $3^{-1} \equiv 4 \bmod 11$, but so is $15,26,-7$. Etc $3*-7 = -21 \bmod 11 = -1 $

Proof. Lets suppose $x^{-1} \bmod N$ has two inverses, $y \equiv x^{-1} \bmod N, z \equiv x^{-1} \bmod N, y\cancel{\equiv} z, 0 \leq y \neq z \leq N-1$.

This implies that $xy \equiv xz \equiv 1 \bmod N$. But if we multiply each by $x^{-1}$, then $x^{-1}xy \equiv x^{-1}xz \bmod N$ which implies $y \equiv z \bmod N$ which is a contradiction.

#### Inverse: Non existence 

if $gcd(x,N) > 1$ then $x^{-1} \equiv \bmod N$ does not exists. 

Lets assume $z = x^{-1} \bmod N \implies xz \equiv 1 \bmod N$ and $x,z$ shares a common divisor, $k > 1$.

This means that $xz = gN+1$,  which means $akz = g(bk)+1$, for some $a$ and $b$ since $x,N$ share some common divisor $k$. But this implies that $k(az-gb) = 1$, then $az-gb = \frac{1}{k}$  which shows that $az-gb$ is a fraction but $az-gb$ is an integer since a,z,g,b are integers and $k >1$, which is a contradiction. 

#### Euclid Rule

For integers x,y where $ x \geq y > 0$:

$$
gcd(x,y) = gcd(x \bmod y ,y)
$$

Proof: $gcd(x,y) = gcd(x-y,y)$, and if this is true we take x and minus y from it until we are no longer able to do so. This gives us exactly $x \bmod y$. 

Now, to proof $gcd(x,y) = gcd(x-y,y)$:
* if $d$ divides $x,y$ then $d$ divides $x-y$ 
* if $d$ divides $x-y, y$, then it divides $x$ since we can just sum them up.

#### Euclid's GCD algorithm

```
Euclid(x,y):
  input: integers (x,y) where x >= y >= 0
  output: gcd(x,y)

  if y = 0:
    return(x)
  else:
    return (Euclid(y, x mod y))
```

In the base case we are looking at y = 0, which is $gcd(x,0)$ What are the divisors of zero? How should we define this? What is a reasonable manner of defining the divisors of zero? Well, we got to this case by taking the GCD of sum multiple $x$ with $x$: 

$$
gcd(x,0) = gcd(kx, x) = x
$$

Before we analyize the runtime analysis, lets prove:

Lemma: if $x \geq y$ then $x \bmod y < \frac{x}{2}$.

* If $y \leq x/2$ then $x \bmod y \leq y-1 < y \leq x/2$
* If $y > x/2, \lfloor \frac{x}{y}\rfloor =1$ then $x \bmod y = x-y < x - \frac{x}{2} \leq \frac{x}{2}$
 


Note, because of the lemma, each rounds the values decreasings by half:

$$
(x,y) \rightarrow (y, x\bmod y) \rightarrow (\underbrace{x \bmod y}_{< \frac{x}{2}}, y\bmod x \bmod y ) \\
\implies 2n \text{ rounds}
$$

So there is a total of $2n$ rounds. We can now do our run-time analysis. 

Runtime analysis:

* `x mod y` takes $O(N^2)$ time to compute where $N$ is the number of bits, and this is for a single round.
* Total of $2n$ rounds
* Total of $O(n^3)$ runtime. 

#### Extended Euclid Algorithm

This is to compute the inverse of $x \bmod y$. Suppose $d = gcd(x,y)$ and we can express $d=x\alpha+y\beta$ and we have the following:

if $gcd(x,N) =1$ then $x^{-1} \bmod N$ exists. 

$$
\begin{aligned}
d = 1 &= x\alpha + N\beta \\
1 &\equiv x\alpha + \underbrace{N\beta}_{0} \bmod N \\
x^{-1} &\equiv \alpha \bmod N
\end{aligned}
$$

Similarly, 

$$
\beta = N^{-1} \bmod X
$$

```
Ext-Euclid(x,y)
  input: integers, x,y where x >= y >= 0
  output: integers d, α,β where d = gcd(x,y) and d = xα+yβ

  # remember gcd(x,0) = x, so we just set α = 1,β = 0
  if y = 0:
    return (x,1,0)
  else:
    d,α',β' = Ext-Euclid(y, x mod y)
    return (d, β', α' - floor(x/y)β')
```

The proof of the final expression can be found in the textbook, enjoy!

Runtime analysis:

* Similarly, $O(n^2)$ to compute $x \bmod y$ and calculating $\lfloor \frac{x}{y} \rfloor$
* $n$ rounds
* Total of $O(n^3)$


#### Summary:

* Fast Modular Exponentiation algorithm
* How to calculate multiplicative inverse
  * Euclid's GCD algorithm - $gcd(x,y)$
  * Extended Euclid's algorithm to compute $x^{-1} \bmod N$

### RSA (RA2)




<!-- {% include embed/youtube.html id='10oQMHadGos' %} -->