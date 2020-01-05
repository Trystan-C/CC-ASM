## Desired
* Way to refresh changes w/o restarting the computer?
* Write disassembler using ccasm.

## Documentation
* CONTRIBUTING.md for adding instructions/tests.
* Update README.md with system overview, limitations, etc.

## Instructions to Add
* trap <byte>
    * 0 -- Write null-terminated ASCII string at A0.
    * 1 -- Kill execution, i.e., halt CPU.
    * 2 -- Shutdown
    * 3 -- Restart
    * 4 -- Read null-terminated string from std-in to the address stored in A0.
    * 5 -- Set terminal cursor X
    * 6 -- Set terminal cursor Y
    * 7 -- Get terminal dimensions, store in d6, d7?
    
## Other Features
* File-descriptor system for interacting with peripherals.
    * Add common interface for developing drivers for each peripheral.
