# B Tree

*Under Construction.*

A B-tree is a self-balancing tree data structure that keeps data sorted and allows searches, sequential access, insertions, and deletions in logarithmic time. The B-tree is a generalization of a binary search tree in that a node can have more than two children. 

Unlike self-balancing binary search trees, the B-tree is optimized for systems that read and write large blocks of data. B-trees are a good example of a data structure for external memory. It is commonly used in databases and filesystems. 

Multiple definitions for B-trees exist. Here we follow Knuth's definition as explained below.

##Explanation

![](Images/B-tree.svg)
*B-tree of order 5*

In short a B-tree exists of three types of nodes:

- the root node on top of the B-tree
- leaf nodes on the bottom of the B-tree
- internal nodes in between; an internal node always has a parent node and multiple child nodes

Please reason for yourself:

- if the B-tree has only one level, then the root node is also a leaf node
- the B-tree in the image above has *no* internal nodes.

According to Knuth's definition, a B-tree of *order m* is a tree which satisfies the following properties:

- Every internal node has a number of child nodes that is within *m / 2* and *m*
- The root has at least two child nodes if it is not a leaf node itself
- A non-leaf node with *k* child nodes contains *k − 1* keys
- All leave nodes appear in the same (bottom) level
- Key values are unique within the B-tree

Each of the key values of a non-leaf node act as separation values which divide its subtrees. E.g. when an internal node has 3 child nodes then it must have 2 keys: a1 and a2. All values in the leftmost subtree will be less than a1, all values in the middle subtree will be between a1 and a2 and all values in the rightmost subtree will be greater than a2.

###Internal nodes

Internal nodes are all nodes except for leaf nodes and the root node. They are usually represented as an ordered set of elements and child pointers. Every internal node contains a maximum of *m* child nodes  and a minimum of *m / 2* children. Thus the number of elements is always 1 fewer than the number of child node pointers. 

The number of keys is between *m / 2 - 1* and *m - 1*.  Thus each internal node is at least half full. This implies that two half-full nodes can be joined to make one full node. Vice versa one full node can be split into two half full nodes. These properties make it possible to delete and insert new values into a B-tree and adjust the tree to preserve the B-tree properties.

###The root node

The root node’s number of child nodes has the same upper limit as internal nodes but has no lower limit. E.g. when there are fewer than *m* keys in the entire B-tree then the root will be the only node in the tree with no children at all.

###Leaf nodes
Leaf nodes have the same restriction on the number of keys and they have no child nodes.

###Implementation
	struct node<T> {
		keys: [T]
		subtrees: [node]?
	}
	
	struct BTree<T> {
		order: Int // greater than 2
		root: node<T>
	}

##Speed
B-tree searches are of **O(m log n)** where *m* is the order of the B-tree and *n* is the number of keys stored. 

In reality B-trees are stored on disks and the B-tree order is determined based on key length and disk properties. That adds to the efficiency of the search algorithm. This subject carries behind the scope of this article though.



Because a range of child nodes is permitted, B-trees do not need re-balancing as frequently as other self-balancing search trees, but may waste some space, since nodes are not entirely full. The lower and upper bounds on the number of child nodes are typically fixed for a particular implementation. For example, in a 2-3 B-tree (often simply referred to as a 2-3 tree), each internal node may have only 2 or 3 child nodes.

Each internal node of a B-tree will contain a number of keys. The keys act as separation values which divide its subtrees. E.g if an internal node has 3 child nodes (or subtrees) then it must have 2 keys: a1 and a2. All values in the leftmost subtree will be less than a1, all values in the middle subtree will be between a1 and a2, and all values in the rightmost subtree will be greater than a2.



Usually, the number of keys is chosen to vary between d and 2d, where d is the minimum number of keys, and d+1 is the minimum degree or branching factor of the tree. In practice, the keys take up the most space in a node. The factor of 2 will guarantee that nodes can be split or combined. If an internal node has 2d keys, then adding a key to that node can be accomplished by splitting the 2d key node into two d key nodes and adding the key to the parent node. Each split node has the required minimum number of keys. Similarly, if an internal node and its neighbor each have d keys, then a key may be deleted from the internal node by combining with its neighbor. Deleting the key would make the internal node have d-1 keys; joining the neighbor would add d keys plus one more key brought down from the neighbor's parent. The result is an entirely full node of 2d keys.

The number of branches (or child nodes) from a node will be one more than the number of keys stored in the node. In a 2-3 B-tree, the internal nodes will store either one key (with two child nodes) or two keys (with three child nodes). A B-tree is sometimes described with the parameters (d+1) — (2d+1) or simply with the highest branching order, (2d+1).

A B-tree is kept balanced by requiring that all leaf nodes be at the same depth. This depth will increase slowly as elements are added to the tree, but an increase in the overall depth is infrequent, and results in all leaf nodes being one more node farther away from the root.

B-trees have substantial advantages over alternative implementations when the time to access the data of a node greatly exceeds the time spent processing that data, because then the cost of accessing the node may be amortized over multiple operations within the node. This usually occurs when the node data are in secondary storage such as disk drives. By maximizing the number of keys within each internal node, the height of the tree decreases and the number of expensive node accesses is reduced. In addition, rebalancing of the tree occurs less often. The maximum number of child nodes depends on the information that must be stored for each child node and the size of a full disk block or an analogous size in secondary storage. While 2-3 B-trees are easier to explain, practical B-trees using secondary storage need a large number of child nodes to improve performance.

***Variants***

The term B-tree may refer to a specific design or it may refer to a general class of designs. In the narrow sense, a B-tree stores keys in its internal nodes but need not store those keys in the records at the leaves. The general class includes variations such as the B+ tree and the B* tree.

    In the B+ tree, copies of the keys are stored in the internal nodes; the keys and records are stored in leaves; in addition, a leaf node may include a pointer to the next leaf node to speed sequential access (Comer 1979, p. 129).
    The B* tree balances more neighboring internal nodes to keep the internal nodes more densely packed (Comer 1979, p. 129). This variant requires non-root nodes to be at least 2/3 full instead of 1/2 (Knuth 1998, p. 488). To maintain this, instead of immediately splitting up a node when it gets full, its keys are shared with a node next to it. When both nodes are full, then the two nodes are split into three. Deleting nodes is somewhat more complex than inserting however.
    B-trees can be turned into order statistic trees to allow rapid searches for the Nth record in key order, or counting the number of records between any two records, and various other related operations.[1]


See also [Wikipedia](https://en.wikipedia.org/wiki/B-tree).

*Written by Jeroen Houtzager*

