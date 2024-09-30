---
toc: true
mermaid: true
hidden: true
math: true
---


### Strongly Connected Components (GR1)

Here is a recap on DFS (for a undirected graph)

```
DFS(G):
  input G=(V,E) in adjacency list representation
  output: vertices labeled by connected components
  cc = 0
  for all v in V, visited(v) = False, prev(v) = NULL
  for all v in V:
    if not visited(v):
      cc++
      Explore(v)
```

Now lets define `Explore`:

```
Explore(z):
  ccnum(z) = cc
  visited(z) = True
  for all (z,w) in E:
    if not visited(w):
      Explore(w)
      prev(w) = z
```

The `ccnum` is the connected component number of $z$.

The overall running time is $O(n+m), n = \lvert V \lvert, m = \lvert M \lvert$. This is because you visit each node once, and, at each node, you try the edges, hence the total run time is total nodes and total edges in order to reach all nodes.


What if our graph is now directed? We can still use DFS, but add pre or postorder numbers and remove the counters.

Notice hte difference nad adding of the `clock` variable:

```
DFS(G):
  clock = 1
  for all v in V, visited(v) = False, prev(v) = NULL
  for all v in V:
    if not visited(v):
      cc++
      Explore(v)
```

Now lets define `Explore`:

```
Explore(z):
  pre(z) = clock;clock++
  visited(z) = True
  for all (z,w) in E:
    if not visited(w):
      Explore(w)
      prev(w) = z
  post(z) = clock; clock++
```

Here is an example:

{% graphviz %}
digraph { 
    bgcolor="lightyellow"
    rankdir=LR;
    node [shape = circle];
    A -> D
    B -> A
    B -> E
    B -> C
    C -> F
    D -> E
    D -> G
    D -> H
    E -> A
    E -> G
    F -> B
    F -> H
    H -> G
}
{% endgraphviz %}

Assuming we start at B, this is how our DFS looks like define as Node(pre,post):

Blue edge reflects that it is "used" during DFS but not used because the node has been visited.

{% graphviz %}
digraph { 
    bgcolor="lightyellow"
    rankdir=LR;
    node [shape = circle];
    A -> D [color = black, xlabel = "A(2,11)"]
    B -> A [color = black, xlabel = "B(1,16)"]
    B -> E [color = blue]
    B -> C [color = black, xlabel ="C(12,15)"]
    C -> F [color = black, xlabel ="F(13,14)"]
    D -> E [color = black, xlabel = "D(3,10)"]
    D -> G [color = blue]
    D -> H [color = black, xlabel="H(8,9)"]
    E -> A [color = blue]
    E -> G [color = black, xlabel = "E(4,7)"]
    F -> B [color = blue]
    F -> H [color = blue]
    H -> G [color = blue]
    G [xlabel="G(5,6)"]
}
{% endgraphviz %}

There are various type of edges, for a given edge $z \rightarrow w$:

* Treeedge such as $A\rightarrow B, B\rightarrow D$
  * where $post(z) > post(w)$, because of how you recurse back up during DFS
* Back edges $B \rightarrow A, F\rightarrow B$
  * $post(z) < post(w)$
  * Edges that goes back up.
* Forward edges $D \rightarrow G, B \rightarrow E$ 
  * Same as the tree edges
  * $post(z) > post(w)$
* Cross edges $F \rightarrow H, H \rightarrow G$
  * $post(z) > post(w)$

Notice that only for the back edges it is different in terms of the post order and behaves differently from the other edges.

**Cycles**

A graph $G$ has a cycle if and only if its DFS tree has a back edge. 

Proof:

Given $a \rightarrow b \rightarrow  c \rightarrow  ... \rightarrow  j \rightarrow  a$
which is a cycle. Suppose somewhere down the line we have this node $i$, then the sub tree (descendants) of $i$ must contain $i-1$ which contains a backedge to $i$.

For the other direction, it is obvious, Consider the back edge $B \rightarrow A$, then the cycle exists.

**Toplogical sorting**

Topologically sorting a DAG (directed acyclic graph that has no cycles): order vertices so that all edges go from lower $\rightarrow$ higher. Recall that since it has no cycles, it has no back edges. So the post order numbers must be $post(z) > post(w)$ for any edge $z \rightarrow w$. 

So, to do this, we can order vertices by decreasing post order number. Note that for this case, since we have $n$ vertices, we can create a array of size $2n$ and insert the nodes according to their post order number. So, our sorting of post order numbers runtime is $O(n)$.

{% graphviz %}
digraph { 
    bgcolor="lightyellow"
    rankdir=LR;
    node [shape = circle];
    X -> Y
    Y -> U
    Y -> W
    Y -> Z
    Z -> W
}
{% endgraphviz %}

What are the valid Topological order? : $XY(ZWU\lvert ZUW\lvert UZW)$

Note, for instance, XYUWZ is not a valid topological order! (Basically Z must come before W) - Because there's a directed edge from Z to W, Z must come before W in any valid topological ordering of this graph.

Analogy: Imagine you're assembling a toy. Piece Y is needed for both piece Z and piece W. But, piece Z is also needed for piece W.  You must attach Y to Z first, then Z to W.  Even though Y is needed for W, you don't attach it directly to W.

