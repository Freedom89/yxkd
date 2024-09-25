---
title: CS6515 OMSCS - Graduate Algorithms DP DC Prep
date: 2024-08-15 0000:00:00 +0800
categories: [Courses, Gatech, Notes]
tags: [courses, omscs, gatech_notes]     # TAG names should always be lowercase
math: true
toc: true
mermaid: true
---

## Dynamic Programming

For dynamic programming, your solution needs to have 4 parts:

* Subproblem definition
* Recurrence relation
   * **STATE YOUR BASE CASES!**
* Psuedocode
* Complexity 

> For subproblem definition, there is a "weak" version and the "strong" inclusion.
> What the strong inclusion means is you **include** the i-th term in your recurrence. So, your T[i] must include a[i] **no matter what**.
>
> If you only "consider" it, then, use the words `up to` and not `include`.
{: .prompt-info }

There are a few cases when the **strong** definition is required, especially when you need to consider a **restart** in your recurrence such as LIS. Sometimes it is easier to use a strong definition to solve a problem.

In terms of dynamic programming,

> Only prefix and window dynamic programming problems are valid, there is no suffix problem.
> Only Floyd Warshall and Chain Matrix Multiply (CMM) are $O(n^3)$.
{: .prompt-tip }

* I find it useful to identify if it is a prefix problem, or a window problem $x_i,...,x_j$. If it is a window problem, then it should be a CMM.
* Otherwise, if it is a lookback problem, is the lookback window fixed?
  * For example, for a given $j$, do we only look back $j-1$, $j-2$? If so, this is likely to be a $O(n)$ problem
    * If you look back to i-1, i-2 for instance, then it is likely that you need two base cases, one for T[1], T[2]. You could also use T[0], T[-1] if you prefer as long as the solution works!
  * If we always need to look back from the start, then, it is likely that this is $O(n^2)$.
* Lastly, **backtracking** is not covered in this notes! 

### Longest Increasing Subsequence (LIS)

`Problem statement`

Given a following sequence, find the length of the longest increasing subsequence. For example, given Input: 5, 7, 4, -3, 9, 1, 10, 4, 5, 8, 9, 3, the longest subsequence will be -3, 1, 4, 5, 8, 9, and the answer will be 6.

`Intuition`

Two observations:
* The lookback is always to the start
* Although the lookback starting point can change, for example:
  * 5 4 -3 -2 -1 0 1 2 3, then at `-3` is where we should start
  * So, this tells us we should use the `strong` definition.

`Subproblem`

Let T[i] be the longest increasing subsequence, including i.

`Recurrence relation`

```
T[i] = 1 + max{T[j] if x[i] > x[j] : where 1 <= j <= i-1} \\
        where 1 <= i <= n
```

`Psuedocode`

```
for i in range(1,n):
    T[i] = 1
    for j in range(1,i-1):
        if x[i] > x[j] and T[j] + 1 > T[i]:
            T[i] = T[j] + 1

return max(T[.])            
```

`Complexity`

Two inner for loops, hence $O(n^2)$.

### Longest Common Subsequence (LCS)

`Problem statement`

Given two sequences, $x_1,..,x_n$ and $y_1,...,y_m$, find the longest common subsequence. For example given X = BCDBCDA and Y = ABECBAB, then the longest subsequence is BCBA.

`Intuition`

Observations:
* When I add a new character in both of them, it either increases the score or does not.
* Since it may not increase the score (we choose to skip it), then we should use the weak definition.
* Since we are using the weak, then the score must be maximum of either i and j-1, or i-1 and j.

`Subproblem`

Let L[i,j] denote the longest common subsequence between x from 1 up to i, and y from 1 up to j.

`Recurrence relation`

Base case: 

```
L[i, j] = 0 where 0 <= i <= n
L[0, j] = 0 where 0 <= j <= m
```

Relation:

```
L[i,j] = 1 + L[i-1, j-1]  if x[i] == y[j]
    where 1 <= i <= n, 1<= j <= m 
L[i,j] = max(L[i-1, j], L[i, j-1]) if x[i] != y[j] 
    where 1 <= i <= n, 1<= j <= m 
```

`Psuedocode`

