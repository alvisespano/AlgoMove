# AlgoMove
This is an evaluation repository for BCRA journal submission (30/6/2025).

Authors: Alvise Spanò, Lorenzo Benetollo, Michele Bugliesi, Silvia Crafa, Dalila Ressi, Sabina Rossi

# Other repos
AlgoMove is under active development at its official repository: [http://github.com/lollobene/AlgoMove]

# Installing the Aptos toolchain
AlgoMove relies on the Aptos toolchain, which include a full-blown Move compiler.
Install the Aptos CLI for testing AlgoMove [https://aptos.dev/en/build/cli]

# Installation and build
The AlgoMove Transpiler is a standalone program written in F# and needs the F# toolchain to be built. 
Multiple options exist: 
- get a free version of Microsoft Visual Studio (Community Edition) and open the AlgoMove.sln file included in this repository. Build the program and launch it from VS using the "play" button on top.
- get the F# plugin for Visual Studio Code and build/launch from there.
- under Linux, install the Mono toolchain and build the program manually.

# Testing AlgoMove
AlgoMove consists of two components: a *library* and a *transpiler* tool.
The AlgoMove Library is a library of Move modules that can be imported from your Move program in place of the standard library.
The AlgoMove Transpiler is the accompayning tool that parses disassembled Move-bytecode files and converts them into TEAL.

To use AlgoMove, write a Move program importing the AlgoMove Library modules you need and follow these steps:
- use the Aptos Move compiler to compile your Move program: 
	- `cd` to the program location and verify the folder is organized accordingly
	- type `aptos move compile`
	- this will compile all modules included in the `source` subfolder and put the bytecode into the `build/bytecode_modules` subfolder
	- Move source filed have extension `.move`
	- bytecode files generated by the compier have extension `.mv`
- use the Aptos Move *disassembler* to generate the disassembled bytedcode in a human-readable format that the AlgoMove Transpiler can parse:
	- type `aptos move disassemble --bytecode-path build/Traspiler/bytecode_modules/<FILENAME>.mv`
	- this will generate a `.mv.asm` file in the same folder as the original `.mv` file
	- disassembling involves one file at a time, not the whole folder, so repeat the process for every module you import from your _main_ module
- launch the AlgoMove Transpiler passing the `.mv.asm` file as argument
	- if launching from VS or VSC use the UI for setting the program argument to the desired filename
	- if launching from the shell, type `AlgoMoveTranspiler <FILENAME>.mv.asm`

The AlgoMove Transpiler will generate one single `.teal` file including all the code of the main module plus the imported modules, recursively translated and embedded in.
For this reason, the transpiler needs to find all the (recursively) imported modules proprely disassembled in the same folder.

# Example
Suppose you write a simple AlgoMove program consisting of one module.
The source file is `MyMain.move` and imports two AlgoMove modules (`algomove::asset` and `algomove::utils`).
You will need to compile, disassemble and copy the `.mv.asm` files of the whole AlgoMove Library to the folder where you will put the disassembled `MyMain.mv.asm` file of your module.
This because the transpiler needs all modules imported recursively in the same folder as the main module.

