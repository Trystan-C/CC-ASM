## Desired
* Way to refresh changes w/o restarting the computer?
* Write disassembler using ccasm.

## Documentation
* CONTRIBUTING.md for adding instructions/tests.
* Update README.md with system overview, limitations, etc.

## Instructions to Add
* trap <byte>
    * 0 -- Store terminal width/height in D6/D7.
    * 1 -- Store cursor x/y in D6/D7.
    * 2 -- Set terminal cursor x/y to values in D0/D1.
    * 3 -- Write null-terminated ASCII string at A0.
TODO:
    * 4 -- Read null-terminated string from std-in to the address stored in A0.
    * 5 -- Shutdown
    * 6 -- Restart
    
## Other Features
* File-descriptor system for interacting with peripherals.
    * Add common interface for developing drivers for each peripheral.