```
L[0, j] = 0 # add for loop
L[i, 0] = 0 # add for loop 
for i in range(1,n):
    for j in range(1,m):
        if x[i] == y[j]:
            L[i,j] = 1 + L[i-1, j-1]
        else:
            L[i,j] = max(L[i-1, j], L[i, j-1])
return L[n][m]
```

`Complexity`

Two inner loops, $O(nm)$


### Contiguous Subsequence Max Sum

`Problem statement`

A contiguous subsequence of a list S is a subsequence made up of consecutive elements of S. For instance, if S is 5, 15, −30, 10, −5, 40, 10, then 15, −30, 10 is a contiguous subsequence but 5, 15, 40 is not. Give a linear-time algorithm for the following task:

`Intuition`

* Again, this is similar to LIS we might need to restart the starting point (Observe the answer above is 10, -5, 40, 10). So, this tells us we should be using the **strong** definition.

`Subproblem`

Let T[i] be the max sum of the subsequence of x from 1, ..., i including i.

`Recurrence relation`

Base case: `T[0] = 0`

```
T[i] = x[i] + max(0, T[i-1]) where 1 <= i <= n
```

`Psuedocode`

```
T[0] = 0
for i in range(n):
    T[i] = x[i] + max(0, T[i-1])
return max(T[.])
```

`Complexity`

Only one for loop, $O(n)$.

### Knapsack

`Problem statement`

Given $n$ items with weights $w_1,w_2,..., w_n$ each with value $v_1,...,v_n$ and capacity $B$, we want to find the subset of objects S, such that we maximize values max($\sum_{i\in S} v_i$ ) but $\sum_{i \in S} w_i < B$..

`Intuition`

* This is a prefix problem, and, when you add a new item, either you can find a better solution, OR you cannot find a better solution.
* So this tells you that you can skip the i item, so, weak definition.
* If you do not include the ith item, then the best at i, is i-1.

Also, since this is knapsack, we also need to vary the weight B.

`Subproblem`

Let K(i, b) to be the optimal solution involving up to the first i items with capacity b. 

`Recurrence relation`

Base case: 

```
K(i, 0) = 0 where 1 <= i <= n
K(0, b) = 0 where 1 <= b <= B
```

Relation:

```
K(i,b) = max(
        v[i] + K(i-1, b - w[i]), 
        K(i-1,b)
        ) where 1 <= i <= n, w[i] <= b
```

`Psuedocode`

```
K(i,0) = 0 # add for loop
K(0, b) = 0 # add for loop

for i in range(1, n):
    for b in range(1,B):
        tmp1 = v[1] + K(i-1, b-w[i])
        tmp2 = K(i-1,b)
        K(i,w) = max(tmp1,tmp2)
return K(n,B)
```

`Complexity`

There is two loops, N, and W, so, $O(NB)$.

`Extra notes:`

* Knapsack is also known as a Pseudo-polynomial time problem because of B.

### Knapsack with repetitions

`Problem statement`

Same as above, but now you have unlimited items of each. 

`Intuition`

* Then this becomes simple, when you add a new item, either it can help you get a better score, or, it cannot!
* Problem definition should remain weak.

You can choose to modify the above approach and simplify use:

$$
K(i,b) = max(v_i + K(i-1, b-w_i), K(i-1,b))
$$

But there is an easier way:

* We can just remove the `K(i-1,b)` since we are no longer constraint on the items, so:

`Subproblem`

Let K(b) be the maximum value obtainable from weight 1 ... b up to B.

`Recurrence relation`

```
K(b) = max{v[i] + K(b - w[i])}
    where 1 <= i <= n, w[i] <= b
```

`Psuedocode`

```
for b in range(1,B)
    K[b] = 0
    for i in range(1,n):
        if w[i] < b and K[b] < v[i] + K[b-w[i]]:
            K[b] = v[i] + K[b-w[i]]
return K(B)
```

`Complexity`

Complexity does not change, and remains $O(nB)$.

### Chain Matrix Multiply 

`Problem statement`

Given an sequence of matrices $A_1...,A_n$, find the optimal cost of computing them.

`Intuition`

