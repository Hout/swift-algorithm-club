//
//  main.swift
//  B Tree
//
//  Created by Jeroen Houtzager on 19/03/16.
//  Copyright © 2016 Jeroen Houtzager. All rights reserved.
//

import Foundation

enum BTreeError : ErrorType {
    case BadOrder
    case NumberOfKeys
    case MinimumKeys
    case MaximumKeys
    case MinimumChildNodes
    case MaximumChildNodes
}

public class BTree<KeyType: Comparable> : CustomStringConvertible {
    var root: BTreeNode<KeyType>?
    let order: Int
    
    required public init?(order: Int) throws {
        self.order = order
        
        guard order >= 2 else {
            throw BTreeError.BadOrder
        }
        
        self.root = BTreeNode<KeyType>(bTree: self)
    }
    
    public func addKey(key: KeyType) {
        let insertLeaf = root!.searchLeaf(key)
        insertLeaf.addKey(key)
    }
    
    public func deleteKey(key: KeyType) {
        root!.deleteKey(key)
    }
    
    public func averageKeysPerNode() -> Float {
        return Float(root!.numberOfKeys()) / Float(root!.numberOfNodes())
    }
    
    public func height() -> Int {
        return root!.height()
    }
    
    public var description: String {
        return "(\(order)/\(averageKeysPerNode())) \(root!.description)"
    }
}

public class BTreeNode<KeyType: Comparable> : CustomStringConvertible {
    let bTree: BTree<KeyType>
    var parent: BTreeNode? // No parent for the root node
    var keys: [KeyType]
    var childNodes: [BTreeNode<KeyType>] // Empty child nodes for leaf nodes
    
    internal init(bTree: BTree<KeyType>) {
        self.bTree = bTree
        self.keys = [KeyType]()
        self.childNodes = [BTreeNode<KeyType>]()
        
        if bTree.root == nil {
            bTree.root = self
        }
    }
    
    public func height() -> Int {
        if childNodes.count == 0 {
            return 1
        }
        return childNodes[0].height() + 1
    }
    
    internal func numberOfKeys() -> Int {
        return childNodes.reduce(keys.count, combine: { $0 + $1.numberOfKeys() })
    }
    
    internal func numberOfNodes() -> Int {
        return childNodes.reduce(1, combine: { $0 + $1.numberOfNodes() })
    }
    
    func isInternal() -> Bool {
        return !isRoot() && !isLeaf()
    }
    
    func isRoot() -> Bool {
        return parent == nil
    }
    
    func isLeaf() -> Bool {
        return childNodes.count == 0
    }
    
    func indexOfKey(key: KeyType) -> Int? {
        for index in keys.indices {
            if keys[index] == key {
                return index
            }
        }
        return nil
    }
    
    func rightIndexOfKey(key: KeyType) -> Int {
        for index in keys.indices {
            if keys[index] > key {
                return index
            }
        }
        return keys.count
    }
    
    func searchLeaf(key: KeyType) -> BTreeNode {
        if isLeaf() {
            return self
        }
        
        // No leaf
        let index = rightIndexOfKey(key)
        return childNodes[index].searchLeaf(key)
    }
    
    internal func addKey(key: KeyType, rightChildNode: BTreeNode<KeyType>? = nil) {
        let insertIndex = rightIndexOfKey(key)
        keys.insert(key, atIndex: insertIndex)
        if let node = rightChildNode {
            assert(!isLeaf())
            childNodes.insert(node, atIndex: insertIndex + 1)
        }
        
        // check if node is at max
        let maxKeys = bTree.order - 1
        if keys.count > maxKeys {
            // node at max, split up
            
            let medianIndex = (bTree.order - 1) / 2
            let medianKey = keys[medianIndex]
            
            // if root, create a new root above the current one
            if isRoot() {
                let newRoot = BTreeNode(bTree: bTree)
                newRoot.childNodes.append(self)
                parent = newRoot
                bTree.root = newRoot
            }
            
            // now create a new node and split the current one up
            let newNode = BTreeNode<KeyType>(bTree: bTree)
            newNode.parent = parent
            
            // keys to the right of the median key will transfer to the new node
            newNode.keys = Array(keys[medianIndex + 1...keys.count - 1])
            keys.removeRange(medianIndex...keys.count - 1) // remove median key too as it is promoted to the parent
            
            // if no leaf, child nodes to the right of the median key transfer to new node too
            if !isLeaf() {
                newNode.childNodes = Array(childNodes[medianIndex + 1...childNodes.count - 1])
                childNodes.removeRange(medianIndex + 1...childNodes.count - 1)
            }
            
            // median key goes to the parent with the new node on the right hand side
            parent!.addKey(medianKey, rightChildNode: newNode)
        }
        
        assert(childNodes.count <= bTree.order)
        assert(keys.count < bTree.order)
        if !isLeaf() {
            assert(keys.count == childNodes.count - 1)
            if isRoot() {
                assert(childNodes.count >= 2)
            }
        }
        if isInternal() {
            assert(childNodes.count >= bTree.order / 2)
        }
    }
    
