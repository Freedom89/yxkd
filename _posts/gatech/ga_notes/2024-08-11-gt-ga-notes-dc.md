---
toc: true
mermaid: true
hidden: true
math: true
---

### Master theorem

Note, this is the simplified form of the Master Theorem, which states that:

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


where:

* $a$: Number of subproblems the problem is divided into.
* $b$: Factor by which the problem size is reduced.
* $O(n^d)$: Cost of work done outside the recursive calls, such as dividing the problem and combining results.

**Understanding the Recursion Tree**

To analyze the total work, think of the recursion as a tree where:

* Each level of the tree represents a step in the recursion.
* The root of the tree represents the original problem of size $n$.
* The first level of the tree corresponds to dividing the problem into $a$ subproblems, each of size $\frac{n}{b}$.
* The next level corresponds to further dividing these subproblems, and so on.

**Cost at the $k-th$ level:**

* Number of Subproblems:

  $$
  \text{Number of subproblems at level } k = a^k
  $$

  At each split, it produces $a$ sub problems, after $k$ splits, hence $a^k$.

* Size of Each Subproblem:

  $$
  \text{Size of each subproblem at level } k = \frac{n}{b^k}
  $$

  During each step, the problem is reduced by $b$. E.g in binary search, each step reduces by half, $\frac{n}{2}$. After $k$ steps, it will be $\frac{n}{2^k}$

* Cost of Work at Each Subproblem:

  $$
  \text{Cost of work at each subproblem at level } k = O\left(\left(\frac{n}{b^k}\right)^d\right)
  $$

  This is the cost of merging. For example in merge sort, cost of merging is $O(n)$ which is linear. 

* Thus, total cost at level k :

  $$
  \text{Total cost at level } k = a^k \times O\left(\left(\frac{n}{b^k}\right)^d\right) = O(n^d) \times \left(\frac{a}{b^d}\right)^k
  $$


Then, $k$ goes from $0$ (the root) to $log_n b$ levels (leaves), so,

$$
\begin{aligned}
S &= \sum_{k=0}^{log_b n} O(n^d)  \times \left(\frac{a}{b^d}\right)^k \\
&= O(n^d) \times \sum_{k=0}^{log_b n}  \left(\frac{a}{b^d}\right)^k
\end{aligned}
$$

Recall that for geometric series, $\sum_{i=0}^{n-1} ar^i = a\frac{1-r^n}{1-r}$. So, we need to consider $\frac{a}{b^d}$. So, when $n$ is large:

Case 1:

If $d> log_b a$, then $ a < b^d $ thus $\frac{a}{b^d} < 1$. So when $n$ is large,

$$
\begin{aligned}
S &= O(n^d) \times \sum_k^\infty (\frac{a}{b^d})^k \\ 
&= O(n^d) \times \frac{1}{1-\frac{a}{b}} \\
&\approx O(n^d)
\end{aligned}
$$
 
For case 1, the work is dominated by the cost of the non-recursive work (i.e., the work done in splitting, merging, or processing the problem outside of the recursion) dominates the overall complexity. 

Case 2:

if $d = log_b a$, then $a = b^d$ thus $\frac{a}{b^d} = 1$.

$$
\begin{aligned}
S &= O(n^d) \times \sum_k^{log_b n} \underbrace{(\frac{a}{b^d})^k}_{1} \\ 
&= O(n^d) \times  log_b n \\
&\approx O(n^d log_b n) \\
&\approx O(n^d log n) \\
\end{aligned}
$$

Notice that the log base is just a ratio that we can further simplify.

For case 2, The work is evenly balanced between dividing/combining the problem and solving the subproblems. Another way to think about it is, at each step there is $n^d$ work, with $log_b n \approx log n $ levels, so the total work is $O(n^d log n)$

Case 3:

If $d < log_b a$ then $a > b^d$ thus $\frac{a}{b^d} > 1$. 

$$
\begin{aligned}
S &= O(n^d) \times \sum_{k=0}^{log_b n} (\frac{a}{b^d})^k \\ 
&= O(n^d) \times \frac{(\frac{a}{b^d})^{log_b n}-1}{\frac{a}{b^d}-1}\\
&\approx  O(n^d) \times (\frac{a}{b^d})^{log_b n}-O(n^d) \\
&\approx  O(n^d) \times (\frac{a}{b^d})^{log_b n}\\
&= O(n^d) \times \frac{a^{log_b n}}{(b^{log_b n})^d}\\
&= O(n^d) \times \frac{a^{log_b n}}{n^d}\\
&= O(a^{log_b n}) \\
&= O(a^{(log_a n)(log_b a)}) \\
&= O(n^{log_b a})
\end{aligned}
$$