* So, this is the classic case of a "window" problem, where I can cut $A_1...,A_n$, and get $A_1...A_j$ and $A_{j+1}...A_n$, then perhaps cut $A_1...A_k$ and $A_{k+1}...A_j$. This "sliding window" makes it $n^2$ subproblems.
* For this question at least, you must involve $A_i$, so, it should be strong definition.

`Subproblem`

Let $C(i,j)$ be the optimal cost of calculating $A_1....A_i$ including i.

For an arbitrary matrix, $A_i$, the dimensions is $m_{i-1},m_{i}$

`Recurrence relation`

The base case is to define the lower triangle (including diagonals) to be all 0.

Base case:

```
C[i,j] = 0 where 1 <= j <= i <= n.
```

Relation:

```
C(i,j) = min{ C(i,l) + C(l+1, j) + m_{i-1} m_l m_j }
    where i <= l <= j-1
    and 1 <= j < i <= n
```

Special note - the `1 <= j < i <= n` represents the upper triangle excluding the diagonals.

`Psuedocode`

```
for i in range(1,n):
  C[i,i] = 0 # For code wise, we ignore lower diagonals

for s in range(1,n-1):
  for i in range(1, n - s):
    j = i+s
    C[i,j] = infinity
    for l in range(i, j-1):
      curr = (m[i-1] * m[l] * m[j]) + C(i,l) + C(l+1,j)
        if C[i,j] > curr:
          C[i,j] = curr
return C[1,n]
```

`Complexity`

Three for loops, hence $O(n^3)$.

Extra note - Depending on certain type of questions, you might need pad the start and end with $A_0$ and $A_{n+1}$ to indicate the start and end such as the string cutting problem (Dpv 6.9).

### Bellman-Ford

`Problem statement`

Given $\overrightarrow{G}$ with edge weights and vertices $V$, find the shortest path from source node $s$ to target node $Z$.

`Intuition`

* So, we consider the nodes 1,..., i. When we add i, is either we found a better solution to Z, or we don't.
* Since we can skip node i, then this should also be weak subproblem.

`Subproblem`

Denote D(i,z) to be the shortest path from i to z by using nodes 1,...,i up to i.

`Recurrence relation`

Base case:

```
D(0, s) = 0 for all s except z
D(0, z) = infinity
```

Relation:

```
D(i,z) = min {D(i-1, y) + w(y,z), D(i-1, Z)}
where 1 <= i <= length(V)-1 and there exists an edge y->z
```

(Note, i is from 1 to n-1 since we exclude z where z is the nth node)

`Psuedocode`

```
for z in range(1, length(V)):
  D(0,z) = infinity
for i in range (1, n-1):
  for z in V:
    # for all nodes in V
    D(i,z) = D(i-1, z)
    for all yz in E:
      if D(i,z) > D(i-1,y) + w(y,z):
        D(i,z) = D(i-1,y) + w(y,z)
Return D(n-1,:)
```

`Complexity`

Initially, you might think that there the complexity is $O(N^2E)$ because of the 3 nested for loops. But, in the 2nd and 3rd nested for loop, it is actually going through all edges (If you go through all nodes and all the edges within each node, it is actually going through all the edges). So the time complexity is actually $O(NE)$.

`Extra notes:`

**How to find negative cycle?**

Now, how can you use bellman ford to detect if there is a negative cycle? Notice that the algorithm runs until n-1. Run it for one more time, and compare the difference. If the solution is different, then, some negative weights must exists.

In other words, check for:

$$
D(n,z) < D(n-1,z), \exists z \in V
$$

**What if we want to find all pairs? (y,z)**

In the above implementation, z is still fix, means we want to find shortest path from all possible s to all possible z, to accomplish this we repeat the above algorithm for $N$ times where $N$ is the number of nodes.

Then in this case, the complexity is $O(N^2E)$. But, in the event that this is a fully connected graph, then $E=N^2$ which means the overall complexity $O(N^4)$. The question becomes `can we do better?` Yes we can!

### Floyd-Warshall 

`Problem statement`

Find all pairs!

`Intuition`

* This is the same logic is just that we are using 3 for loops.
* When adding an new node i, we either make use of it and find a better path, or we don't.

`Subproblem`

For $0 \leq i \leq n$ and $1 \leq s, t \leq n$, let $D(i,s,t)$ be the length of the shortest path from $s\rightarrow t$ using a subset $\{1, ..., i\}$ as intermediate vertices. Note, the key here is intermediate vertices.

