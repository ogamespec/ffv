// FFV. Bank C0:0000 ... C0:FFFF.

start ()    // C0:0000
{

}

Emulation_mode_RESET ()         // C0:CEC0
{
    SEI;        // Interrupt disable
    CLC;
    XCE;        // Native mode enabled

    goto start;
}

//
// SNES Header.
//

.C0:FFC0 46 49 4E 41+snes_header:    .BYTE 'FINAL FANTASY 5      ' ; Cartridge title
.C0:FFD5 21                          .BYTE $21 ; !           ; ROM Speed and Map Mode
.C0:FFD6 02                          .BYTE   2               ; Chipset - ROM+RAM+Battery
.C0:FFD7 0B                          .BYTE  $B               ; ROM size (1 SHL n) Kbytes
.C0:FFD8 03                          .BYTE   3               ; RAM size (1 SHL n) Kbytes
.C0:FFD9 00                          .BYTE   0               ; Country - International (eg. SGB) (any)
.C0:FFDA C3                          .BYTE $C3 ; +           ; Developer ID code
.C0:FFDB 00                          .BYTE   0               ; ROM Version number
.C0:FFDC 0D                          .BYTE  $D               ; Checksum complement
.C0:FFDD E0                          .BYTE $E0 ; р
.C0:FFDE F2                          .BYTE $F2 ; Є           ; Checksum
.C0:FFDF 1F                          .BYTE $1F

//
// Exception Vectors
//

.C0:FFE0 00 00                       .WORD 0                 ; WRAM Boot (unused)
.C0:FFE2 00 00                       .WORD 0
.C0:FFE4 00 00                       .WORD 0                 ; Native-mode COP
.C0:FFE6 00 00                       .WORD 0                 ; Native-mode BRK
.C0:FFE8 00 00                       .WORD 0                 ; Native-mode ABORT
.C0:FFEA E0 CE                       .WORD Native_mode_NMI   ; Native-mode NMI
.C0:FFEC 00 00                       .WORD 0                 ; Native-mode RESET
.C0:FFEE E4 CE                       .WORD Native_mode_IRQ   ; Native-mode IRQ
.C0:FFF0 00 00                       .WORD 0
.C0:FFF2 00 00                       .WORD 0
.C0:FFF4 00 00                       .WORD 0                 ; Emulation-mode COP
.C0:FFF6 00 00                       .WORD 0
.C0:FFF8 00 00                       .WORD 0                 ; Emulation-mode ABORT
.C0:FFFA 00 00                       .WORD 0                 ; Emulation-mode NMI
.C0:FFFC C0 CE                       .WORD Emulation_mode_RESET ; Emulation-mode RESET
.C0:FFFE 00 00                       .WORD 0                 ; Emulation-mode IRQ
