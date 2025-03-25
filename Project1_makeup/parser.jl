mutable struct ASTNode
  type::String
  value::Any
  children::Array{ASTNode,1}
end
mutable struct Parser
  tokens::Array{Token,1}
  position::Int
end

function Parser(tokens)
  return Parser(tokens, 1)
end

function parse_member(parser::Parser)
    local token = current_token(parser)
    if token === nothing
        error("Unexpected end of input while parsing class members")
    end
    # Use a case-insensitive check for procedure
    if token.type == "VAR"
        return parse_var_decl(parser)
    elseif token.type == "CONSTRUCTOR"
        return [parse_constructor(parser)]
    elseif token.type == "DESTRUCTOR"
        return [parse_destructor(parser)]
    elseif token.type == "PROCEDURE" || lowercase(token.value) == "procedure"
        return [parse_procedure(parser)]
    else
        error("Syntax Error: Unexpected token `$(token.value)` in class member declaration")
    end
end


function current_token(parser::Parser)
  return parser.position <= length(parser.tokens) ? parser.tokens[parser.position] : nothing
end

function match(parser::Parser, expected_type::String)
  token = current_token(parser)
  if token !== nothing && token.type == expected_type
      parser.position += 1
      return token
  else
      error("Syntax Error: Expected ", expected_type, ", found ", (token !== nothing ? token.type : "EOF"))
  end
end

function parse_program(parser::Parser)
    match(parser, "PROGRAM")
    match(parser, "IDENTIFIER")
    match(parser, "SEMICOLON")
    
    # If there's an interface section, skip it.
    if current_token(parser) !== nothing && lowercase(current_token(parser).value) == "interface"
        parse_interface_section(parser)
    end

    local declarations = ASTNode[]
    # Continue to process global declarations until "begin" is reached.
    while current_token(parser) !== nothing && lowercase(current_token(parser).value) != "begin"
        if current_token(parser).type == "VAR"
            append!(declarations, parse_var_decl(parser))
        elseif current_token(parser).type == "CLASS"
            push!(declarations, parse_class_decl(parser))
        else
            # Skip any unrecognized tokens (or error out if desired)
            match(parser, current_token(parser).type)
        end
    end

    match(parser, "BEGIN")
    local statements = ASTNode[]
    while current_token(parser) !== nothing && current_token(parser).type != "END"
        push!(statements, parse_statement(parser))
    end

    match(parser, "END")
    match(parser, "DOT")
    
    return ASTNode("program", "", vcat(declarations, statements))
end


function parse_var_decl(parser::Parser)
    match(parser, "VAR")
    
    var_names = []
    push!(var_names, match(parser, "IDENTIFIER").value)
    
    while current_token(parser) !== nothing && current_token(parser).type == "COMMA"
        match(parser, "COMMA")
        push!(var_names, match(parser, "IDENTIFIER").value)
    end
    
    match(parser, "COLON")
    
    # Expect either INTEGER or STRING_TYPE for the type.
    local type_token = current_token(parser)
    if type_token.type == "INTEGER" || type_token.type == "STRING_TYPE"
        local var_type = match(parser, type_token.type)
        match(parser, "SEMICOLON")
        return [ASTNode("var_decl", name, [ASTNode("type", var_type.value, [])]) for name in var_names]
    else
        error("Syntax Error: Expected type INTEGER or STRING_TYPE, found ", type_token.type)
    end
end


