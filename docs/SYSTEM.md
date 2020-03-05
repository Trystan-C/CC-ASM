# CC-ASM System Overview

CC-ASM mimics a sort of 68k-esque assembly language. The system composed a few simple components
that fit together to form the end-product. This overview does not assumes a baisc knowledge of
low-level computer architecture. That being said, the system itself is an oversmiplification of a real
low-level computing environment.

## Lua Environment

CC-ASM is loaded into a single global namespace, `_G.ccasm`. To start a new instance of CC-ASM, run the
script at `/ccasm/ccasm.lua`. This will clear any and all state in CC-ASM, including the memory contents,
the register values, and any APIs that have been loaded for use by the system. This is useful for loading
changes made to the system's source code without having to restart the computer.

## Core Components

CC-ASM is composed of handful of core components. These components include:

* Instruction Set
* Assembler
* Loader
* Memory
* CPU
* Registers
* Debugger

## Instruction Set

CC-ASM's instruction set is defined in `/ccasm/src/instructions.lua`. Each instruction represents a
single action that can be executed in a CPU cycle (step). All instructions follow a very simple format that
is not space efficient but is very simple and thus easier to deal with.

### Size Restrictions

All data in CC-ASM are represented by either 1, 2, or 4 bytes. These sizes are referred to respectively as
byte, word, and long (short for long word).

### Instruction Format

All CC-ASM instructions share the following format, where each `[...]` is a single byte, and each `[[...]]` is
multiple bytes:

`[instruction_id][num_operands][[operands]]`

Each operand has the following format:

`[operand_type][operand_size_in_bytes][operand_byte_0][...][operand_byte_N]`

where `N` is the number of bytes used to represent the operand: 1, 2, or 4.

See `/docs/INSTRUCTIONS.md` for the instruction set documentation and `/docs/OPERANDS.md` for
the supported operand documentation.

In reality, an instruction set describes the combinations of bits understood by the CPU as they correspond to
different operations components of the CPU can perform. These combinations are derived from the internal configuration
of the circuits inside the CPU hardware.  CC-ASM separates these components into the `instructions.lua` and
`cpu.lua` modules.

## Assembler

CC-ASM's assembler is responsible for translating CC-ASM source code (`.ccasm` files) into object code (`.cco` files).
Source code is the code that you write, and object code is the binary representation that is understood and executed
by the CPU. See `/docs/ASSEMBLER.md` for an overview of the features available in the language.

To assemble a CC-ASM source file, use `/ccasm/src/assembler.lua <file.ccasm>`, where `<file.ccasm>` is the relative path
to your source file. This will generate an object file of the same in the same directory that can be loaded into memory
for execution.

## Loader

The CC-ASM loader is responsible for taking object code (`.cco` files) and loading them into memory for execution. To load
an assembled program into memory, use `/ccasm/src/load.lua <file.cco>`, where `<file.cco>` is the relative path to your object
code file.

## Memory

CC-ASM's memory module is just a 1D table of `2^16` bytes, numbers between 0 and 255. This works out to `64 kB` of working memory.
Not all memory, however, should be used by your programs. All addresses in CC-ASM are 2 bytes (1 word).

### Stack

The stack is memory used by the CPU for subroutine calls and by the user for storing data in registers for use at a later time.
Stack memory is all of the bytes in address range of `0x7F` to `0x47F`, exactly `1025` bytes. The top of the stack is maintained
by the stack pointer in the `registers.lua` module, which is the address word for where the next value should be read or written.

Subroutine calls using the `bsr` instruction store the address jumped from on the stack, and `ret` instructions set the program counter
to the next word on the stack.

CC-ASM programs can also directly write/read to/from the stack using the `push/pop` instructions. There is no size granualarity provided
with these instructions, however, so every `push/pop` stores a long. If a program tries to push a long onto the stack that will push

### User Input

Currently, the `run.lua` utility stores key input values (the key id returned by `os.pullEvent("key")`) at the address `0x200`. Programs
in execution can read the byte at this address for the most recent key event record to accept user input.

## CPU

CC-ASM's CPU is responsible for loading and executing instructions, i.e., stepping. The CPU reads each instruction in the format
described in the [instruction format](#instruction-format) section. It depends upon the `instructions.lua`, `memory.lua`, and
`operandTypes.lua`, and `registers.lua` APIs to interpret the bytes read for each instruction. The CPU keeps track of which
instruction its executing using the program counter contained within the `registers.lua` module.

## Registers

Registers are internal spaces for storing intermediate data for doing things like math, comparisons, and reading/writing data from/to
memory. In reality, registers are hardware built into the CPU, but CC-ASM separates them between the `registers.lua` and `cpu.lua`
modules, respectively.

Registers are separated into three types: data registers, address registers, and special registers. Each register can hold up to one
long (4 bytes).

### Data Registers

Data registers do the real work. They're used for writing data to memory, reading data from memory, and doing math or logic.

### Address Registers

Address registers are used for addressing memory and providing information to the CPU about where certain data are located.

### Special Registers

The special registers are the stack pointer, the program counter, and the status register.

#### Stack Pointer

The stack pointer contains the address word for where the next stack value should be read or written.

#### Program Counter

The program counter keeps track of the address of the start of the next instruction to be executed by the CPU.

## Debugger

The CC-ASM debugger is a utility program that lets you view memory, the state of the CPU registers, and step the CPU. This
program is useful for executing programs in a very granular manner, so you can observe their behavior for both understanding
and amusement.