ffc0: cd ef     mov   x,#$ef
ffc2: bd        mov   sp,x
ffc3: e8 00     mov   a,#$00
ffc5: c6        mov   (x),a
ffc6: 1d        dec   x
ffc7: d0 fc     bne   $ffc5
ffc9: 8f aa f4  mov   $f4,#$aa
ffcc: 8f bb f5  mov   $f5,#$bb
ffcf: 78 cc f4  cmp   $f4,#$cc
ffd2: d0 fb     bne   $ffcf
ffd4: 2f 19     bra   $ffef
ffd6: eb f4     mov   y,$f4
ffd8: d0 fc     bne   $ffd6
ffda: 7e f4     cmp   y,$f4
ffdc: d0 0b     bne   $ffe9
ffde: e4 f5     mov   a,$f5
ffe0: cb f4     mov   $f4,y
ffe2: d7 00     mov   ($00)+y,a
ffe4: fc        inc   y
ffe5: d0 f3     bne   $ffda
ffe7: ab 01     inc   $01
ffe9: 10 ef     bpl   $ffda
ffeb: 7e f4     cmp   y,$f4
ffed: 10 eb     bpl   $ffda
ffef: ba f6     movw  ya,$f6
fff1: da 00     movw  $00,ya
fff3: ba f4     movw  ya,$f4
fff5: c4 f4     mov   $f4,a
fff7: dd        mov   a,y
fff8: 5d        mov   x,a
fff9: d0 db     bne   $ffd6
fffb: 1f 00 00  jmp   ($0000+x)
fffe: c0        di
ffff: ff        stop
