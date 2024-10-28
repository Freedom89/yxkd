---
toc: true
mermaid: true
hidden: true
math: true
---

### NP1: Definitions

How do we prove that a problem is computationally difficult? Meaning that it is hard to devise an efficient algorithm to solve it for all inputs. 

To do this, we prove that the problem is NP-complete. 
* Define what is NP
* What exactly it means for a problem to be NP-complete 

We will also look at reductions and formalize this concept of reduction.

#### computational complexity 

* What does NP-completeness mean?
* What is $P=NP$ or $P\neq NP$ mean?
* How do we show that a problem is intractable? 
  * unlikely to be solved efficiently
    * Efficient means polynomial in the input size
  * To show this, we are going to prove that it is NP complete

#### P = NP

NP = class of all search problems. (In some courses it talks about decision problems instead which has a need for a witness for particular instances, but thats out of scope)

P = class of search problems that are solvable in polynomial time. 

The rough definition is the problem where we can efficiently verify solutions, so P is a subset of NP. If I can generate solutions in polynomial time then I can also verify in polynomial time. 

So if P = NP, that means I can generate a solution and verify it. If $P \neq NP$, means even if I can verify it, I might not be able to generate it.

Search Problems:
* Form: Given instance I (input),
  * Find a solution $S$ for $I$ if one exists
  * Output NO if I has no solutions
* Requirement: To be a search problem,
  * If given an instance I and solution S, then we can verify S is a solution to I in polynomial time (Polynomial in $\lvert I \lvert$)

Let's take a look at some examples


#### SAT problem

Input: Boolean formula in CNF with n variables and m clauses 
output: Satisfying assignment if one exists, NO otherwise

What is the running time to verify a SAT solution? 
* $O(nm)$

SAT $\in$ NP: 

Given f and assignment to $x_1, ..., x_n$,
* $O(n)$ time to check that a clause is satisfied
* $O(nm)$ total time to verify 

Therefore, SAT is a search problem and therefore SAT is in NP. 

#### Colorings

K-colorings problem:

Input: Undirected $G=(V,E)$ and integer $k > 0$
Output: Assign each vertex a color in $\{1,2,...,k\}$ so that adjacent vertices get different colors and NO if no such k-coloring exists

K-coloring $\in$ NP:

Given G and a coloring, in $O(m)$ time can check that for $(v,w) \in E$, color of v $\neq$ color of w.

#### MST

Input: $G=(V,E)$ with positive edge lengths
Output: tree T with minimum weight 

Is MST in the class P? - Can you generate a solution in polynomial time?
* MST is a search problem
* Can clearly find a solution, run Krushal's or pim

Is MST in class NP? Can you verify a given solution in polynomial time?
* Run BFS/DFS to check that T is a tree
* To check if its minimum weight, run Kruskal's or Prims to check that T has min weight.
  * May output different tree, but will have the same minimum weight.
  * Same runtime of $O(mlogn)$

#### Knapsack

Input: n objects with integer values $w_1, ... , w_n$ and integer values $v_1, ..., v_n$ with capacity $B$
Output: Subset S of objects with:
* Total weight $\leq B$
* Maximum total value

Two variants of knapsack, with and without repetition. 

Is Knapsack in the class NP?

Given a solution $S$, we need to check in polynomial time that $\sum_{i \in S} w_i \leq B$. This can be done in $O(n)$ time. 

The second thing to check is $\sum_{i \in S} v_i$ is optimal. Unlike MST, we cannot run the MST algorithm, and the running time for knapsack is $O(nB)$.
* The runtime is not polynomial in the input size. (Not in n, logB bits)
* Knapsack not known to be in NP
 
Knapsack is in NP, is incorrect. We do not know how to show that knapsack is in NP. Is knapsack not in NP? We cannot prove that at the moment, if we could prove that knapsack is not in NP, that would imply that P is not equal to NP. So as far as we know right now knapsack is not known to be in the class NP. 

Is Knapsack in the class P? Also No.

Similarly, Knapsack is not known to be in the class P. There might be a polynomial time algorithm for knapsack, P might be equal NP in which case knapsack will lie in NP. 

There is a simple variant of the knapsack problem which is in the class NP, what we are going to have to do is drop the optimization (max) and add in another input parameter. 
* That additional input parameter is going to be our goal for the total value and then we are going to check check whether our total value of our subset is at least the goal.
  * We can do binary search on that additional parameter, the goal for the total value. 

#### Knapsack-Search

Input: weights $w_1, ..., w_n$ values $v_1, ..., v_n$ with capacity B and **goal g**.

Output: subset S with $\sum_{i \in S} w_i \leq B$ and $\sum_{i \in S} v_i \geq g$

If no such subset $S$ exists, output NO.

Notice in the original version we are maximizing this sum of the total value, here we are simply finding a subset whose total value is at least $g$. Now, suppose that we could solve this version in polynomial time, how do we solve the maximization version? 

Well, we can simply do binary search over this $g$ and by doing binary search over $g$ and we find the maximum $g$ which has a solution, then that tells us the maximum total value that we can achieve. 