So, $D(0,s,t)$ means you can go to t from s directly without any intermediate vertices.

`Recurrence relation`

Basecase:

```
D(0,s,t) = w(s,t) if there exists an edge linking s to t
D(0,s,t) = infinity otherwise
```

Relation:

```
D(i,s,t)=min{ D(i-1,s,t), D(i-1,s,i) + D(i-1,i,t)}
      where 1 <= i,s,t <= n
```

`Psuedocode`

```
for s=1->n:
    for t=1->n:
        if (s,t) in E 
            then D(0,s,t)=w(s,t)
        else D(0,s,t) = infinity

for i=1->n:
    for s=1->n:
        for t=1->n:
            D(i,s,t)=min{ D(i-1,s,t), D(i-1,s,i) + D(i-1,i,t) }

Return D(n,:,:)
```

`Complexity`

The complexity here is clearly $O(N^3)$.

`Extra notes:`

**Checking negative cycles**

To detect negative weight cycles, can check the diagonal of the matrix D. 
* If there is a negative cycle, then there should be a negative path length from a vertex to itself, i.e $D(n,y,y) < 0, \exists y \in V $. 
  * This is equivalent to checking whether there is any negative entries on the diagonal matrix $D(n,:,:)$.

### Edit Distance

`Problem statement`

Edit distance between two strings of size n, and size m.

`Intuition`

* Similar to the Longest Common Subsequence, when you add a new character in either case x[i] and y[j], the edit distance can remain the same if x[i] == y[j]
* If they are not the same, then, there are 3 cases to consider
  * x[1, ..., i-1] against y[1, ..., j]
  * x[1, ..., i] against y[1, ..., j-1]
  * x[1, ..., i-1] against y[1, ..., j-1] 
* Again, you can skip either i or j, so weak problem definition.

`Subproblem`

Let D(i,j) be the edit distance of strings x and y, up to i and j.

`Recurrence relation`

Base case:

```
D(i,0) = 0 # for loop i
D(0,j) = 0 # for loop j
```

Relation:

```
D(i,j) = min(
        D(i-1, j-1) + diff(x[i], y[j]),
        D(i-1, j) + 1,
        D(i, j-1) + 1
)
```

`Psuedocode`

```
D(i,0) = 0 # for loop i
D(0,j) = 0 # for loop j
for i in range(1, n):
  for j in range(1,m):
    diff = 0 if x[i] == y[j] else 0
    D(i,j) = min(
        D(i-1, j-1) + diff(x[i], y[j]), # replace
        D(i-1, j) + 1, # delete x
        D(i, j-1) + 1  # insert x
)

```

`Complexity`

Complexity is $O(nm)$.

`Extra Notes:` 

* The first case is `D(i-1, j-1) + diff(x[i], y[j])` which is cost of substitute x[i] to y[j].
* The second case is `D(i-1, j) + 1`  which is the cost of deleting x[i]
  * So, imagine we D[i,j] is from D[i-1, j], this means we have delete x[i].
* The last case is `D(i, j-1) + 1` which is the cost of insertion x[i]
  * Again, imagine if D[i,j] is from D[i, j-1], means we insert x[i]

For example take x=`aabc` with y=`aac`, and suppose i = 3, j = 3.

* D[3,3] = D[2, 3] + 1 means we have `aa` and `aac` so we deleted `b` from x,
* D[3,3] = D[3, 2] + 1 means we have `aab` and `aa` so we insert `c` at x[3] so it becomes `aac`


## Divide and Conquer

For Divide and conquer, three sections are required:

* Algorithms.
  * You are allowed to modify Binary search, Merge sort, Fast Select, FFT.
  * If you make modification, it is not enough to state your modification, you need to state **how** you use your modification
  * **STATE YOUR BASE CASE!**
* Justification of correctness
  * Why does the algorithm work? Why did you make certain changes?
  * What is it about the problem size that allows your algorithm to be correct?
* Runtime analysis
  * Even if your modifications is trivial, **remember to state them!**.

Todo?
* Merge sort
* Binary Search

### Master Theorem

