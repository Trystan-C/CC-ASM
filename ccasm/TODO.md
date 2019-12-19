## Desired
* Way to refresh changes w/o restarting the computer?

## Documentation
* CONTRIBUTING.md for adding instructions/tests.
* Update README.md with system overview, limitations, etc.

## Macros to Add
* declareString "str" -- Write string as ASCII bytes, append null-terminator (e.g., 0).

## Instructions to Add
* Update integer.addBytes to use signed integers. Add a couple test cases.
* cmpByte/Word/Long
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
    * 0 -- Set x-coordinate of cursor on terminal.
    * 1 -- Set y-coordinate of cursor on terminal.
    * 2 -- Write null-terminated ASCII string at A0.
    * 3 -- Kill execution, i.e., halt CPU.
    * 4 -- Shutdown
    * 5 -- Restart
    * 6 -- Read null-terminated string from std-in to the address stored in A0.
    
## Other Features
* File-descriptor system for interacting with peripherals.
    * Add common interface for developing drivers for each peripheral.