How many rounds in our binary search are we going to have to run? The maximum value is clearly all the items available:

$$
V = \sum_{i=1}^n v_i
$$

So we need to do binary search between 1 and $V$. So the total number of rounds in binary search is going to be $O(log V)$. Notice that to represent $v_1, ..., v_n$ is $log v_i$ bits. So this binary search algorithm is polynomial in the input size.

Now this version can be solved in NP time, need to check in poly-time:

Given input $w_1, ..., w_n, v_1, ..., v_n, B, g$ and solution $S$, 
* $\sum_{i \in S} w_i \leq B$
* $\sum_{i \in S} v_i \geq g$

Both of the above can be checked in $O(n)$ time. 

Special note, you might be confused why the sum is $O(n)$ but since the input size is $log W$ and $log V$, the sum of these is still $nlogW, nlogV$ which is still in polynomial time. 

#### P=NP revisited

* P stands for polynomial time. 
* NP stands for nondeterministic polynomial time 
  * problems that can be solved in poly-time on a nondeterministic machine
  * By nondeterministic time, it means it is allowed to guess at each step 

The whole point of this is to tell you that NP does not meant not-polynomial time, but it is nondeterministic polynomial time.

So recall that:

* NP = all search problems
* P = search problems that can be solved in poly-time
  * $P \subset NP$

![image](../../../assets/posts/gatech/ga/np1_pnpsubset.png){: width='200'}

The question now is, are there problems lie in NP which do not lie in P? That means $P\neq NP$ and there are some problems that we cannot solve in polynomial time.

#### NP-completeness

if $P\neq NP$ what are intractable problems? Problems that we cannot solve in polynomial time.
* NP-complete problems 
  * Are the hardest problems in the class NP

If $P\neq NP$ then all $NP$-complete problems are not in P.

The contra positive of this statement is:

If a NP-complete problem can be solved in poly-time, then all problems in NP can be solved in poly time. 

Hence to show a problem such as SAT, we have to show that if there is a polynomial time algorithm for SAT then there is a polynomial time algorithm for all problems in the class NP.
* To do that, we are going to take every problem in the class NP, and for each of these problems have a reduction to SAT. 
  * If we can solve SAT in polynomial time, we can solve every such problem in class NP in polynomial time. 

#### SAT is NP-complete 

SAT is NP-complete means:
* SAT $\in$ NP
* If we can solve SAT in poly-time, then we can solve every problem in NP in poly-time. 

![image](../../../assets/posts/gatech/ga/np1_satproblem.png){: width='200'}

* Reduce all problems to SAT! 

If $P\neq NP$ then SAT $\notin$ $P$, then we know that there are some problems in NP which cannot be solved in polynomial time, and therefore we cannot solve SAT in poly-time. 
* Because if we can solve SAT in poly-time then we can solve all problems in NP in polynomial time. 
* Or if you believe that nobody knows how to prove that $P=NP$ then nobody knows a polynomial time algorithm for SAT. 

It might occur to you that a polynomial time to solve SAT does not exists, otherwise we would have proven $P=NP$!

#### Reduction

For problems A and B, a reduction of can be represented as:

* $A \rightarrow B$
* $A \leq B$

Means we are showing that B is at least as hard computationally as A, i.e if we can solve B, then we can solve A. 

If we can solve problem B in poly-time, then we can use that algorithm to solve A in poly-time. 

#### How to do a reduction

Colorings $\rightarrow$ SAT

Suppose there is a poly-time algorithm for SAT and use it to get a poly-time algo for Colorings.

![image](../../../assets/posts/gatech/ga/np1_reduction.png){: width='400'}

You can take any problem $I$, map it with $f$, and use SAT algorithm, get the results and map it back with $h$. If solution does not exists, just return NO.  

So we need to define $f, h$
* $f$ : input for colorings $(G,k) \rightarrow$ input for SAT, $f(G,k)$
* $h$ : solution for $f(G,k)$ $\rightarrow$ solution for colorings

Need to prove that if $S$ is a solution to $f$, then $h(S)$ is a solution to the original $G$. But we also need that if there was no solution to $f$, then there is no solution to the colorings problem.

$S$ is a solution to $f(G,k) \iff$ $h(S)$ is a solution to $(G,k)$.

#### NP-completeless proof

To show: Independent sets is NP-complete

* Independent Sets (IS) $\in$ NP 
  * Solution can be verified in polynomial time 
* $\forall A \in NP, A\rightarrow IS$ 
  * Reduction of A to Independent Sets

Suppose we know SAT is NP-complete, $\forall A\in NP, A\rightarrow \text{ SAT}$, if we show

$$
\begin{aligned}
\text{SAT} \rightarrow \text{IS} &\implies A \rightarrow {SAT} \rightarrow \text{IS}\\
&\implies A \rightarrow \text{IS}
\end{aligned}
$$

Instead, to show IS is NP-complete, we need:
* IS $\in$ NP
* SAT $\rightarrow$ IS

### NP2: 3SAT 

### NP3: Graph Problems

### NP4: Knapsack


<!-- {% include embed/youtube.html id='10oQMHadGos' %} -->