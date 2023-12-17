2023 VC3
========

This is my entry to the [2023 Vintage Computing Christmas Challenge](https://logiker.com/Vintage-Computing-Christmas-Challenge-2023)
Total size in memory is 204 bytes.

It's written in z80 macro assembly (SjASMPlus) and targets the ZX Spectrum 48k, although other ZX Spectrums (including the NEXT) should work as well.
If you open in vscode, it'll prompt you to install DeZog which includes an emulator that's already setup. You'll need to change the path to the [sjasmplus](https://github.com/z00m128/sjasmplus/releases/tag/v1.20.3) executable in the tasks.json file then just build the default target.
You'll see a .sld and .sna appear and you can start debugging to run in the emulator.

Another option is to use [JSSpeccy3](https://jsspeccy.zxdemo.org). Hit the Open button and select vc3-2023.sna and it should load and run the program.

Theory of operation
-------------------
It's a pretty simple program optimized for size not speed. I'm using some routines written by Deam Belfield, to clear the screen and draw the characters in the correct place.

The coordinates of the border asterisks are stored as bytes in the stack area. There's some buffer above it to ensure we don't overwrite the code during routine calls.

Setup disables interrupts, loads the SP, and clears the screen.

The main loop copies the next coordinate from the stack, draws the line down and to the left, copies the coordinate again and draws the down and right line, and finally pops the coordinate and draw the line that's up and right. If we've hit the top of the stack, it's done and we halt, otherwise we loop and do it again.