$$
T(n) =
\begin{cases}
O(n^d), & \text{if } d > \log_b a \\
O(n^d \log n), & \text{if } d = \log_b a \\
O(n^{\log_b a}), & \text{if } d < \log_b a
\end{cases}
$$

For constants $a>0, b>1, d \geq 0$.

The recurrence relation under the Master Theorem is of the form:

$$
T(n) = aT\left(\frac{n}{b}\right) + O(n^d)
$$

Other important thing:

**Logarithms**

This is the change of base for logs which states that $log_a b = \frac{log_c b}{log_c a}$, so we can express $log_b n = \frac{log_a n}{log_a b}$, and we have $(log_a b)^{-1} = (\frac{log_b b}{log_b a})^{-1} = log_b a$ 

$$
\begin{aligned}
a^{log_b n} &= a^{(log_a n)(log_b a)} \\
&= (\underbrace{a^{log_a n}}_{n})^{log_b a} \\
&= n^{log_b a}
\end{aligned}
$$

**L'Hopital rule**

Suppose we have two run times, $n^{2.33}$ and $n^2log n$, we want to find out which one is bigger, to do this, we can use L'Hospital rule which is simply comparing the gradient:

$$
\begin{aligned}
f(n) &=\frac{n^{2.333}}{n^2 logn} = \frac{n^{0.333}}{log n}\\
f'(n)&= \frac{0.333 n^{-0.6666}}{1/n} \\
f'(n) &= cn^{0.333} \\
\therefore lim_{n \rightarrow \infty} f(x) &= \infty
\end{aligned}
$$

So, this shows that $n^{2.333} > n^2 logn$


**Other interesting recurrances**

(Todo?)
* $O(\sqrt{n})$
* $T(n-1)$

**Geometric series**

$$
\sum_{k=1}^{n-1} ar^k  = a\frac{r^n-1}{r-1}
$$

if $r < 1$, and $n \rightarrow \infty$, then $r^n = 0$. Hence we have $\frac{a}{1-r}$.

### Fast Integer Multiply

Lets cover a little about binary, for instance 1 is binary `1`, 3 is `11` and 8 is binary `1000` which is $2^3$.

For example, take 9 * 5 which we know is 45. 45 can be represented as 32+8+4+1 which is $2^5+2^3+2^2+2^0$ which is `101101` in binary.

```
   1001
x   101
-------
   1001 # first bit 1 multiply with 1001
  0000  # Second bit, offset by 1 space and multiply
 1001   # third bit, offset by 2 and multiply
-------
 101101 # Element sum
```

Another thing about shifting bits, for example in python, we take `9<<2` means we are adding two `0` to `1001` which yields `100100`. This is $32+4 = 36$.

We are now ready to go through the Fast Integer Multiply.

Given two integers $x$ and $y$

$$
\begin{aligned}
xy &= ( x_L \times 2^{\frac{n}{2}} + x_R)( y_L \times 2^{\frac{n}{2}} + y_R) \\
&= 2^n \underbrace{x_L y_L}_A + 2^{\frac{n}{2}}(\underbrace{x_Ly_R + x_Ry_L}_{\text{X}}) + \underbrace{x_Ry_R}_B
\end{aligned}
$$

Using Gauss idea, we can replace $X$ with $C-A-B$ as follows:

$$
\begin{aligned}
(x_L+x_R)(y_L+y_R) &= x_L y_L + x_Ry_R + (x_Ly_R+x_Ry_L) \\
(x_Ly_R+x_Ry_L) &= \underbrace{(x_L+x_R)(y_L+y_R)}_{C}- \underbrace{x_L y_L}_A + \underbrace{x_Ry_R}_B \\
\therefore xy &= 2^n A + 2^{\frac{n}{2}} (C-A-B) + B
\end{aligned}
$$

Code:

```
FastMultiply(x,y):
input: n-bit integers, x & y , n = 2**k
output: z = xy 
xl = first n/2 bits of x, xr = last n/2 bits of x
same for yl, yr.

A = FastMultiply(xl,yl), B= FastMultiply(xr,yr)
C = FastMultiply(xl+xr,yl+yr)

Z = (2**n)* A + 2**(n/2) * (C-A-B) + B
return(Z)
```