    func searchNode(key: KeyType) -> (node: BTreeNode<KeyType>, index: Int)? {
        for index in keys.indices {
            if keys[index] == key { return (node: self, index: index) }
            if isLeaf() { return nil }
            if keys[index] > key {
                return childNodes[index].searchNode(key)
            }
        }
        return childNodes[keys.count].searchNode(key)
    }
    
    internal func parentIndex(node: BTreeNode<KeyType>) -> Int? {
        guard parent != nil else {
            return nil
        }
        for index in parent!.childNodes.indices {
            let childNode = parent!.childNodes[index]
            if childNode === node {
                return index
            }
        }
        return nil
        
        //        Did not work:
        //        return try! parent?.childNodes.indexOf(node)
    }
    
    internal func rebalanceFromNode(node: BTreeNode<KeyType>) {
        if keys.count < bTree.order / 2 {
            // imbalanced
            if let index = parentIndex(node) {
                if index > 0 {
                    // step 1: check sibling to the left
                    let leftSibling = parent!.childNodes[index - 1]
                    if leftSibling.keys.count > bTree.order / 2 {
                        // get right element from left sibling into current node
                        
                        let rightKey = leftSibling.keys.last!
                        let rightChild = leftSibling.childNodes.last!
                        
                        node.keys.insert(parent!.keys[index], atIndex: 0)
                        node.childNodes.insert(rightChild, atIndex: 0)
                        
                        parent!.keys[index] = rightKey
                        
                        leftSibling.keys.removeLast()
                        leftSibling.childNodes.removeLast()
                    }
                } else if index < parent!.childNodes.count - 1 {
                    // step 2: check sibling to the right
                    let rightSibling = parent!.childNodes[index + 1]
                    if rightSibling.keys.count > bTree.order / 2 {
                        // get left element from right sibling into current node
                        
                        let leftKey = rightSibling.keys.first!
                        let leftChild = rightSibling.childNodes.first!
                        
                        node.keys.append(parent!.keys[index])
                        node.childNodes.append(leftChild)
                        
                        parent!.keys[index] = leftKey
                        
                        rightSibling.keys.removeFirst()
                        rightSibling.childNodes.removeFirst()
                    }
                } else {
                    // step 3: merge left and right sibling
                    /// TODO
                }
            }
        }
    }
    
    public func deleteKey(key: KeyType) {
        if let found = self.searchNode(key) {
            if found.node.isLeaf() {
                found.node.keys.removeAtIndex(found.index)
                found.node.rebalanceFromNode(found.node)
            } else if found.node.isInternal() {
                found.node.keys[found.index] = found.node.childNodes[found.index].keys.last!
                found.node.childNodes[found.index].keys.removeLast()
                found.node.rebalanceFromNode(found.node.childNodes[found.index])
            }
        }
    }
    
    public var description: String {
        var s = [String]()
        s.append("Keys")
        s.append(keys.description)
        if childNodes.count > 0 {
            s.append(">")
            for node in childNodes {
                s.append(node.keys.description)
            }
        }
        s.append("\n")
        for node in childNodes {
            if !node.isLeaf() {
                s.append(node.description)
            }
        }
        return s.joinWithSeparator(" ")
    }
}

let max = 200000
let order = 4
let tree1 = try! BTree<Int>(order: order)!

for _ in 1...max {
    let key = random() % max
    tree1.addKey(key)
}
print("==== Tree 1 (random add pattern) ====")
print("average keys per node: \(tree1.averageKeysPerNode())")
print("tree height: \(tree1.height())")


let tree2 = try! BTree<Int>(order: order)!

for key in 1...max {
    tree2.addKey(key)
}
print("==== Tree 2 (sequential add pattern) ====")
print("average keys per node: \(tree2.averageKeysPerNode())")
print("tree height: \(tree2.height())")

tree2.deleteKey(max / 2)

