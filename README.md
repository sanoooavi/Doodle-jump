# Doodle Jump Game (Assembly x86) 🎮

Welcome to the exciting world of Doodle Jump! This repository contains a simple implementation of the popular game using Assembly language for the x86 processor. Challenge yourself to reach new heights by guiding our character through platforms while dodging obstacles.

## Prerequisites 📋

To run this game, you will need the following:

- DOS Emulator (e.g., DOSBox)
- Knowledge of Assembly language and the x86 processor.

## How to Play 🎮

To control the character's movement, utilize the j and k keys on your keyboard. The character automatically jumps upon landing on a platform. Your objective is to leap from one platform to another, ascending to higher levels. Be cautious not to fall off the screen or collide with obstacles. Keep an eye on your score, which can be found in the upper right corner of the screen.
Beware of the bugs that lurk within the game! Make sure to steer clear of them as they can hinder your progress. Additionally, be cautious of red platforms, as they are broken and should be avoided.

https://github.com/sanoooavi/Doodle-jump/assets/81512968/4bf5399d-75cd-4dbe-bc28-1a7def77e243

## Installation 💻
To run the program, you must first download DOSBox and the 8086 assembler. Follow these steps:

- Download [DOSBox](https://www.dosbox.com/download.php?main=1) and install it on your system.
- Obtain the 8086 [assembler](https://drive.google.com/drive/folders/1akM4UNg6StiVE3ehzEstOgOhEw1JBxA0?usp=drive_open) and set it up.
- Clone or download the repository to your local machine.
- Execute the following commands in the specified order:
```
mount [DriveLetter] [DirectoryPath]
```
- Replace `[DriveLetter]` with an available drive letter (e.g., C, D, E) that you want to assign within DOSBox.
- Replace `[DirectoryPath]` with the full path to the directory containing the assembly code.

For example, if you want to mount the "C:\Assembly" directory as the C drive in DOSBox, you would use the following command:
```
mount c C:\Assembly
cd C:\Assembly\Project
masm /a project.asm
link project
project
```
Get ready to embark on an exhilarating Doodle Jump adventure! Enjoy the game and aim for new heights!
