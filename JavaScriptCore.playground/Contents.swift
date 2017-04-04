import JavaScriptCore

// Create a 'JSContext'
//------------------------------------------------------------------------------
guard let context = JSContext() else {
    fatalError("Unable to create JavaScript context.")
}

// Register an error handler callback
//------------------------------------------------------------------------------
context.exceptionHandler = {
    if let context = $0.0, let value = $0.1 {
        print("\(context)"); print("\(value)")
    }
}

// Define a JavaScript function, 'log'
//------------------------------------------------------------------------------
let log: @convention(block) () -> () = { _ in
    print("\((JSContext.currentArguments().reduce("") { $0.0 + "\($0.1)" }))")
}
context.define("log", as: log)

// Load (and evaluate) a JS script from a file
//------------------------------------------------------------------------------
do {
    try context.evaluate(script: "core.js")
} catch {
    fatalError("\(error)")
}

// Call a function defined inside the JS script
//------------------------------------------------------------------------------
if let factorial = try? context.value("factorial")
    , let result = factorial.call(withArguments: [5]) {
    print("Factorial Result: \(result.toInt32())")
}
//------------------------------------------------------------------------------
