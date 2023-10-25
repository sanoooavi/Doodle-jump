# Doodle Jump Game (Assembly x86) 🎮

This is a simple implementation of the popular Doodle Jump game using Assembly language for the x86 processor. The game features a character that jumps on platforms to reach higher levels while avoiding obstacles.

## Prerequisites 📋

To run this game, you will need the following:

- DOS Emulator (e.g., DOSBox)
- Knowledge of Assembly language and the x86 processor.

## Getting Started 🚀

1. Clone or download the repository to your local machine.
2. Set up DOSBox on your system.
3. Mount the directory containing the game files as a drive in DOSBox.
4. Run the DOSBox emulator.
5. Change to the mounted drive in DOSBox.
6. Assemble the source code using an x86-compatible assembler (e.g., MASM).
7. Run the compiled executable file.

## How to Play 🎮

- Use j, k keys to control the character's movement.
- The character automatically jumps when landing on a platform.
- Try to jump from one platform to another to reach higher levels.
- Avoid falling off the screen or colliding with obstacles.
- The game ends when the character falls off the screen or collides with a bug.

## Installation 💻

First, you need to download DosBox and 8086 assembler. In order to run the program:

```
masm /a project.asm
link project
project
```
