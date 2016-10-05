//
//  RegexRule.swift
//  MyProject
//
//  Created by username on 28/09/16.
//  Copyright © 2016 BCA. All rights reserved.
//

import Foundation

public class RegexRule : Rule {
    /// Regular express string to be used in validation.
    private var REGEX: String = "^(?=.*?[A-Z]).{8,}$"
    /// String that holds error message.
    private var message : String
    
    /**
     Method used to initialize `RegexRule` object.
     
     - parameter regex: Regular expression string to be used in validation.
     - parameter message: String of error message.
     - returns: An initialized `RegexRule` object, or nil if an object could not be created for some reason that would not result in an exception.
     */
    public init(regex: String, message: String = "Invalid Regular Expression"){
        self.REGEX = regex
        self.message = message
    }
    
    /**
     Method used to validate field.
     
     - parameter value: String to checked for validation.
     - returns: Boolean value. True if validation is successful; False if validation fails.
     */
    public func validate(value: String) -> Bool {
        let test = NSPredicate(format: "SELF MATCHES %@", self.REGEX)
        return test.evaluate(with: value)
    }
    
    /**
     Method used to dispaly error message when field fails validation.
     
     - returns: String of error message.
     */
    public func errorMessage() -> String {
        return message
    }
}