For case 3, the work is dominated by the cost of recursive subproblems dominates the overall complexity


### Fast Integer multiplication (DC1)

Given two (large) n-bit integers $x \& y$, compute $ z = xy$.

Recall that we want to look at the running time as a function of the number of bits. The naive way will take $O(N^2)$ time. 

Inspiration:

Gauss's idea: multiplication is expensive, but adding/subtracting is cheap.

2 complex numbers, $a+bi\ \&\ c+di$, wish to compute $(a+bi)(c+di) = ac - bd + (bc + ad)i$. Notice that in this case we need 4 real number multiplications, $ac,bd,bc,ad$. Can we reduce this 4 multiplications to 3? Can we do better?

Obviously it is possible! The key is that we are able to compute $bc+ad$ without computing the individual terms; not going to compute $bc, ad$ but instead $bc+ad$, consider the following:

$$
\begin{aligned}
(a+b)(c+d) &= ac + bd + (bc + ad) \\
(bc+ad) &= \underbrace{(a+b)(c+d)}_{term3} - \underbrace{ac}_{term1} - \underbrace{bd}_{term2}
\end{aligned}
$$

So, we need to compute $ac, bd, (a+b)(c+d)$ to obtain $(a+bi)(c+di)$. We are going to use this idea to multiply the n-bit integers faster than $O(n^2)$

Input: n-bits integers x,y and assume $n$ is a power of 2 - for easy computation and analysis.

Idea: break input into 2 halves of size $\frac{n}{2}$, e.g $x = x_{left} \lvert x_{right}$, $y = y_{left} \lvert y_{right}$

Suppose $x=2=(10110110)_2$:
* $x_{left} = x_L = (1011)_2 = 11$
* $x_{right} = x_R= (0110)_2 = 6$
* Note, $182 = 11 \times 2^4 + 6$
* In general, $x = x_L \times 2^{\frac{n}{2}} + x_R$

Divide and conquer: 

$$
\begin{aligned}
xy &= ( x_L \times 2^{\frac{n}{2}} + x_R)( y_L \times 2^{\frac{n}{2}} + y_R) \\
&= 2^n \underbrace{x_L y_L}_a + 2^{\frac{n}{2}}(\underbrace{x_Ly_R}_c + \underbrace{x_Ry_L}_d) + \underbrace{x_Ry_R}_b
\end{aligned}
$$

```
EasyMultiply(x,y):
input: n-bit integers, x & y , n = 2**k
output: z = xy 
xl = first n/2 bits of x, xr = last n/2 bits of x
same for yl, yr.

A = EasyMultiply(xl,yl), B= EasyMultiply(xr,yr)
C = EasyMultiply(xl,yr), D= EasyMultiply(xr,yl)

Z = (2**n)* A + 2**(n/2) * (C+D) + B
return(Z)
```

running time: 

* $O(n)$ to break up into two $\frac{n}{2}$ bits, $x_L,x_R, y_L,y_R$
* To calculate A,B,C,D, its $4T(\frac{n}{2})$
* To calculate $z$, is $O(n)$
  * Because e.g we need to shift $A$ by $2^n$ bits.

So the total complexity is: $4T(\frac{n}{2}) + O(n)$ 

Let $T(n)$ = worst-case running time of EasyMultiply on input of size n, and by master theorem, this yields $O(n^{log_2 4}) = O(n^2)$

As usual, as with everything, **can we do better?** Can we change the number `4` to something better like `3`? I.e we are trying to reduce the number of 4 sub problems to 3.

**Better approach:**

$$
\begin{aligned}
xy &= ( x_L \times 2^{\frac{n}{2}} + x_R)( y_L \times 2^{\frac{n}{2}} + y_R) \\
&= 2^n \underbrace{x_L y_L}_1 + 2^{\frac{n}{2}}(\underbrace{x_Ly_R + x_Ry_L}_{\text{Change this!}}) + \underbrace{x_Ry_R}_4
\end{aligned}
$$

Using Gauss idea:

$$
\begin{aligned}
(x_L+x_R)(y_L+y_R) &= x_L y_L + x_Ry_R + (x_Ly_R+x_Ry_L) \\
(x_Ly_R+x_Ry_L) &= \underbrace{(x_L+x_R)(y_L+y_R)}_{c}- \underbrace{x_L y_L}_a + \underbrace{x_Ry_R}_b \\
\therefore xy &= 2^n A + 2^{\frac{n}{2}} (C-A-B) + B
\end{aligned}
$$

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

Example:

Consider $z=xy$, where $x=182, y=154$. 

* $x = 182 = (10110110)_2, y= 154 = (10011010)_2$
  * $x_L = (1011)_2 = 11$
  * $x_R = (0110)_2 = 6$
  * $y_L = (1001)_2 = 9$
  * $y_R = (1010)_2 = 10$
