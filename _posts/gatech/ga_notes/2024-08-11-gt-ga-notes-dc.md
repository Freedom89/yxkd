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

<!-- {% include embed/youtube.html id='10oQMHadGos' %} -->