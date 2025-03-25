# Environment and helper functions

mutable struct Environment
    variables::Dict{String, Any}
    classes::Dict{String, Any}
end

function Environment()
    return Environment(Dict(), Dict())
end

# Recursively search for a constructor node in the AST
function find_constructor(node::ASTNode)
    if node.type == "constructor"
        return node
    end
    for child in node.children
        local cons = find_constructor(child)
        if cons !== nothing
            return cons
        end
    end
    return nothing
end

# Instantiate a class by merging parent's fields and executing the constructor
function instantiate_class(className::String, env::Environment)
    if !haskey(env.classes, className)
        error("Runtime Error: Unknown class $(className)")
    end
    local class_ast = env.classes[className]
    local obj = Dict{String,Any}()
    
    # Merge parent's fields if present.
    local parentName = nothing
    for member in class_ast.children
        if member.type == "parent"
            parentName = member.value
            break
        end
    end
    if parentName !== nothing
        local parent_obj = instantiate_class(parentName, env)
        for (k, v) in parent_obj
            obj[k] = v
        end
    end
    
    # Initialize fields declared in this class (and in public/private blocks).
    for member in class_ast.children
        if member.type == "var_decl"
            obj[member.value] = 0
        elseif member.type in ["public", "private"]
            for sub in member.children
                if sub.type == "var_decl"
                    obj[sub.value] = 0
                end
            end
        end
    end

    # Run the constructor if present.
    local cons = find_constructor(class_ast)
    if cons !== nothing
        for stmt in cons.children
            if stmt.type == "assign"
                local new_value = eval_expression(stmt.children[1], env)
                if haskey(obj, stmt.value)
                    obj[stmt.value] = new_value
                end
            end
        end
    end

    # Store the class name in the object (for method lookup).
    obj["class"] = className
    return obj
end

# Expression evaluation

function eval_expression(node::ASTNode, env::Environment)
    if node.type == "number"
        return parse(Int, node.value)
    elseif node.type == "string"
        return node.value
    elseif node.type == "variable"
        if haskey(env.variables, node.value)
            return env.variables[node.value]
        else
            error("Runtime Error: Undefined variable $(node.value)")
        end
    elseif node.type == "object"
        if haskey(env.variables, node.value)
            return env.variables[node.value]
        else
            error("Runtime Error: Undefined object variable $(node.value)")
        end
    elseif node.type == "object_instantiation"
        return instantiate_class(node.value, env)
    elseif node.type == "field_access"
        local obj = eval_expression(node.children[1], env)
        if haskey(obj, node.value)
            return obj[node.value]
        else
            error("Runtime Error: Field $(node.value) not found in object")
        end
    elseif node.type == "binary_op"
        local left = eval_expression(node.children[1], env)
        local right = eval_expression(node.children[2], env)
        if node.value == "+"
            return left + right
        elseif node.value == "-"
            return left - right
        elseif node.value == "*"
            return left * right
        elseif node.value == "/"
            return left ÷ right
        else
            error("Runtime Error: Unknown operator $(node.value)")
        end
    else
        error("Runtime Error: Unknown expression type $(node.type)")
    end
end

# Method call evaluation

function eval_method_call(node::ASTNode, env::Environment)
    local obj = eval_expression(node.children[1], env)
    local method_name = node.value
    if !haskey(obj, "class")
        error("Runtime Error: Object has no class info")
    end
    local className = obj["class"]
    if !haskey(env.classes, className)
        error("Runtime Error: Unknown class $(className)")
    end
    local class_ast = env.classes[className]
    local proc = nothing
    for member in class_ast.children
        if (member.type == "procedure" || member.type == "destructor") && member.value == method_name
            proc = member
            break
        elseif member.type in ["public", "private"]
            for sub in member.children
                if (sub.type == "procedure" || sub.type == "destructor") && sub.value == method_name
                    proc = sub
                    break
                end
            end
        end
        if proc !== nothing
            break
        end
    end
    if proc === nothing
        error("Runtime Error: Method $(method_name) not found in class $(className)")
    end
    for stmt in proc.children
        eval_statement(stmt, env)
    end
    return nothing
end

# Statement evaluation

function eval_statement(node::ASTNode, env::Environment)
    if node.type == "class_decl"
        env.classes[node.value] = node
    elseif node.type == "assign"
        local value = eval_expression(node.children[1], env)
        env.variables[node.value] = value
    elseif node.type == "print"
        local results = map(expr -> string(eval_expression(expr, env)), node.children)
        println(join(results, " "))
    elseif node.type == "var_decl"
        env.variables[node.value] = 0
    elseif node.type == "local_var_decl"
        local value = eval_expression(node.children[1], env)
        env.variables[node.value] = value
    elseif node.type == "method_call"
        eval_method_call(node, env)
    else
        return
    end
end

# Program evaluation

function eval_program(node::ASTNode, env::Environment)
    for stmt in node.children
        eval_statement(stmt, env)
    end
end

# Main entry point: run interpreter from source code

function run_interpreter(source_code::String)
    println("\nOutput:")
    println("==========")
    local tokens = tokenize(source_code)
    local parser = Parser(tokens)
    local ast = parse_program(parser)
    local env = Environment()
    eval_program(ast, env)
    println("\n")
end