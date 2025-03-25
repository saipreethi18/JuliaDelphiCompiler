mutable struct Token
  type::String
  value::String
end

function remove_comments(source::String)
    source = replace(source, r"//[^\n]*" => "")
    source = replace(source, r"\{[^}]*\}" => "")
    return source
end


function read_file_utf8(file_path::String)
    open(file_path, "r") do f
        content = String(read(f))
        # Remove BOM
        local clean_content = replace(content, "\ufeff" => "")
        local final_content = remove_comments(clean_content)
        #println("Source code:\n", final_content)  # Debug print
        return final_content
    end
end

function tokenize(source::String)
    tokens = Token[]
    # Unified regex pattern that prioritizes string literals and keywords.
    local pattern = r"('[^']*')|program|interface|class|inherits|implements|end|constructor|destructor|public|private|procedure|var|begin|integer|string|writeln|:=|[a-zA-Z_][a-zA-Z0-9_]*|[0-9]+|[+\-*/(),;.:]"
    local matches = eachmatch(pattern, source)
    local words = [m.match for m in matches]
    
    for word in words
        if occursin(r"^'.*'$", word)
            push!(tokens, Token("STRING", word))
        elseif word in ["program", "interface", "class", "inherits", "implements", "end", "constructor", "destructor", "public", "private", "procedure"]
            push!(tokens, Token(uppercase(word), word))
        elseif word == "var"
            push!(tokens, Token("VAR", word))
        elseif word == "begin"
            push!(tokens, Token("BEGIN", word))
        elseif word == "integer"
            push!(tokens, Token("INTEGER", word))
        elseif word == "string"
            push!(tokens, Token("STRING_TYPE", word))
        elseif word == "writeln"
            push!(tokens, Token("PRINT", word))
        elseif word == ":="
            push!(tokens, Token("ASSIGN", word))
        elseif word == ";"
            push!(tokens, Token("SEMICOLON", word))
        elseif word == ":"
            push!(tokens, Token("COLON", word))
        elseif word == "."
            push!(tokens, Token("DOT", word))
        elseif word == ","
            push!(tokens, Token("COMMA", word))
        elseif word == "+"
            push!(tokens, Token("PLUS", word))
        elseif word == "-"
            push!(tokens, Token("MINUS", word))
        elseif word == "*"
            push!(tokens, Token("MULTIPLY", word))
        elseif word == "/"
            push!(tokens, Token("DIVIDE", word))
        elseif word == "("
            push!(tokens, Token("LPAREN", word))
        elseif word == ")"
            push!(tokens, Token("RPAREN", word))
        elseif occursin(r"^[0-9]+$", word)
            push!(tokens, Token("NUMBER", word))
        elseif occursin(r"^[a-zA-Z_][a-zA-Z0-9_]*$", word)
            push!(tokens, Token("IDENTIFIER", word))
        end
    end

    return tokens
end