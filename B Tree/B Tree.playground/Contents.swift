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

public class BTreeNode<T: Comparable> {
    let order: Int
    var parent: BTreeNode? // No parent for the root node
    var keys: [T]
    var childNodes: [BTreeNode<T>] // Empty child nodes for leaf nodes

    required public init?(order: Int) throws {
        self.parent = nil
        self.order = order
        self.keys = [T]()
        self.childNodes = [BTreeNode<T>]()

        guard order >= 2 else {
            throw BTreeError.BadOrder
        }
    }

    internal init(parent: BTreeNode) {
        self.parent = parent
        self.order = parent.order
        self.keys = [T]()
        self.childNodes = [BTreeNode<T>]()
    }

    func isRoot() -> Bool {
        return parent == nil
    }

    func isLeaf() -> Bool {
        return childNodes.count == 0
    }

    func indexOfKey(key: T) -> Int? {
        for index in keys.indices {
            if keys[index] == key {
                return index
            }
        }
        return nil
    }

    func rightIndexOfKey(key: T) -> Int {
        for index in keys.indices {
            if keys[index] > key {
                return index
            }
        }
        return keys.count
    }
    
    func shiftKeysFromIndex(fromIndex: Int) {
        for index in keys.indices.endIndex.stride(to: fromIndex, by: -1) {
            keys[index] = keys[index-1]
        }
    }
    
    func searchLeaf(key: T) -> BTreeNode {
        if isLeaf() {
            return self
        }

        // No leaf
        return childNodes[rightIndexOfKey(key)].searchLeaf(key)
    }

    public func addKeyToTree(key: T) {
        let insertLeaf = searchLeaf(key)
        insertLeaf.addKeyToNode(key)
    }
    
    internal func addKeyToNode(key: T) {
        // insert key
        let insertIndex = rightIndexOfKey(key)
        shiftKeysFromIndex(insertIndex)
        keys[insertIndex] = key
        
        // check if node is past max
        let maxKeys = order - 1
        if keys.count >= maxKeys {
            // leaf at max, split up
            let medianIndex = keys.count / 2
            let medianKey = keys[medianIndex]
            if parent == nil {
                parent = try! BTreeNode(order: order)
            }
            parent!.addKeyToNode(medianKey)
        }
    }
}

let tree = try! BTreeNode<Int>(order: 7)!

for key in 1...1000 {
    tree.addKeyToTree(key)
}




