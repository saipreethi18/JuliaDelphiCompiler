# Team Members
- Prathima Dodda (2505 5647)
- Sai Preethi Kota (6650 2985)
# Delphi Interpreter in Julia

## Overview

This project implements an interpreter for a Delphi-like programming language by extending a Pascal grammar. The interpreter supports object-oriented features including:

- **Numeric Operations using Variables**
- **Classes and Objects**
- **Constructors and Destructors**
- **Encapsulation**
- **Inheritance**
- **Interfaces**

The interpreter is written in Julia and is divided into three main components:

1. **Lexer**: Tokenizes the source code. (lexer.jl)
2. **Parser**: Builds an Abstract Syntax Tree (AST) from the tokens. (parser.jl)
3. **Interpreter**: Evaluates the AST and executes the program. (interpreter.jl)

Test cases are provided to illustrate the functionality of constructors, destructors, encapsulation, inheritance, and interfaces.

## Files

- **`lexer.jl`**  
  Contains the lexer implementation that reads Delphi source code and produces tokens.

- **`parser.jl`**  
  Contains the parser that converts tokens into an AST. This parser supports class declarations, interfaces, inheritance clauses, and procedure (method) declarations.

- **`interpreter.jl`**  
  Contains the interpreter code, which defines the environment, evaluates expressions, executes statements, and handles object instantiation and method calls.

- **`test_runner.jl`**  
  A test runner script that ties everything together. It reads a source code file (e.g., a `.pas` file), tokenizes it, parses it, and then executes the resulting AST.

- **Test Files** (examples):
  - `test1.pas`  
    Demonstrates storing values in variables and arithmetic operations.
  - `test_class.pas`  
    Demonstrates Classes and Objects.
  - `TestConstructor.pas`  
    Demonstrates constructors.
  - `TestConstructorDestructor.pas`  
    Demonstrates class instantiation, constructors, and destructors.
  - `TestInheritance.pas`  
    Demonstrates inheritance.
  - `TestInterface.pas`  
    Demonstrates interfaces and method calls.

## Requirements

- **Julia 1.x** – The project is implemented in Julia, so you will need to have Julia installed.

## How to Run

1. **Download the Project**  
   Ensure all project files (`lexer.jl`, `parser.jl`, `interpreter.jl`, `test_runner.jl`, and your test source files) are in one project directory.

2. **Open a Terminal in the Project Directory**

3. **Run the Test Runner**  
   Use the following command:
   ```bash
   julia test_runner.jl
