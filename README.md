# xam

XAM is short for XML Adventure Machine, which is a bombastic name for a rather simple thing: It's a simple text adventure "framework" for the C64 written in BASIC. The idea is to "write" the adventure in XML files, run the included JAVA-based Converter tool, run the build.cmd in the build directory (sorry, Windows only for now but you should be able to modify it for another OS easily) and then play the game on the C64 by running it from the created d64 image file.

The XAM code itself is game-agnostic, i.e. it's just an interpreter for the game's data that has been converted from the XML files that actually describe the game. It expects the first room to be called start.rom, but other than that, it doesn't know anything about the actual game. Well, that's not entirely true...the code defines some static data structures (i.e. arrays) whose dimensions depend on the "size" of the game. One might have to adjust these depending on the game that the interpreter is supposed to run. I could have made the Converter tool modify the interpreter's code to match the game's requirements, but I couldn't be bothered.

XAM actually relies on being compiled with MOSpeed to run properly: https://github.com/EgonOlsen71/basicv2
The build script expects MOSpeed's dist-directory to be in the current path.
It will run in the interpreter as well, but very very slowly.

XAM comes with a full blown, german example adventure called Brotquest, which can be found in the build-directory as a d64 file.
