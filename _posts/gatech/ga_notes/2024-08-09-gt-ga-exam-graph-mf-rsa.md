---
title: CS6515 OMSCS - Graduate Algorithms Graphs Maxflow RSA Prep
date: 2024-10-15 0000:00:00 +0800
categories: [Courses, Gatech, Notes]
tags: [courses, omscs, gatech_notes]     # TAG names should always be lowercase
math: true
toc: true
mermaid: true
---

# Graphs 

## Graph Operations

| Operation                                                                                      | Time complexity  |
| :--------------------------------------------------------------------------------------------- | :--------------- |
| Traversing, reversing, copying, subgraph or working on full graph                              | $O(n+m)$         |
| Iterating, checking, reading, removing, <br> or otherwise working on all edges (or subset):         | $O(n+m)$         |
| Checking, reading, or removing one vertex:                                                     | $O(1)$           |
| Checking, reading, or removing one edge:                                                       | $O(n)$ or $O(m)$ |
| Iterating, checking, reading, removing, <br> or otherwise working on all vertices (or subset): | $O(n)$           |

Special call out:

* When the graph is connected, meaning $m \geq n-1$, $O(n+m)$ can be simplified to $O(m)$
* Similarly in a cases where the graph could be fully connected (such as Kruskal), $m \leq \frac{n(n-1)}{2} \leq n^2$. So in these cases $log m = log n^2 = 2 log n = log n$

## Graph terminologies

For the following `directed` graph:

{% graphviz %}
digraph { 
    bgcolor="lightyellow"
    rankdir=LR;
    node [shape = circle];
    A -> B
    A -> C
    B -> C
}
{% endgraphviz %}

* `A` is adjacent to `B,C`
* `B,C` are neighbors of `A`
* `A` is the parent of `B,C`

## Tree edges

* Tree edges are actually part of the DFS forest.
* Forward edges lead from a node to a nonchild descendant in the DFS tree.
* Back edges lead to an ancestor in the DFS tree.
* Cross edges lead to neither descendant nor ancestor; they therefore lead to a node that has already been completely explored (that is, already postvisited).

![image](../../../assets/posts/gatech/ga/exam2_dfs_edge_type.png){: width='200'}

Here is another summary:

![image](../../../assets/posts/gatech/ga/exam2_dfs_edge_summary.png){: width='300'}

## Graphs Algorithms Overview

* DFS which outputs connected components, topological sort on a DAG. You also have access to the prev, pre and post arrays.
* BFS on unweighted graphs to find the shortest distance from a source vertex to all other vertices and a path can be recovered backtracking over the prev labels
* Dijkstra’s algorithm on weighted graphs to find the shortest distance from a source vertex to all other vertices and a path can be recovered backtracking over the prev labels
* Bellman-Ford and Floyd-Warshall to compute the shortest path when weights are allowed to be negative
* SCC which outputs the strongly connected components, and the metagraph of strongly connected components.
* Kruskal’s and Prim’s algorithms to find an MST
* Ford-Fulkerson and Edmonds-Karp to find the max flow on networks.
* 2-SAT which takes a CNF with all clauses of size $\leq$ 2 and returns a satisfying assignment if it exists

## DFS

DFS is an algorithm for traversing or searching tree or graph data structures. It starts at the root or an arbitrary node of a graph and explores as far as possible along each branch before backtracking.

`input`:
* $G=(V,E)$

`output`:
* Pre, Post, Prev, Visited
* ccnum (vertex being assigned to a connected component)
  * Becareful when using this on **directed graphs** because you cannot choose which vertex to start from.
* In the case of a DAG (no cycles)
  * Topological order / sorting

`runtme`:

* $O(n+m)$

`More information`: None for now!

## BFS

BFS is an algorithm for traversing or searching tree or graph data structures. It starts at the tree root (or some arbitrary node of a graph) and explores the neighbor nodes at the present depth before moving on to nodes at the next depth level.

`input`:

* $G=(V,E)$
  * Start vertex $v \in V$

