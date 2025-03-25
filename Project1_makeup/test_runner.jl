include("lexer.jl")
include("parser.jl")
include("interpreter.jl")

function run_interpreter_from_file(filename::String)
    source_code = read_file_utf8(filename)
    run_interpreter(source_code)
end

println("Running Delphi Interpreter Test...")
run_interpreter_from_file("test1.pas")
run_interpreter_from_file("test_class.pas")
run_interpreter_from_file("TestConstructor.pas")
run_interpreter_from_file("TestConstructorDestructor.pas")
run_interpreter_from_file("TestEncapsulation.pas")
run_interpreter_from_file("TestInheritance.pas")
run_interpreter_from_file("TestInterface.pas")