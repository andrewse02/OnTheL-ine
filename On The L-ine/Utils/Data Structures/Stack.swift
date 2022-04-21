//
//  Stack.swift
//  SelectionTesting
//
//  Created by Andrew Elliott on 4/10/22.
//

import Foundation

struct Stack<Element> {
    private var items: [Element] = []
    
    func size() -> Int {
        return items.count
    }
    
    func peek() -> Element? {
        return items.last
    }
    
    mutating func pop() -> Element? {
        return items.popLast()
    }
  
    mutating func push(_ element: Element) {
        items.append(element)
    }
    
    mutating func clear() {
        items.removeAll()
    }
    
    func toArray() -> [Element] {
        return items
    }
}

// Extension for this project's purposes
extension Stack {
    func contains(element: Element) -> Bool {
        return items.contains { cell in
            guard let cell = cell as? SelectionCollectionViewCell else { return false }
            guard let element = element as? SelectionCollectionViewCell else { return false }
            
            return cell == element
        }
    }
    
    mutating func pop(elements: Int) -> Element? {
        var result: Element?
        
        for _ in 0..<elements {
            result = items.popLast()
        }
        
        return result
    }
    
    mutating func peek(elements: Int) -> Element? {
        let index = items.endIndex - (elements)
        guard items.indices.contains(index) else { return nil }
        
        return items[index]
    }
}