`output`:

* dist[]
  * For all vertices u reachable from the starting vertex v, dist[u] is the shortest path distance from v to u. If no such path exists, infinity otherwise.
* prev[]
  * Vertex preceding u in the shortest path from v to reachable vertex u. 

`runtime`:
* $O(n+m)$

`More information`:

if you only want connectivity from a specific vertex, use BFS instead.

## Dijkstra 

Dijkstra's algorithm is used to find the shortest distance from a source vertex to all other vertices. A path can be recovered by backtracking over all of the pre-labels.

`input`:
* $G=(V,E)$, G must be **directed**
* start vertex $s \in V$

`output`:

* dist[]
  * Shortest distance between vertex v and reachable vertex u or infinity otherwise if not reachable.
* prev[]
  * Vertex preceding u in the shortest path from v to reachable vertex u


`runtime`:
* $O((m+n)log n)$
* $O(mlogn)$ if graph is **strongly connected** so $m \geq n-1$

`More information`:
* Uses a binary min heap
* Edges **must not be negative**

## Bellman-Ford 

Bellman-Ford is used to derive the shortest path from s to all vertices in V. It does not find a path between all pairs of vertices in V. To do this, we would have to run BF $\lvert V \lvert$ times. Negative weights are allowed.

`input`:
* $G=(V,E)$, G must be **directed**
* start vertex $s \in V$

`output`:
* The shortest path from vertex s to all other vertices.


`runtime`:
* $O(mn)$

Initially, you might think that there the complexity is $O(m^2n)$ because of the 3 nested for loops. But, in the 2nd and 3rd nested for loop, it is actually going through all edges (If you go through all nodes and all the edges within each node, it is actually going through all the edges). So the time complexity is actually $O(mn)$.

`More information`:

**How to find negative cycle?**

Now, how can you use bellman ford to detect if there is a negative cycle? Notice that the algorithm runs until n-1. Run it for one more time, and compare the difference. If the solution is different, then, some negative weights must exists.

In other words, check for:

$$
D(n,z) < D(n-1,z), \exists z \in V
$$


## Floyd-Warshall

FW is primarily used to find the shortest path from ALL nodes to all other nodes where negative weights are allowed.


`input`:
* $G=(V,E)$, G must be **directed**

`output`:
* The shortest path from all vertices to all other vertices
* `T[i,s,t]` is for the first $i$ vertices, the distance from $s \rightarrow t$.
* Final output is `T[n, s,t]`

`runtime`:
* $O(n^3)$

`More information`:

**Checking negative cycles**

To detect negative weight cycles, can check the diagonal of the matrix D. 
* If there is a negative cycle, then there should be a negative path length from a vertex to itself, i.e $T(n,y,y) < 0, \exists y \in V $. 
  * This is equivalent to checking whether there is any negative entries on the diagonal matrix $T(n,:,:)$.

## SCC 

The SCC algorithm is used to determine the strongly connected components as well as the meta-graph of connected components in a given directed graph.

`input`:
* $G=(V,E)$, G must be **directed**

`output`:
* meta-graph (DAG) that contains the connected components
* Reverse Topological sorting of the meta-graph
  * So the sink SCC will have order 1 while source SCC will have $n$ as its entries. (multiple sink and/or source SCC is possible)
* ccnum[] - strongly connected components produced from the 2nd DFS run


`runtime`:
* $O(m+n)$

`More information`:

SCC algorithm:

```
SCC(G):
  input: directed G=(V,E) in adjacency list
  1. Construct G^R
  2. Run DFS on G^R
  3. Order V by decreasing post order number
  4. Run undirected connected components alg on G based on the post order number
```

*Why do we compute the reverse graph G?*

What about the other way around? Does v with the highest post order always lie in a source SCC? Turns out, this is true! How can we make use of this? Simple, just reverse it! So the source SCC of the reverse graph is the sink SCC!

## 2-SAT