* $A = x_Ly_L= 11*9 = 99$
* $B = x_Ry_R = 6*10 = 60$  
* $C = (x_L + x_R)(y_L + y_R) = (11+6)(9+10) = 323 $

$$
\begin{aligned}
z & =  2^n A + 2^{\frac{n}{2}} (C-A-B) + B\\
&= 2^8* 99 + 2^4 * (323-99-60) + 60 \\
&= 28028
\end{aligned}
$$

### Linear-time median (DC2)

Given an unsorted list $A=[a_1,...,a_n]$ of n numbers, find the median ($\lceil \frac{n}{2}\rceil$ smallest element). 

Quicksort Recap:

* Choose a pivot p 
* Partition A into $A_{< p}, A_{=p}, A_{>p}$
* Recursively sort $A_{< p}, A_{>p}$

Recall in quicksort the challenging component is choosing the pivot, and if we reduce the partition by only 1, this results in the worse case can result in $O(n^2)$. So what is a good pivot? the median but how can we find this median without sorting which is $O(n log n)$.

The key insight here is we do not need to consider all of $A_{< p},A_{=p}, A_{>p}$, we just need to consider 1 of them.

```
Select(A,k):
Choose a pivot p (How?)
Partition A in A < p, A = p, A > p          
if  k <= |A_{<p}|        
    then return Select(A_{<p},k)               
if  |A_{<p}| < k <= |A_{>p}| + |A_{=p}|           
    then return p            
if  k > |A_{>p}| + |A_{=p}|  
    then return Select(A_{>p}, k - |A_{<p}| - |A_{=p})| 
```    

**The question becomes, how do we find such a pivot?**

The pivot matters a lot, because if the pivot is the median, then, our partition will be $\frac{n}{2}$ which fields $T(n) = T(\frac{n}{2}) + O(n)$, which will achieve a running time of $O(n)$. 

However, it turns out we do not need $\frac{1}{2}$, we just need something that can reduce the problem at each step, for example $T(n) = T(\frac{3n}{4}) + O(n)$ where each step only eliminates $\frac{1}{4}$ of the problem space, which will still give us $O(n)$. It turns out we just need the constant factor to be less than 1 (do you know why?), so, even 0.99 will work!

For the purpose of this lectures, we consider a pivot $p$ is good, if it reduces the problem space by $\frac{1}{4}$. i.e $\lvert A_{<p}| \leq \frac{3n}{4} \&  \lvert A_{>p}| \leq \frac{3n}{4} $.

Assume for now we have a sorted array, then, the probability of selecting a good pivot is when the number is between $[\frac{n}{4},\frac{3n}{4} ]$, so the probability is half. We can validate the pivot by tracking the size of the split. So this is as good as flipping a coin - what is the expected number of trails before you get a heads? The answer is 2. However, there is still a chance that you keep getting tails, so it does not still guarantee the worst case runtime is $O(n)$. Consider the following:

$$
\begin{aligned}
T(n) &= T\bigg(\frac{3}{4} n\bigg) + \underbrace{T\bigg(\frac{n}{5}\bigg)}_{\text{cost of finding good pivot}} + O(n)\\
&\approx O(n)
\end{aligned}
$$

To accomplish this, choose a subset $S \subset A$, where $\lvert S \rvert = \frac{n}{5}$. Then, we set the pivot = $median(S)$. 

But, now we face another problem, how do we select this sample $S$? :sad: - one problem after another.

Introducing `FastSelect(A,k)`:

