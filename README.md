# JuliaDelphiCompiler

## Project Overview

The **JuliaDelphiCompiler** project is an implementation of a Pascal-to-Delphi compiler in the Julia programming language. It extends the standard Pascal grammar to support object-oriented features like classes, constructors, destructors, and encapsulation, along with optional support for inheritance and interfaces. The project demonstrates how to work with Julia's powerful language features to build an interpreter that can execute the Delphi-like extensions of Pascal.

## Features Implemented
- **Classes and Objects**
- **Constructors and Destructors**
- **Encapsulation**
- **Inheritance** (Bonus Feature)
- **Interfaces** (Bonus Feature)

## Project Setup

### Prerequisites

To run this project, you need to have the following installed:

1. **Julia**: [Download Julia](https://julialang.org/downloads/)
2. **ANTLR 4**: Used for parsing the Pascal grammar.

### Installation Steps

1. Clone this repository:
   ```bash
   git clone https://github.com/saipreethi18/JuliaDelphiCompiler.git
   cd JuliaDelphiCompiler
Install necessary dependencies in Julia: You may need to install required Julia packages by running the following in the Julia REPL:

julia
Copy
Edit
using Pkg
Pkg.add("ANTLR")
Build the parser and lexer:

Use ANTLR4 to generate the parser and lexer code for the Delphi-like grammar.

Follow instructions for the grammar creation in the parser.jl and lexer.jl files.

To run the project:

Use the test_runner.jl script to execute tests.

How to Run
Run the following command to execute the interpreter:

bash
Copy
Edit
julia test_runner.jl
Check the outputs of the test cases in the console.

Example Files
TestConstructor.pas: Demonstrates constructors and their usage.

TestEncapsulation.pas: Demonstrates how encapsulation works in the language.

TestInheritance.pas: Example of how inheritance is handled in the language (Bonus).

TestInterface.pas: Example of interfaces in the language (Bonus).

Contributing
Feel free to fork this repository, create branches, and submit pull requests if you want to contribute improvements.

License
This project is licensed under the MIT License - see the LICENSE file for details.

Acknowledgments
Thanks to the ANTLR4 team for creating a robust parsing tool.

The project builds upon the existing Pascal grammar and extends it to support Delphi-like features.

sql
Copy
Edit

### Instructions to Add the README:

1. Create a new file named `README.md` in the root directory of your repository.
2. Paste the above content into this file.
3. Save the file.

Finally, commit the README to Git and push it:

```bash
git add README.md
git commit -m "Added README for JuliaDelphiCompiler project"
git push
