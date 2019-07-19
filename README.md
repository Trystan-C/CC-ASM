# CC-ASM

This project implements a simple assembly-like language for Computer Craft to
enable learning lower-level computer architecture concepts.

## Backstory

When I first got into programming, Computer Craft made learning fun and, most
importantly, accessible. This project is my way of paying it forward while also
having a good bit of fun along the way.

## Features

No features are currently implemented. Working on that.

The features listed below are planned for implementation:
* Compiled 68k-esque assembly language for Computer Craft.
* API for compiling and running CC-ASM programs.
* API for adding your own instructions.
* Standalone memory viewer for all CC-ASM programs.
* Standalone CC-ASM program debugger.
* XUnit-inspired test runner for Computer Craft.

## Usage

CC-ASM provides two methods of compiling and executing CC-ASM programs:
* *Shell*: Build and run programs directly on the Computer Craft shell.
* *API*: Build and execute programs using a built-in functions from your own
Lua scripts.

### Shell Usage
1. Compile your CC-ASM source files by running `assemble <file1> <file2> ... <fileN>
--output-file <output-file-name>`
at the shell.
2. Execute the compiled output using `ccasm <output-file-name>.out`.

### API Usage

TODO

## Installation

CC-ASM can be installed in two different scopes: locally and globally.

### Local Installation

To install CC-ASM locally, clone this repository and copy the contents
of the `src` to your computer's local directory. This location varies
between operating systems.

### Global Installation

To install CC-ASM globally, clone this repository and copy the `src` directory
into your Computer Craft installation's `rom` directory.

Then, move the `assemble.lua` file from the `src` directory into the root
`rom` directory.