With Master theorem, $3T(\frac{n}{2}) + O(n) \rightarrow O(n^{log_2 3})$ 


### Linear-time median

In order to find a linear time median, we need to find a good pivot.

To find a good pivot, we simply use the median of medians, this is similar to quick sort. (You can refer to the notes to get a proof in the notes) but the idea is to partition the array into groups of 5, find the median of each of them, and then find the median in each of them. 

To do this, you will have time complexity of 

$$
T(\frac{n}{5}) + O(n)
$$

It can be shown that by doing so, you reduce the problem space by $\frac{3n}{10}$ in each iteration (refer to notes if you want proof).

Once you found p the pivot which is the median of medians,

```
FastSelect(A,k):

Break A into ceil(n/5) groups         G_1,G_2,...,G_n/5
    # doesn't matter how you break A

For j=1->n/5:
    sort(G_i)
    let m_i = median(G_i)

S = {m_1,m_2,...,m_n/5}             # these are the medians of each group
p = FastSelect(S,n/10)              # p is the median of the medians (= median of elements in S)
Partition A into A_<p, A_=p, A_>p

# now recurse on one of the sets depending on the size
# this is the equivalent of the quicksort algorithm 

if k <= |A_<p|:
    then return FastSelect(A_<p,k)    
if k > |A_>p| + |A_=p|:
    then return FastSelect(A_>p,k-|A_<p|-|A_=p|)
else return p
```

**Analysis of run time**:
* Splitting into $\frac{n}{5}$ groups - $O(n)$
* Since we are sorting a fix number of elements (5), it is order $O(1)$, over $\frac{n}{5}$, so, it is still $O(n)$. 
* The first `FastSelect` takes $T(\frac{n}{5})$ time.
* The final recurse takes $T(\frac{3n}{4})$

$$
\begin{aligned}
T(n) &= T(\frac{3n}{4})+ T(\frac{n}{5}) + O(n) \\
&= O(n)
\end{aligned}
$$

### FFT

#### n-th roots of unity

An nth root of unity, where n is a positive integer, is a number z satisfying the $z^n =1$, so we can define $\omega$ to be:

$$
\omega_n = e^{2\pi i/n} = (1, \frac{2\pi i}{n})
$$

Note, the subscript $n$ refers to the roots of unity, e.g $\omega_16$ refers to the 16 roots of unity.

To see that this is true: $\omega_n^n = e^{2\pi i} $, and $2\pi$ is exactly 1 circle (360 degrees), going back to the starting point on the real axis. So $e^{2\pi i} = 1$

#### sum of nth roots of unity

The sum of the n-th roots and with a little help from geometric series:

$$
w_n^0 + ... + w_n^{n-1} = \frac{\omega_n^n - 1}{\omega_n -1}
$$

But we established that $\omega_n^n = 1$ so the above expression evaluates to be 0.

#### Plus minus property

We consider the 4 roots of unity, which is 1, i, -1, i. If we see, the first half is the opposite of the second half. In general:

$$
\omega_n^j = -\omega_n^{\frac{n}{2} +j}, \omega_n^j = e^{2\pi ij/n}
$$

This is because you are adding across $\frac{n}{2}$ points which is half the circle $\pi$.

Take the 16 roots for example, suppose we take the first root and nine root:

$$\begin{aligned}
\omega_{16}^1 &= e^{2\pi i / 16} \\
\omega_{16}^9 &= e^{2\pi i \times 9 / 16} \\
&= e^{2\pi i \times 1 / 16 + 2 \pi i \times (8/16)} \\
&= e^{2\pi i/ 16} \underbrace{e^{\pi i}}_{-1} \\
&= -e^{2\pi i/ 16} \\
&= -\omega_{16}^1 \\
\end{aligned}
$$

#### Square property

The square property is the following equation:

$$
(w_{2n}^j)^2 = w_n^j
$$

This should be obvious because:

$$
(w_{2n}^j)^2 = (e^{2\pi ij /2n})^2 = e^{2\pi ij /n} = w_n^j
$$

#### Polynomial representation

For every polynomial of degree $n-1$, we can represent it by $n$ points. For example a straight line of degree $1$, can be presented by two points, a polynomial can be represented by $3$ points etc. You can visualize this by constructing a system of linear equations and given 3 points, you can revers engineer the polynomial. The goal now is to transform a polynomial into these points so we can use them efficient uses later, but this is the gist of the FFT algorithm.

