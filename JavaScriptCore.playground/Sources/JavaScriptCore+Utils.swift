import JavaScriptCore

/**
 */
extension JSContext {
    /**
     */
    public enum ValueError: Error {
        case isUndefined
        case isNull
    }
    
    /**
     */
    public struct Script: ExpressibleByStringLiteral {
        public enum LoadError: Error {
            case notFound(bundle: Bundle)
            case unknown(error: Error?)
        }
        
        ///
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
         */
        fileprivate func load(in bundle: Bundle) throws -> String {
            guard let url = bundle.url(forResource: rawValue, withExtension: nil) else {
                throw LoadError.notFound(bundle: bundle)
            }
            
            return try String(contentsOf: url)
        }
    }
    
    /**
     */
    public func evaluate(script: Script, in bundle: Bundle = .main) throws -> JSValue! {
        return evaluateScript(try script.load(in: bundle))
    }

    /**
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
     */
    public func define<Key: NSCopying & NSObjectProtocol, Value>(_ key: Key, as object: Value!) {
        setObject(object, forKeyedSubscript: key)
    }
    
    /**
     */
    public func define<T>(_ key: String, as object: T!) {
        define(NSString(string: key), as: object)
    }
}
