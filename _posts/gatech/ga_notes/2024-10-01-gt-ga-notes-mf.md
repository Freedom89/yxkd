---
toc: true
mermaid: true
hidden: true
math: true
---


### Ford-Fulkerson (MF1)

**Problem formulation**:

* Input: Directed graph $G=(V,E)$ designated $s,t \in V$ for each $e \in E$, capacity $c_e >0$
* Goal: Maximize flow $s \rightarrow t$, $f_e$ = flows along $e$ subjected to the following:
  * Capacity constraints: * $\forall e \in E, 0\leq f_e \leq c_e$
  * Conversation of flow: $\forall v \in V - \{S \cup T\}$, flow-in to $v$ = flow-out of $v$
  * $\sum_{\overrightarrow{wv} \in E} f_{wv} = \sum_{\overleftarrow{vz} \in E} f_{vz}$

Other details:

* For the max flow problems, the cycles are ok! 
* Anti parallel edges:

  ![image](../../../assets/posts/gatech/ga/mf1_mf1_anti.png){: width='400'}
* Notice the edge between $a\leftrightarrow b$, you want to break this anti parallel edges (Because of the residual network that we will see later)

**Residual Network**

Consider the following network, we initially run a path $s \rightarrow a \rightarrow b \rightarrow t$

![image](../../../assets/posts/gatech/ga/mf1_mf1_resid0.png){: width='400'}

But, it turns out that there is still capacity of $7$ left, what can we do? We build a backward edge with weights from the previous path, as shown with the red arrow below.

![image](../../../assets/posts/gatech/ga/mf1_mf1_resid.png){: width='400'}

Now, we can pass on a flow of $7$ and the max flow is $17$.

In general, the residual network $G^f = (V,E^f)$, for flow network $G=(V,E)$ with $c_e : e \in E$, and flow $f_e : e \in E$, 
* if $\overrightarrow{vw} \in E\ \&\ f_{vw} < c_{vw}$, then add $\overrightarrow{vw}$ to $G^f$ with capacity $c_{vw} - f_{vw}$ (remaining available)
* if $\overrightarrow{vw} \in E\ \&\ f_{vw} > 0$, then add $\overrightarrow{wv}$ to $G^f$ with capacity $f_{vw}$

In other words, if you flow is below capacity provided, add another edge in parallel with edge weight as the flow. If your flow is greater than 0 (and all capacity is used), add a backward edge with the capacity flow. Also, because we remove the parallel edges, we are allowed to add the forward edge and backward edge without inequalities. 

#### Ford-Fulkerson Algorithm

* Set $f_e = 0$ for all $ e \in E$
* Build the residual network $G^f$ for the current flow $f$
  * Initially it will all be zero
* Check for a path $s\rightarrow t$ in $G^f$ using DFS/BFS
  * If there is no such path, then output $f$.
  * If there is a path, denote it a $\mathcal{P}$
* Given $\mathcal{P}$, let $c(\mathcal{P})$ denote the minimum capacity along $\mathcal{P}$ in $G^f$
* Augment $f$ by $c(\mathcal{P})$ units along $\mathcal{P}$
  * For every forward edge, we increase the flow along that edge by this amount
  * For the backward edge, we decrease the flow in the other direction
* Repeat from the build residual network step (until you return output $f$)

The proof is based on max-flow = min-cut theorem, which will be covered in MF2.

For Time complexity, we assume all capacities are integers (Edmonds-Karp algorithm eliminates this assumptions). This assumption implies that whenever we augment hte flow, we augment by an integer amount. 
* This implies that the flow increases by $\geq 1$ unit per round 
* Let $C$ denote the size of max flow, then we have at most $C$ rounds.
* Since the graph is connected, $\mathcal{P}$ is $n-1$ edges, so to update the residual network takes $O(n)$
* To check for the path $\mathcal{P}$, either with BFS or DFS, takes $O(n+m)$, since the graph is connected, it reduces to $O(m)$. 
* Augment $f$ by $c(\mathcal{P})$ also takes $O(n)$
* So overall the complexity of each round is $O(m)$, over $C$ rounds, hence the total runtime is $O(Cm)$.

#### Other Algorithms

For Ford-Fulkerson
* the running time depends on the integer $C$, if you recall from knapsack, the running time is a pseudo-polynomial.
* We use BFS/DFS to find any path from $s\rightarrow t$

For Edmonds-karp
* Algorithm takes $O(m^2 n)$ time
* We take the shortest path from $s \rightarrow t$, in this case shortest means the number of edges and do not care about the weights on the edges. To find such a path, we run BFS. The number of rounds in this case is going to be $O(mn)$, and each round takes $O(m)$ time, the total is $O(m^2n)$.
  * So the runtime is independent of the max flow and no longer require it to be integer values 

Orlin
* $O(mn)$, generally the best for general graphs for the exact solution of the max-flow problem.

### Max-Flow Min-Cut (MF2)

Recall that the Ford-Fulkerson algorithm stop when there is no more augmenting path in residual $G^{f*}$. (star here means the max flow, i.e optimal solution)

Lemma: For a flow $f^*$ if there is no augmenting path in $G^{f*}$ then $f^*$ is a max-flow.

**Min-cut Problem**

Recall that a cut is a partition of vertices $V$ into two sets, $V = L \cup R$. Define st-cut to be a cut where $s\in L, t\in R$

Notice that a cut does not need to be connected, F is not connected to A and B in this subset. We are interested in the capacity of this st-cut. 

![image](../../../assets/posts/gatech/ga/mf2_mf2_cut.png){: width='400'}

