//: Playground - noun: a place where people can play

import Cocoa

enum BTreeError : ErrorType {
    case BadOrder
    case NumberOfKeys
    case MinimumKeys
    case MaximumKeys
    case MinimumChildNodes
    case MaximumChildNodes
}

typealias Key = Comparable

protocol BTreeRootNodeish {

}

class BTreeNode<Key> {
    let bTree: BTree<Key>
    var keys: [Key]

    required init(bTree: BTree<Key>, keys: [Key]) {
        self.bTree = bTree
        self.keys = keys
    }
}

class BTreeLeafNode<Key> : BTreeNode<Key> {

    required init(parent: BTreeNode<Key>, keys: [Key]) throws {
        let maxKeys = bTree.order - 1
        guard keys.count >= maxKeys / 2 else {
            throw BTreeError.MinimumKeys
        }
        guard keys.count <= maxKeys else {
            throw BTreeError.MaximumKeys
        }

        super.init(bTree: parent.bTree, keys: keys)
        self.parent = parent
        self.keys = keys
    }
}

class BTreeInternalNode<Key> : BTreeLeafNode<Key> {
    var childNodes: [BTreeNode]?

    required init(parent: BTreeNode<Key>, keys: [Key], childNodes: [BTreeNode<Key>]) throws {
        guard keys.count == childNodes.count - 1 else {
            throw BTreeError.MinimumChildNodes
        }
        guard childNodes.count >= bTree.order / 2 else {
            throw BTreeError.MinimumChildNodes
        }
        guard childNodes.count <= bTree.order else {
            throw BTreeError.MaximumChildNodes
        }

        super.init(bTree: parent.bTree)
        self.parent = parent
        self.keys = keys
        self.childNodes = childNodes
    }
}

class BTreeRootNode<Key> : BTreeNode<Key> {
}

class BTree<Key> {
    let order: Int
    let root: BTreeNode<Key>

    init(order: Int) throws {
        guard order > 2 else {
            throw BTreeError.BadOrder
        }
        self.order = order
        self.root = BTreeNode(bTree: self, keys: [Key]())
    }
}


