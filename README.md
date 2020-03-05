# CC-ASM

This project implements a simple assembly-like language for Computer Craft.

## Features

* Compiled 68k-esque assembly language for Computer Craft.
* API for compiling and running CC-ASM programs.
* API for adding your own instructions.
* Standalone CC-ASM program debugger.
* XUnit-inspired test runner for Computer Craft.

## Documentation

See the documentation for an overview of the system at `/docs`.

## Running Programs

### Compilation
Compile your CC-ASM source files by running: `ccasm> assemble <file1> <file2> ... <fileN>`

This will create an output file of the same name in the same directory with
the `.cco` extension.

### Loading
Load the assembled program using: `ccasm> load <outFile>`

The start address, or origin, at which the program is loaded can be changed by
passing an additional argument to `load`: `ccasm> load <outFile> <origin?>`

### Execution
Execute the compiled output using: `ccasm> src/run <start_address>`

## Debugger

CC-ASM comes with a visual debugger that can be used to view memory, view registers,
and step the cpu.

To use the debugger, load an assembled program and run `debug`.

![alt text](https://i.imgur.com/DauIhz2.png "Debugger")

## Demos

To show that you can do some neat things with CC-ASM, I've written a really, really
simple pong clone in the language. It flickers a lot, but it works.

![alt text](https://i.imgur.com/yHYa7Cq.gif "Pong Demo")

## Installation

To install, clone this repo to any computer's root directory, so all the project code
is located at `/ccasm/`.

## Testing
This section covers running the existing CC-ASM test suite. For guidance on writing
additional tests for yourself, see the `CONTRUBITNG.md` in the `test` subdirectory.

To run the existing test suite, run the following from the project root:

`ccasm> test/testRunner . -r`

![alt text](https://i.imgur.com/DAcEQzF.gif "Test Demo")

## Global State
CC-ASM relies on some global state. All of this state resides at `_G.ccasm`. To reset the
state use the following:

`ccasm> ccasm`

This will reload all of the APIs and clear memory, registers, etc.

## Limitations

* CC-ASM is **slow**. If you want to do stuff quickly, don't use this. It's a novelty project.
* Memory is restricted to 64K, i.e., a 16-bit address space.
* Data sizes are limited to 1, 2, or 4 bytes (byte, word, long).