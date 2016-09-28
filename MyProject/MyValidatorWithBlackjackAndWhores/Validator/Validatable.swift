//
//  Validatable.swift
//  MyProject
//
//  Created by username on 28/09/16.
//  Copyright © 2016 BCA. All rights reserved.
//

import Foundation
import UIKit

public typealias ValidatableField = protocol<AnyObject, Validatable>

public protocol Validatable {
    
    var validationText: String {
        get
    }
}

extension UITextField: Validatable {
    
    public var validationText: String {
        return text ?? ""
    }
}