For a polynomial $A(x) = a_0x^0 + a_1x^1 + .... + a_{n-1}x^{n-1}$, we assume $n$ is even so $n-1$ is odd for simplicity. 

$$
\begin{aligned}
A_{even}(y) &= a_0y^0 + a_2y^1 + ... + a_{n-2}y^{\frac{n-2}{2}} \\
A_{odd}(y) &= a_1y^0 + a_3y^1 + ... + a_{n-1}y^{y^{\frac{n-2}{2}}} \\
\therefore A(x) &= A_{even}(x^2) + x A_{odd}(x^2)
\end{aligned}
$$

So, given a polynomial of degree $d-1$ ($1+x+...+x^{d-1}$), first, find the nth roots of unity such that $2^n > d$. For instance if you have a polynomial of degree 6, you need 7 roots so we round up to 8. The goal is to compute:

$$
\begin{aligned}
A(\omega_n^j) = A_{even}((\omega_n^j)^2) + \omega_n^jA_{even}((\omega_n^j)^2)
\end{aligned}
$$

Notice that we can make use of our $\pm$ property, so:

$$
\begin{aligned}
A(\omega_n^{\frac{n}{2} + j}) &= A(-\omega_n^j)\\
 &= A_{even}((\omega_n^j)^2) - \omega_n^jA_{even}((\omega_n^j)^2)
\end{aligned}
$$

With this, we can now state our FFT algorithm.

#### FFT algorithm

The inputs are $a= (a_0, a_1, ..., a_{n-1})$ for Polynomial $A(x)$ where n is a power of 2 with $\omega$ is a $n^{th}$ roots of unity. The desired output is $A(\omega^0), A(\omega^1), ..., A(\omega^{n-1})$ 

We let $\omega = \omega_n = (1, \frac{2\pi}{n}) = e^{2\pi i/n}$

* if $n=1$, return $(a_0)$
* let $a_{even} = (a_0, a_2, ..., a_{n-2}), a_{odd} = (a_1, ..., a_{n-1})$
* Call $FFT(a_{even},\omega^2) = (s_0, s_1, ..., s_{\frac{n}{2}-1})$
* Call $FFT(a_{odd},\omega^2) = (t_0, t_1, ..., t_{\frac{n}{2}-1})$
* For $j = 0 \rightarrow \frac{n}{2} -1$:
  * $r_j = s_j + w^j t_j$
  * $r_{\frac{n}{2}+j} = s_j - w^j t_j$
* Return $r_1, ..., r_{n-1}$

#### FFT Runtime analysis

Notice that we split the problem into half, and recurse based on odd and even. As a last step, we do a for loop through all of the roots of unity making it $O(n)$. This gives the recurrence:

$$
2T(\frac{n}{2}) + O(n) = O(nlogn)
$$

#### Multiply Two polynomials

Given two polynomials, $A(x) = a_0x^0 + ... + a_{i-1}x^{i-1}$ and $B(x) = b_0x^0 + ... + b_{j-1}x^{j-1}$. Our goal is to find $C(x) = A(x)B(x)$.

We find the nth roots of unity, such that $2^n > i+j-2$. For instance if you have a degree 3 polynomial with a degree 5 polynomial,$i-1 + j -1 = 4-1+6-1 = 9$, so you need 16 roots of unity.

We first transform:

$$
\begin{aligned}
A(x) &= (\alpha_0, \alpha_1, ..., \alpha_n) \\
B(x) &= (\beta_0, \beta_1, ..., \beta_n) \\
\therefore C(x) &= (\alpha_0 \times \beta_0, ...,\alpha_n \times \beta_n )
\end{aligned}
$$

To convert $C(x)$ back to its polynomial, we simply run inverse FFT.

#### Inverse FFT

Without proof (refer to the notes if you want), note that:

$$
w_n^1 * w_n^{-1} = w_n^0 = 1 \\
w_n^1 * w_n^{n-1} = w_n^n = 1
$$

So, this means that we can just simply go in the opposite direction (clockwise) to get the inverse!

