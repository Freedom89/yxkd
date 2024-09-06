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
 
For case 1, the work is dominated by the cost of solving the subproblems.

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

For case 3, the work is dominated by the cost of dividing/combining the problem. An example of this is binary search.


### Fast Integer multiplication

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



<!-- {% include embed/youtube.html id='10oQMHadGos' %} -->