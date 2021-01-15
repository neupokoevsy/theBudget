//
//  CategoryModel.swift
//  theBudget
//
//  Created by Sergey Neupokoev on 06/01/2021.
//

import Foundation

struct Category {
    
    private(set) public var title: String
    private(set) public var imageName: String
    public var useCount: Int
    
    init(title: String, imageName: String, useCount: Int) {
        self.imageName = imageName
        self.title = title
        self.useCount = useCount
    }
}
