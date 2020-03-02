## Documentation
* CONTRIBUTING.md for adding instructions/tests.
* Update README.md with system overview, limitations, etc.

## Planned Work 
* Larger pong paddles. Like, 3 pipes instead of 1.
* Add a single global namespace instead of the current approach, e.g., _G.ccasm.memory instead of just _G.memory.
* Update branching to use absolute addresses, not immediate data.
* Make instruction byte values generated, so adding new instructions is less painful.
* File-descriptor system for interacting with peripherals.
* Add common interface for developing drivers for each peripheral.