Define capacity from $L\rightarrow R$

$$
Capacity(L,R) = \sum_{\overrightarrow{vw} \in E: v \in L, w \in R} c_{vw}
$$

Notice edges such as $C \rightarrow F$ do not count.

So the problem formulation of the min st-cut problem is as follows:

* Input: flow network
* Output: st-cut (L,R) with minimum capacity.

![image](../../../assets/posts/gatech/ga/mf2_mf2_cut1.png){: width='400'}

For example consider this cut, the capacity is $8+2+2+3+7+5 = 27$ 

The cut with minimum capacity is as follows

![image](../../../assets/posts/gatech/ga/mf2_mf2_cut2.png){: width='400'}

The min st-cut is 12, which i is equal to the max-flow 12. $L$ contains everybody but $t$. So the theorem we want to prove is the size of hte max flow equals to the size of the min st-cut.

#### Theorem

Note, in the max-flow problem, it is always from s to t, but on the other side it is called the st-cut problem because we want the cut to separate s and t. There could be a minimum cut such that s,t belongs to the same set. 

To proof this, we show that max-flow $\leq$ min st-cut, and vice versa. This will show that max-flow == st-cut.

#### LHS

To show max-flow $\leq$ min st-cut, show that for any flow $f$ and any st-cut $(L,R)$:

$$
size(f) \leq capacity (L,R)
$$

Note - this is for any flow, which includes the max over f, and the minimum over the capacity. 

Claim: $size(f) = f^{out}(L) - f^{in}(L)$

$$
\begin{aligned}
& f^{out}(L) - f^{in}(L) \\
 &= \sum_{\overrightarrow{vw} \in E: v \in L, w \in R} f_{vw} - \sum_{\overrightarrow{wv} \in E: v \in L, w \in R} f_{wv} \\
&= \sum_{\overrightarrow{vw} \in E: v \in L, w \in R} f_{vw} - \sum_{\overrightarrow{wv} \in E: v \in L, w \in R} f_{wv} + \sum_{\overrightarrow{vw} \in E: v \in L, w \in L} f_{vw} - \sum_{\overrightarrow{wv} \in E: v \in L, w \in L} f_{wv} 
\end{aligned}
$$

Notice that the first term and the third term, when combined, you get all edges out of v, and likewise all edges into c, and we filter out the vertex $s$. Notice that the source vertex has no input.

$$
\begin{aligned}
& f^{out}(L) - f^{in}(L) \\
& = \sum_{v\in L} f^{out}(v) - \sum_{v\in L} f^{in}(v) \\
& = \sum_{v\in L-S} (\underbrace{f^{out}(v)-f^{in}(v)}_{0}) + f^{out}(s) + \underbrace{f^{in}(s)}_{0}\\
&= size(f)
\end{aligned}
$$

So, the total flow out of $f$, is the size of $f$!. Coming back, we have:

$$
size(f) = f^{out}(L) - f^{in}(L) \leq f^{out}(L) \leq capacity(L,R)
$$

The last part is true, because the total flow out of L, must be the capacity out of L to R. 

#### RHS

Now, we prove the reverse inequality:

$$
max_f size(f) \geq  min_{(L,R)} capacity(L,R)
$$

Take flow $f^\*$ from Ford-Fulkerson algorithm, and $f^\*$ has no st-path in residual $G^{f\*}$. We will construct $(L,R)$ where:

$$
size(f^*) = cap(L,R)
$$

Similarly, this is for any size and any capacity, we can set the left to be the max, and right to be the min:

$$
max_f size(f) \geq size(f^*) = cap(L,R) \geq min_{(L,R)} capacity(L,R)
$$

Take flow $f^\*$ with no st-path in residual $G^{f\*}$. Let $L$ be the vertices reachable from $s$ in $G^{f\*}$. We know that $t \notin L$ because there is no such path that exists. So, let $R = V-L$. This also implies that $t \in R$.

For $\overrightarrow{vw} \in E, v\in L, w \in R$, this edge does not appear in the residual network (Because there is no path from L to R). This means that the edge must be fully capacitated $f_{vw}^* = c_{vw}$, and therefore the forward edge does not appear in the residual network so the flow along this edge equals to its capacity. Now since every edge from L to R is fully capacitated, the total flow out of $L$ must be equal to capacity$(L,R)$. This shows that $f^{*out}(L) = capacity(L,R)$.

Consider the opposite, consider edges $\overrightarrow{zy}, z \in R, y \in L$, which is edges that are going from R into L. The flow $f^\*_{zy} = 0$ because the reverse edge does not appear in the residual network. Because if there is an edge $\overrightarrow{zy}$, then it would be reachable from $L$, then it would be included in the set $L$. Since the back edge does not appear in the residual network, then the forward edge has to have flow zero. This shows that $f^{\*in}(L) = 0$.

Combining this two, shows:

$$
size(f^*) = f^{*out}(L) - f^{*in}(L) = capacity(L,R)
$$

We have shown both sides of the inequality, which concludes that max-flow == min st-cut. We have also shown that for any flow that has no augmenting path in the residual network, we can construct a st-cut where the size of the flow equals to the capacity of the s-t cut $size(f^*) = cap(L,R)$. The only way to have equality here is if both of these are optimal, which is max flow and min st-cut to have the minimum capacity. 

Note, this theorem also gives us another way of finding the min cut. We basically find the max flow, and set L to be all vertices reachable from s in the residual $G^{f*}$. 


<!-- {% include embed/youtube.html id='10oQMHadGos' %} -->