function parse_class_decl(parser::Parser)
    match(parser, "CLASS")
    local class_name = match(parser, "IDENTIFIER").value
    local parent_class = nothing
    local interface_list = String[]
    
    if current_token(parser) !== nothing && lowercase(current_token(parser).value) == "inherits"
        match(parser, current_token(parser).type)
        parent_class = match(parser, "IDENTIFIER").value
    end

    if current_token(parser) !== nothing && lowercase(current_token(parser).value) == "implements"
        match(parser, current_token(parser).type)
        push!(interface_list, match(parser, "IDENTIFIER").value)
        while current_token(parser) !== nothing && current_token(parser).type == "COMMA"
            match(parser, "COMMA")
            push!(interface_list, match(parser, "IDENTIFIER").value)
        end
    end

    match(parser, "SEMICOLON")
    
    local members = ASTNode[]
    while current_token(parser) !== nothing && lowercase(current_token(parser).value) != "end"
        local token = current_token(parser)
        if token.type == "VAR"
            append!(members, parse_var_decl(parser))
        elseif token.type == "CONSTRUCTOR"
            push!(members, parse_constructor(parser))
        elseif token.type == "DESTRUCTOR"
            push!(members, parse_destructor(parser))
        elseif token.type in ["PUBLIC", "PRIVATE"]
            push!(members, parse_encapsulation(parser))
        elseif token.type == "PROCEDURE"
            push!(members, parse_procedure(parser))
        else
            error("Syntax Error: Unexpected token `$(token.value)` inside class `$(class_name)`")
        end
    end

    match(parser, "END")
    match(parser, "SEMICOLON")
    
    # Store parent and interface info in separate nodes
    if parent_class !== nothing
        push!(members, ASTNode("parent", parent_class, []))
    end
    for iface in interface_list
        push!(members, ASTNode("interface", iface, []))
    end

    return ASTNode("class_decl", class_name, members)
end


function parse_procedure(parser::Parser)
    match(parser, "PROCEDURE")
    local proc_name = match(parser, "IDENTIFIER").value
    match(parser, "SEMICOLON")
    match(parser, "BEGIN")
    local body = ASTNode[]
    while current_token(parser) !== nothing && current_token(parser).type != "END"
        push!(body, parse_statement(parser))
    end
    match(parser, "END")
    match(parser, "SEMICOLON")
    return ASTNode("procedure", proc_name, body)
end




function parse_interface_section(parser::Parser)
    # The interface section starts with the token "interface"
    # (Note: Your lexer may output it as lowercase; we use lowercase() for comparison)
    if current_token(parser) !== nothing && lowercase(current_token(parser).value) == "interface"
        # Consume the "interface" token
        match(parser, current_token(parser).type)
    end
    # Skip tokens until we reach an "end" that terminates the interface section.
    # (Assuming the interface section ends with "end;" as in Delphi.)
    while current_token(parser) !== nothing && lowercase(current_token(parser).value) != "end"
        # Consume tokens (you might want to do more sophisticated parsing here if needed)
        match(parser, current_token(parser).type)
    end
    # Consume the "end" token and the following semicolon.
    match(parser, "END")
    match(parser, "SEMICOLON")
end


function parse_constructor(parser::Parser)
  match(parser, "CONSTRUCTOR")
  # Optionally match a semicolon if it is present after the constructor keyword.
  if current_token(parser) !== nothing && current_token(parser).type == "SEMICOLON"
      match(parser, "SEMICOLON")
  end
  match(parser, "BEGIN")
  
  body = []
  while current_token(parser) !== nothing && current_token(parser).type != "END"
      push!(body, parse_statement(parser))
  end
  
  match(parser, "END")
  match(parser, "SEMICOLON")
  
  return ASTNode("constructor", "", body)
end


function parse_destructor(parser::Parser)
    match(parser, "DESTRUCTOR")
    if current_token(parser) !== nothing && current_token(parser).type == "SEMICOLON"
        match(parser, "SEMICOLON")
    end
    match(parser, "BEGIN")
    local body = ASTNode[]
    while current_token(parser) !== nothing && current_token(parser).type != "END"
        push!(body, parse_statement(parser))
    end
    match(parser, "END")
    match(parser, "SEMICOLON")
    return ASTNode("destructor", "destructor", body)
end


function parse_encapsulation(parser::Parser)
  # Match the access modifier (PUBLIC or PRIVATE)
  access_modifier = match(parser, current_token(parser).type)
  members = []
  # Loop until we reach a new access modifier or the end of the class.
  while current_token(parser) !== nothing && !(current_token(parser).type in ["PUBLIC", "PRIVATE", "END"])
      local member_nodes = parse_member(parser)
      for node in member_nodes
          push!(members, node)
      end
  end
  return ASTNode(access_modifier.value, "", members)
