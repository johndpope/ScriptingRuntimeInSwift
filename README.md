# SeaTurtle

SeaTurtle is a simple [turtle graphics](https://en.wikipedia.org/wiki/Turtle_graphics) scripting language and runtime for macOS built in Swift.
![Release 0.0.1](SeaTurtle001.png)

SeaTurtle is reminiscent of (but not compatible with) the Logo programming language environments popular in elementary schools in the late '80s and early '90s.

## Scripting Language

The current version of the scripting language supports the following commands:

`RIGHT N`
Turn the turtle N degrees to the right.

`LEFT N`
Turn the turtle N degrees to the left.

`FORWARD N`
Move the turtle N pixels forward.

`BACKWARD N`
Move the turtle N pixels backward.

`SUB NAME`
Declare a subroutine named NAME.

`REPEAT N`
Declare a loop that iterates N times.

`END`
End a subroutine declaration or loop.

`NAME`
Call a subroutine named NAME.

All numbers must be integers, and all subroutine names must start with a letter. For the context-free grammar of SeaTurtle, see the file `cfg.txt`. See some sample scripts in the directory `SeaTurtle Scripts`.

## Script Files
Script files are just UTF-8 encoded plain text files with SeaTurtle commands. They have the extension `.seat`.

## Implementation

The files that compose the simple lexer, parser, and interpreter are in the directory `Sources`. The main macOS app is document-based and built using Storyboards, Cocoa Bindings, and Sprite Kit.

## Future Direction

The SeaTurtle scripting language will hopefully get:

- [ ] Variable Declarations
- [ ] Arithmetic Expressions
- [ ] Boolean Expressions
- [ ] If-Statements
- [ ] PENUP/PENDOWN
- [ ] HOME (move turtle back to starting location)
- [ ] COLOR C (change pen color)

And the SeaTurtle runtime environment should have:

- [ ] Syntax Highlighting/Coloring
- [ ] Display of line numbers
- [ ] Real-time reporting of syntax or parsing errors
- [ ] Stepping through scripts forwards and backwards
- [ ] Pausing execution
- [ ] Clear canvas option
- [ ] Printing support (both scripts and turtle graphics images)
- [ ] Turtle graphics picture exports
- [ ] A Tutorial
- [ ] Built-in Examples

## Authorship and License

SeaTurtle is written by David Kopec and released under the GNU GPL Version 3.
