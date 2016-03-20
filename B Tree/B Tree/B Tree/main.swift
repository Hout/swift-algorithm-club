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

public class BTree<KeyType: Comparable, ValueType> : CustomStringConvertible {
    var root: BTreeNode<KeyType, ValueType>?
    let order: Int
    
    required public init?(order: Int) throws {
        self.order = order
        
        guard order >= 2 else {
            throw BTreeError.BadOrder
        }
        
        self.root = BTreeNode<KeyType, ValueType>(bTree: self)
    }
    
    public func addKey(key: KeyType, value: ValueType) {
        let insertLeaf = root!.searchLeaf(key)
        insertLeaf.addKey(key, value: value)
    }
    
    public var description: String {
        return "(\(order)) \(root!.description)"
    }
}

public class BTreeNode<KeyType: Comparable, ValueType> : CustomStringConvertible {
    let bTree: BTree<KeyType, ValueType>
    var parent: BTreeNode? // No parent for the root node
    var keys: [KeyType]
    var values: [ValueType]
    var childNodes: [BTreeNode<KeyType, ValueType>] // Empty child nodes for leaf nodes
    
    internal init(bTree: BTree<KeyType, ValueType>) {
        self.bTree = bTree
        self.keys = [KeyType]()
        self.values = [ValueType]()
        self.childNodes = [BTreeNode<KeyType, ValueType>]()
        
        if bTree.root == nil {
            bTree.root = self
        }
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
    
    internal func addKey(key: KeyType, value: ValueType, rightChildNode: BTreeNode<KeyType, ValueType>? = nil) {
        print("----")
        print("Insert key \(key) in \(self)")
        if let node = rightChildNode {
            print("With right hand node \(node)")
        }
        
        let insertIndex = rightIndexOfKey(key)
        keys.insert(key, atIndex: insertIndex)
        values.insert(value, atIndex: insertIndex)
        if let node = rightChildNode {
            assert(!isLeaf())
            childNodes.insert(node, atIndex: insertIndex + 1)
        }
        
        // check if node is at max
        let maxKeys = bTree.order - 1
        if keys.count > maxKeys {
            // node at max, split up
            print("Split up node \(self)")

            let medianIndex = (bTree.order - 1) / 2
            let medianKey = keys[medianIndex]
            let medianValue = values[medianIndex]
            
            // if root, create a new root above the current one
            if isRoot() {
                print("Add new root over \(self)")
                let newRoot = BTreeNode(bTree: bTree)
                newRoot.childNodes.append(self)
                parent = newRoot
                bTree.root = newRoot
            }
            
            // now create a new node and split the current one up
            let newNode = BTreeNode<KeyType, ValueType>(bTree: bTree)
            newNode.parent = parent
            
            // keys to the right of the median key will transfer to the new node
            newNode.keys = Array(keys[medianIndex + 1...keys.count - 1])
            newNode.values = Array(values[medianIndex + 1...values.count - 1])
            keys.removeRange(medianIndex...keys.count - 1) // remove median key too as it is promoted to the parent
            values.removeRange(medianIndex...values.count - 1)
            
            // if no leaf, child nodes to the right of the median key transfer to new node too
            if !isLeaf() {
                newNode.childNodes = Array(childNodes[medianIndex + 1...childNodes.count - 1])
                childNodes.removeRange(medianIndex + 1...childNodes.count - 1)
            }
            
            print("Key to be promoted = \(medianKey)")
            print("Left node becomes \(self)")
            print("Right node becomes \(newNode)")

            // median key goes to the parent with the new node on the right hand side
            parent!.addKey(medianKey, value: medianValue, rightChildNode: newNode)
            
            print("Parent is now \(parent!.keys)")
            print("Parent's children are now \(parent!.childNodes.map({ $0.keys }))")
        }
        print("Node is now \(self)")
        print("----")

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
    
    public var description: String {
        var s = [String]()
        s.append("Keys")
        s.append(keys.description)
        s.append("\nValues")
        s.append(values.description)
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

let tree = try! BTree<Int, Int>(order: 6)!
let max = 100

for value in 1...max {
    let key = Int(rand())  % max
    print("==== Inserting \(key) ====")
    tree.addKey(key, value: value)
    print("==== Tree ====")
    print(tree)
}