```
Input:   A - an unsorted array of size n
         k an integer with 1 <= k <= n 
Output:  k'th smallest element of A

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

The key here is $\frac{3}{4} + \frac{1}{5} < 1$


**Prove of the claim that p is a good pivot**

![image](../../../assets/posts/gatech/ga/dc_median.png)

**Fun exercise**: Why did we choose size 5? And not size 3 or 7?

Recall earlier, for blocks of 5, the time complexity is given by:

$$
T(n) = T(\frac{n}{5}) + T(\frac{7n}{10}) + O(n)
$$

and, $\frac{7}{10} + \frac{1}{5} < 1$.

Now, let us look at the case of 3, assuming we split into n/3 groups:

```
11 21  ... n/6 1 ... n/3 1
12 22  ... n/6 2 ... n/3 2
13 23  ... n/6 3 ... n/3 3 
```

Number of elements: 2 * n/6 = n/3. Likewise, our remaining partition is of size 2n/3. 

Then our formula will look:

$$
\begin{aligned}
T(n) &= T(\frac{2n}{3})+ T(\frac{n}{3}) + O(n) \\
&= O(n logn)
\end{aligned}
$$

Similarly, suppose we use size 7, 

* Number of elements less than or equal to n/14 4 is n/14 * 4 = 2n/7.
* Number of remaining elements more than n/14 4 is 5n/7. 
* Which still leads to a $O(nlogn)$ outcome.


### Solving Recurrences (DC3)

* Merge sort: $T(n) = 2T(\frac{n}{2}) + O(n) = O(nlogn)$
* Naive Integer multiplication:  $T(n) = 4T(\frac{n}{2}) + O(n) = O(n^2)$
* Fast Integer multiplication:  $T(n) = 3T(\frac{n}{2}) + O(n) = O(n^{log_2 3})$
* Median: $T(n) = T(\frac{3n}{4}) + O(n) = O(n)$

An example:

For some constant $c>0$, and given $T(n) = 4T(\frac{n}{2}) + O(n)$:

$$
\begin{aligned}
T(n) &= 4T(\frac{n}{2}) + O(n) \\
&\leq cn + 4T(\frac{n}{2}) \\
&\leq cn + 4[T(4\frac{n}{2^2} + c \frac{n}{2})]\\
&= cn(1+\frac{4}{2}) + 4^2 T(\frac{n}{2^2}) \\
&\leq cn(1+\frac{4}{2}) + 4^2 [4T\frac{n}{2^3} + c(\frac{n}{2^2})] \\
&= cn (1+\frac{4}{2} + (\frac{4}{2})^2) + 4^3 T(\frac{n}{2^3}) \\
&\leq cn(1+\frac{4}{2} + (\frac{4}{2})^2 + ... + (\frac{4}{2})^{i-1}) + 4^iT(\frac{4}{2^i})
\end{aligned}
$$

If we let $i=log_2 n$, then $\frac{n}{2^i}$ = 1.

$$
\begin{aligned}
&\leq \underbrace{cn}_{O(n)} \underbrace{(1+\frac{4}{2} + (\frac{4}{2})^2 + ... + (\frac{4}{2})^{log_2 n -1})}_{O(\frac{4}{2}^{log_2 n}) = O(n^2/n) = O(n)} + \underbrace{4^{log_2 n}}_{O(n^2)} \underbrace{T(1)}_{c}\\
&= O(n) \times O(n) + O(n^2) \\
&= O(n^2)
\end{aligned}
$$

**Geometric series**

$$
\begin{aligned}
\sum_{j=0}^k \alpha^j &= 1 + \alpha + ... + \alpha^k \\
&= \begin{cases}
O(\alpha^k), & \text{if } \alpha > 1 \\
O(k), & \text{if } \alpha = 1 \\
O(1), & \text{if } \alpha < 1
\end{cases}
\end{aligned}
$$

* The first case is what happened in Naive Integer multiplication
* The second case is the merge step in merge sort, where all terms are the same.
* The last step is finding the median where $\alpha = \frac{3}{4}$

**Manipulating polynomials**

It is clear that $4^{log_2 n} = n^2$, what about $3^{log_2 n} = n^c$

First, note that $3 = 2^{log_2 3}$

$$
\begin{aligned}
3^{log_2n} &= (2^{log_2 3})^{log_2 n} \\
&= 2^{\{log_2 3\} \times \{log_2 n\}} \\
&= (2^{log_2 n})^{log_2 3} \\
&= n^{log_2 3}
\end{aligned}
$$

Another example: $T(n) = 3T(\frac{n}{2}) + O(n)$

$$
\begin{aligned}
T(n) &\leq cn(1+\frac{3}{2} + (\frac{3}{2})^2 + ... + (\frac{3}{2})^{i-1}) + 3^iT(\frac{3}{2^i}) \\ 
&\leq \underbrace{cn}_{O(n)} \underbrace{(1+\frac{3}{2} + (\frac{3}{2})^2 + ... + (\frac{3}{2})^{log_2 n -1})}_{O(\frac{3}{2}^{log_2 n}) = O(3^{log_2 n}/2^{log_2 n})} + \underbrace{3^{log_2 n}}_{3^{log_2 n}} \underbrace{T(1)}_{c}\\
&= \cancel{O(n)}\times O(3^{log_2 n}/\cancel{2^{log_2 n}}) + O(3^{log_2 n}) \\
&= O(3^{log_2 n})
\end{aligned}
$$

**General Recurrence**

For constants a > 0, b > 1, and given: $T(n) = a T(\frac{n}{b}) + O(n)$,

$$
T(n) =
\begin{cases}
O(n^{log_b a}), & \text{if } a > b \\
O(n log n), & \text{if } a = b \\
O(n), & \text{if } a < b
\end{cases}
$$

Feel free to read up more about [master theorem](#master-theorem)!

<!-- {% include embed/youtube.html id='10oQMHadGos' %} -->