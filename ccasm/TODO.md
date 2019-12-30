## Desired
* Way to refresh changes w/o restarting the computer?
* Memory map screen data, e.g., x/y position of the cursor, color values, etc.
* Write disassembler using ccasm.

## Documentation
* CONTRIBUTING.md for adding instructions/tests.
* Update README.md with system overview, limitations, etc.

## Macros to Add
* declareString "str" -- Write string as ASCII bytes, append null-terminator (e.g., 0).

## Instructions to Add
* beq
* bne
* blt
* ble
* bgt
* bge
* bsr
* ret
* push <d0-7/a0-6>, +(sp/a7)-
* pop <d0-7/a0-6>, +(sp/a7)-
* lshiftByte/Word/Long
* rshiftByte/Word/Long
* orByte/Word/Long
* andByte/Word/Long
* xorByte/Word/Long
* trap <byte>
    * 0 -- Write null-terminated ASCII string at A0.
    * 1 -- Kill execution, i.e., halt CPU.
    * 2 -- Shutdown
    * 3 -- Restart
    * 4 -- Read null-terminated string from std-in to the address stored in A0.
    
## Other Features
* File-descriptor system for interacting with peripherals.
    * Add common interface for developing drivers for each peripheral.