Given $FFT(A,w_n)$ where A is any polynomial and the nth roots of unity, 

$$
\begin{aligned}
FFT(A, w_n) &= (A(\omega_n^0),A(\omega_n^1), ..., A(\omega_{n-1}^{n-1}))\\
&= (\alpha_0, \alpha_1, ...,\alpha_{n-1}) \\
&= A'
\end{aligned}
$$

Then the inverse is (Notice the opposite/clockwise direction):

$$
\begin{aligned}
IFFT(A', w_n) &= \frac{1}{n}FFT(A',w_n^{-1})\\
&= (A'(\omega_n^0),A'(\omega_n^{-1}), ..., A'(\omega_{n-1}^{-(n-1)}))\\
&= (A'(\omega_n^0),A'(\omega_n^{n-1}), ..., A'(\omega_{n-1}^{1}))\\
\end{aligned}
$$

So, the overall process for multiplying two polynomials looks like this:

Input: Coefficients $a = (a_0, ..., a_{n-1})$ and $b = (b_0, ..., b_{n-1})$
Output: $C(x) = A(x)B(x)$ where $c = (c_0, ..., c_{2n-2})$

* FFT$(a,\omega_{2n}) = (r_0, ..., r_{2n-1})$
* FFT$(b,\omega_{2n}) = (s_0, ..., s_{2n-1})$
* for $j = 0 \rightarrow 2n-1$
  * $t_j = r_j \times s_j$
* Have $C(x)$ at $2n^{th}$ roots of unity and run inverse FFT
  * $(c_0, ..., c_{2n-1}) = \frac{1}{2n}FFT(t, \omega_{2n}^{2n-1})$

#### Useful matrix to remember

$$
\begin{bmatrix}
A(1) \\ A(\omega_n) \\ A(\omega_n^2)\\ \vdots \\ A(\omega_n^{n-1})
\end{bmatrix} =
\begin{bmatrix}
1 & 1 & 1 & ... & 1 \\
1 & \omega_n & \omega_n^2 & ... & \omega_n^{n-1} \\
1 & \omega_n^2 & \omega_n^4 & ... & \omega_n^{2(n-1)} \\
     &      & \ddots &   &    \\
1 & \omega_n^{n-1} & \omega_n^{2(n-1)} & ... & \omega_n^{(n-1)(n-1)} \\
\end{bmatrix}
\begin{bmatrix}
a_0 \\ a_1 \\ a_2 \\ \vdots \\ a_{n-1}
\end{bmatrix}
$$

Notice that the matrix is symmetric.

For example, if we use forth roots of unity, we have  $\omega_n = 1, i, -1 , -i$

$$
\begin{bmatrix}
A(\omega_4^0) \\ A(\omega_4^1) \\ A(\omega_4^2) \\ A(\omega_4^{3})
\end{bmatrix} =
\begin{bmatrix}
1 & 1 & 1 & 1 \\
1 & i & -1  & -i \\
1 & -1 & 1 & -1 \\
1 & -i & -1 & i \\
\end{bmatrix}
\begin{bmatrix}
a_0 \\ a_1 \\ a_2  \\ a_{3}
\end{bmatrix}
$$

So suppose we have coordinates $c_0, c_1, c_2 ,c_3$ and we want to transform back:

$$
\begin{bmatrix}
1 & 1 & 1 & 1 \\
1 & i & -1  & -i \\
1 & -1 & 1 & -1 \\
1 & -i & -1 & i \\
\end{bmatrix}^{-1}
\begin{bmatrix}
c_0 \\ c_1 \\ c_2  \\ c_{3}
\end{bmatrix}=
\frac{1}{4}
\begin{bmatrix}
1 & 1 & 1 & 1 \\
1 & -i & -1 & i \\
1 & -1 & 1 & -1 \\
1 & i & -1  & -i \\
\end{bmatrix}
\begin{bmatrix}
c_0 \\ c_1 \\ c_2  \\ c_{3}
\end{bmatrix}
$$

Notice the rows of the matrix, we went from $(\omega_4^0,\omega_4^1,\omega_4^2,\omega_4^3)$ to $(\omega_4^0, \omega_4^3,\omega_4^2,\omega_4^1)$ when calculating the inverse.