**DAG Structure**

* Source vertex: no incoming edges
  * Highest post order
* Sink vertex = no outgoing edges 
  * Lowest post order

By now, you are probably thinking, what does all this has to do with strongly connected component (SCC)? We will show that it is possible to do so with two DFS search.

**Connectivity in DAG**

Vertices $v$ & $w$ are **strongly connected** if there is a path $v \rightarrow  w$ and $w \rightarrow  v$

So, SCC defined as strongly connected component, is the maximal set of strongly connected vertices.

Example:

{% graphviz %}
digraph { 
    bgcolor="lightyellow"
    rankdir=LR;
    node [shape = circle];
    A -> B
    B -> C
    B -> D
    B -> E
    C -> F
    E -> L
    E -> B
    F -> G
    F -> I
    G -> F
    G -> C
    H -> I
    H -> J
    I -> J
    J -> H
    J -> K
    K -> L
    L -> I
}
{% endgraphviz %}

How many strongly connected components (SCC) does the graph has? `5`

* `A` is a SCC by itself since it can reach many other nodes but no other nodes can reach A
* `{H,I,J,K,L}` Can reach each other 
* `{C,F,G}`
* `{B,E}`
* `{D}`

We can simplify the above graph to the following meta graph:

{% graphviz %}
digraph { 
    bgcolor="lightyellow"
    rankdir=LR;
    node [shape = circle];
    A -> B
    B -> C
    B -> D
    B -> H
    C -> H
    B [label = "B,E"]
    C [label = "C,F,G"]
    H [label = "H,I,J,K,L"]
}
{% endgraphviz %}

Notice that this meta graph is a DAG and it is always the case. This should be obvious because if two strongly connected components are involved in a cycle, then they will be combined to form a bigger SCC.

So, **every directed graph is a DAG of it's strongly connected components**. You can take any graph, break it up into SCC and then topologically sort this SCC so that all edges go left to right.

**Motivation**

There are many ways we can do this, such as start with sinking vertices or source vertices. But, instead we can find the sink SCC, so, we find SCC S, output it, and remove it and repeat it. It turns out, Sinks SCC are easier to work with!

Recall we take any $v \in S$, where $S$   is the sick SCC. For example from the earlier graph we run `Explore(v)`, and we run explore from any of of the vertices in `{H,I,J,K,L}`, we will explore these vertices and not any other because it is a sink SCC. 

What if we find a vertex in the source component? You ended up exploring the whole graph, too bad! So, how can we be smart about this and find a vertex that lies in a sink component? Because if we can do so (somehow magically select a vertex in the sink SCC), then we are guaranteed to find all the nodes in the sink SCC.

**So, how can we find such a vertex?** 

Recall that in a DAG, the vertex with the **lowest postorder** number is a sink. 

In a directed directed G, can we use the same property? Does the property for a general graph, such that v with the lowest post order always lie in a sink SCC? HA of course its not true, do you think it will be that easy?


{% graphviz %}
digraph { 
    bgcolor="lightyellow"
    rankdir=LR;
    node [shape = circle];
    A -> B [label = "A(1,6)"]
    B -> A [label = "B(2,3)"]
    A -> C [label = "C(4,5)"]
}
{% endgraphviz %}

Notice that B has the lowest post order (3) but it belongs to the SCC `{A,B}`. 

What about the other way around? Does v with the highest post order always lie in a source SCC? Turns out, this is true! How can we make use of this? Simple, just reverse it! So the source SCC of the reverse graph is the sink SCC!

So, for directed $G=(V,E)$, look at $G^R = (V,E^R)$, so, the source SCC in $G$ = sink SCC in $G^R$. So, we just flip the graph, run DFS, take the highest post order which is the source SCC in $G^R$, that will be the sink in $G$.

#### SCC algorithm

```
SCC(G):
  input: directed G=(V,E) in adjacency list
  1. Construct G^R
  2. Run DFS on G^R
  3. Order V by decreasing post order number
  4. Run undirected connected components alg on G based on the post order number
```

Proof of claim:

Given two SCC $S$ and $S'$, and there is an edge $v \in S \rightarrow w \in S'$,
the claim is the max post number in $S$ is always greater than max post number of $S'$.

The first case is if we start from $z \in S'$, then, we finish exploring in $S'$ before moving to $S$, so post numbers in $S$ will be bigger.

The second case is if we start $z \in S$, then $z$ will be the root node since we can travel to $S'$ from $z$. Since $z$ is the root node, then it must have the highest post order number. 

#### BFS & Dijkstras 

DFS : connectivity 

BFS: 

input: $G=(V,E)$ & $s \in V$

output: for all $v \in V$, dist(v) = min number of edges from $s$ to $v$ and $prev(v)$.

Dijkstra's:

input: $G=(V,E)$ & $s \in V$, $\ell(e) > 0 \forall e \in E$

output: $\forall v \in V$, dist(v) = length of shortest $s\rightarrow v$ path.

Note, Dijkstra uses the min-heap (known as priority queue) that takes $logn$ insertion run time. So, the overall runtime for Dijkstra is $O((n+m)logn)$.









<!-- {% include embed/youtube.html id='10oQMHadGos' %} -->