end

function parse_statement(parser::Parser)
    local token = current_token(parser)
    if token.type == "VAR"
        return parse_local_var_decl(parser)
    elseif token.type == "IDENTIFIER"
        local var_name = match(parser, "IDENTIFIER")
        if current_token(parser) !== nothing && current_token(parser).type == "ASSIGN"
            match(parser, "ASSIGN")
            local expr = parse_expression(parser)
            match(parser, "SEMICOLON")
            return ASTNode("assign", var_name.value, [expr])
        elseif current_token(parser) !== nothing && current_token(parser).type == "DOT"
            match(parser, "DOT")
            local methodToken = current_token(parser)
            if methodToken.type in ["IDENTIFIER", "CONSTRUCTOR", "DESTRUCTOR", "PROCEDURE"]
                local method_name = methodToken.value
                match(parser, methodToken.type)
            else
                error("Syntax Error: Unexpected token `$(methodToken.value)` in method call")
            end
            # Optionally match LPAREN RPAREN if present
            if current_token(parser) !== nothing && current_token(parser).type == "LPAREN"
                match(parser, "LPAREN")
                if current_token(parser) !== nothing && current_token(parser).type != "RPAREN"
                    # Could parse arguments here if needed
                end
                match(parser, "RPAREN")
            end
            match(parser, "SEMICOLON")
            return ASTNode("method_call", method_name, [ASTNode("object", var_name.value, [])])
        else
            error("Syntax Error: Unexpected token `$(token.value)` in statement")
        end
    elseif token.type == "PRINT"
        match(parser, "PRINT")
        match(parser, "LPAREN")
        local args = ASTNode[]
        push!(args, parse_expression(parser))
        while current_token(parser) !== nothing && current_token(parser).type == "COMMA"
            match(parser, "COMMA")
            push!(args, parse_expression(parser))
        end
        match(parser, "RPAREN")
        match(parser, "SEMICOLON")
        return ASTNode("print", "", args)
    else
        error("Syntax Error: Unexpected token `$(token.value)` in statement")
    end
end


function parse_local_var_decl(parser::Parser)
    match(parser, "VAR")
    local var_name = match(parser, "IDENTIFIER").value
    match(parser, "ASSIGN")
    local init_expr = parse_expression(parser)
    match(parser, "SEMICOLON")
    return ASTNode("local_var_decl", var_name, [init_expr])
end




function parse_expression(parser::Parser)
    local token = current_token(parser)
    local left_node = nothing
    if token.type == "NUMBER"
        local numToken = match(parser, "NUMBER")
        left_node = ASTNode("number", numToken.value, [])
    elseif token.type == "STRING"
        local strToken = match(parser, "STRING")
        local strVal = replace(strToken.value, "'" => "")
        left_node = ASTNode("string", strVal, [])
    elseif token.type == "IDENTIFIER"
        local idToken = match(parser, "IDENTIFIER")
        if current_token(parser) !== nothing && current_token(parser).type == "LPAREN"
            match(parser, "LPAREN")
            match(parser, "RPAREN")
            left_node = ASTNode("object_instantiation", idToken.value, [])
        else
            left_node = ASTNode("variable", idToken.value, [])
        end
        while current_token(parser) !== nothing && current_token(parser).type == "DOT"
            match(parser, "DOT")
            local fieldToken = match(parser, "IDENTIFIER")
            left_node = ASTNode("field_access", fieldToken.value, [left_node])
        end
    else
        error("Syntax Error: Expected NUMBER, STRING, or IDENTIFIER, found ", token.type)
    end
    if current_token(parser) !== nothing && current_token(parser).type in ["PLUS", "MINUS", "MULTIPLY", "DIVIDE"]
        local opToken = match(parser, current_token(parser).type)
        local right = parse_expression(parser)
        return ASTNode("binary_op", opToken.value, [left_node, right])
    end
    return left_node
end
