import JavaScriptCore

/**
 Extends `JSContext` in a way that reduces boilerplate.
 */
extension JSContext {
    /**
     */
    public enum ValueError: Error {
        case isUndefined
        case isNull
    }
    
    /**
     A value which represents a block of JavaScript code.
     */
    public struct Script: ExpressibleByStringLiteral {
        /**
         */
        public enum LoadError: Error {
            case notFound(bundle: Bundle)
            case unknown(error: Error?)
        }
        
        /// The underlying String value.
        private let rawValue: String
        
        /**
         */
        public init(unicodeScalarLiteral value: String) {
            self.rawValue = value
        }
        
        /**
         */
        public init(stringLiteral value: String) {
            self.rawValue = value
        }
        
        /**
         */
        public init(extendedGraphemeClusterLiteral value: String) {
            self.rawValue = value
        }
        
        /**
         If `self` represents the name of a file, this reads the contents
         of the file, __iff__ its located in `bundle`.
         
         - parameter bundle: The bundle which contains the file.
         - returns: The contents of the file.
         
         - note: If the file cannot be located within `bundle`, a `LoadError`
                 exception is thrown.
         */
        fileprivate func load(in bundle: Bundle) throws -> String {
            guard let url = bundle.url(forResource: rawValue, withExtension: nil) else {
                throw LoadError.notFound(bundle: bundle)
            }
            
            return try String(contentsOf: url)
        }
        
        /**
         Evaluates `self` within `context`.
         
         - parameter context: The JavaScript context which performs the script.
         - returns: The resulting `JSValue`, if any.
         */
        fileprivate func run(in context: JSContext) -> JSValue! {
            return context.evaluateScript(rawValue)
        }
    }
    
    @discardableResult
    /**
     When `script` represents a JavaScript file (e.g., _"core.js"_, this will:
     - locate and load the contents of the file; then
     - evaluate the script within `self`; then
     - return the result, if any.
     
     - parameter script: The file name of the script.
     - parameter bundle: The bundle that contains the script. Defaults to `main`.
     - returns: The result of evaluating the JavaScript, if any.
     
     - note: If the file cannot be located within `bundle`, a `LoadError`
             exception is thrown.
     */
    public func evaluate(script: Script, in bundle: Bundle = .main) throws -> JSValue! {
        return evaluateScript(try script.load(in: bundle))
    }
    
    @discardableResult
    /**
     Executes the literal value of `script`.
     
     - parameter script: A block of JavaScript code.
     - returns: The resulting `JSValue`, if any.
     */
    public func execute(script: Script) -> JSValue! {
        return script.run(in: self)
    }

    /**
     The `JSValue` of key.
     
     - parameter key: The key for the value.
     - returns: The value for `key`.
     
     - note: A `ValueError` is thrown if value is `null` or `undefined`.
     */
    public func value(_ key: Any!) throws -> JSValue {
        let value: JSValue! = objectForKeyedSubscript(key)
        
        if value == nil || value.isNull {
            throw ValueError.isNull
        }
        
        if value.isUndefined {
            throw ValueError.isUndefined
        }
        
        return value
    }
    
    /**
     Assigns a value to `key`.
     
     - parameter key: The label being associated with value.
     - parameter object: The value.
     */
    public func define<Key: NSCopying & NSObjectProtocol, Value>(_ key: Key, as object: Value!) {
        setObject(object, forKeyedSubscript: key)
    }
    
    /**
     Assigns a value to `key`.
     
     - parameter key: The label being associated with value.
     - parameter object: The value.
     */
    public func define<T>(_ key: String, as object: T!) {
        define(NSString(string: key), as: object)
    }
}