The 2-SAT problem is to determine whether there exists an assignment to variables of a given Boolean formula in 2-CNF (conjunctive normal form) such that the formula evaluates to true. The algorithm for solving 2-SAT uses graph theory by constructing an implication graph and then checking for the existence of a path that satisfies the conditions.

`input`:

* A Boolean formula in 2-CNF is represented as a set of clauses where each clause is a disjunction of exactly two literals.

`output`:

* A Boolean value indicates whether the given 2-CNF formula is satisfiable. If it is satisfiable, the algorithm may also provide a satisfying assignment of variables.


`runtime`:

* O(m + n) - m is the number of clauses in the 2-CNF formula, n is the number of literal or variables.
  * This runtime stems from the linear runtime of SCC finding algorithms and the construction of the implication graph.

`More information`:

2-SAT algorithm

```
2SAT(F):
  1. Construct graph G for f
  2. Take a sink SCC S 
    - Set S = T ( and bar(S) = F)
    - remove S, bar(S)
    - repeat until empty
```

In general:

* If for some $i$, $x_i, \bar{x_i}$ are in the same SCC, then $f$ is not satisfiable. 
* If for some $i$, $x_i, \bar{x_i}$ are in different SCC, then $f$ is satisfiable. 

Graphs that can use 2-SAT:

Directed graphs

The implication graph is inherently directed since each implication (¬x → y) has a direction.


### Krusal (MST)

Kruskal's is one of the two algorithms used to find the Minimum Spanning Tree (MST) discussed in class.


`input`:
* Connected, Undirected Graph G = (V, E) with edge weights $w_e$

`output`:
* An MST defined by the edges E

`runtime`:

* $O(m log n)$

`More information`:

```
Kruskals(G):
  input: undirected G = (V,E) with weights w(e)
  1. Sort E by increasing weight
  2. Set X = {null}
  3. For e=(v,w) in E (in increasing order)
    if X U e does not have a cycle:
      X = X U e (U here denotes union)
  4. Return X
```

### Prim (MST)

Prim's algorithm is the second and final algorithm used to find the MSTs as discussed in class.


`input`:
* Connected, Undirected Graph G = (V, E) with edge weights $w_e$


`output`:
* An MST defined by the prev[] array


`runtime`:

* O(m log n) if graph is connected
  * This is because if the graph is connected then $m \geq n-1$
* O((m + n) log n) if graph is not connected

`More information`:

MST algorithm is akin tio Dijkstra's algorithm, and use the cut property to prove correctness of Prim's algorithm.

The prim's algorithm selects the root vertex in the beginning and then traverses from vertex to vertex adjacently. On the other hand, Krushal's algorithm helps in generating the minimum spanning tree, initiating from the smallest weighted edge.


### Cut property 

The **cut property** exists if (and only if) an edge is of minimum weight on any cut, then the edge is part of some MST.
* Used to include edges
* if all edge weights are unique, then the **cut property** assets if (and only if) an edge is the minimum across any cut, then the edge is part of every MST. 

### Cycle property 

The **cycle property** states if $e$ is the unique heaviest edge in any cycle of G, then $e$ cannot be part of any MST
* Used to exclude edges 

# Maxflow

## Ford-Fulkerson 

A greedy algorithm to find max flow on networks. The algorithm continually sends flow along paths from the source (starting node) to the sink (end node), provided there is available capacity on all edges involved. This flow continues until no further augmenting paths with available capacity are detected.

`input`:

`output`:

`runtime`:

`More information`:

## Edmonds-Karp

`input`:

`output`:

`runtime`:

`More information`:

## Max-flow Min Cut

## Max-flow Generalization

# RA

## Modular arithmetic

## Modular Exponentiation

## Multiplicative Inverse

### Existence 

## Euclid 

### Euclid GCD 

### Euclid Extended 

# RSA 

## Fermat's little theorem

## Euler's theorem

### Euler's totient function 

## Fermat tests 

## Fermat Witnesses

## Primality test

## Carmichael

## Breaking RSA


<!-- {% include embed/youtube.html id='10oQMHadGos' %} -->