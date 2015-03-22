C2:4CE0 - [BattleLoop](BattleLoop.md)

```
00C2:0000 4C 03 00     jmp  0003
00C2:0003 08           push p
00C2:0004 C2 30        clr  p,30
00C2:0006ю8B           push db
00C2:0007 0B           push d
00C2:0008 48           push a
00C2:0009 DA           push x
00C2:000A 5A           push y
00C2:000B A9 00 00     mov  a,0000
00C2:000E E2 20        set  p,20
00C2:0010 C2 10        clr  p,10
00C2:0012 20 53 00     call 0053		(1)
00C2:0015 C2 20        clr  p,20
00C2:0017 18           clc
00C2:0018 AD C0 09     mov  a,[09C0]
00C2:001B 69 01 00     adc  a,0001
00C2:001E 90 03        jnc  0023
00C2:0020 A9 FF FF     mov  a,FFFF
00C2:0023 8D C0 09     mov  [09C0],a
00C2:0026 7B           mov  a,d
00C2:0027 E2 20        set  p,20
00C2:0029 9C D8 7C     mov  [7CD8],0
00C2:002C 20 E0 4C     call 4CE0		// BattleLoop
00C2:002F A9 00        mov  a,00
00C2:0031 8F 00 21 00  mov  [far 002100],a
00C2:0035 8F 0C 42 00  mov  [far 00420C],a
00C2:0039 8F 0B 42 00  mov  [far 00420B],a
00C2:003D 8F 00 42 00  mov  [far 004200],a
00C2:0041 AD D8 7C     mov  a,[7CD8]
00C2:0044 D0 E6        jnz  002C
00C2:0046 78           di
00C2:0047 20 53 00     call 0053		
00C2:004A C2 30        clr  p,30
00C2:004Cю7A           pop  y
00C2:004D FA           pop  x
00C2:004E 68           pop  a
00C2:004F 2B           pop  d
00C2:0050 AB           pop  db
00C2:0051 28           pop  p
00C2:0052 6B           retf

------------------------------------

(1)

00C2:0053 A9 00        mov  a,00
00C2:0055 48           push a
00C2:0056 AB           pop  db
00C2:0057 8D 00 42     mov  [4200],a
00C2:005A A2 00 00     mov  x,0000
00C2:005D DA           push x
00C2:005E 2B           pop  d
00C2:005F A9 80        mov  a,80
00C2:0061 8D 00 21     mov  [2100],a
00C2:0064 A9 7E        mov  a,7E
00C2:0066 48           push a
00C2:0067 AB           pop  db
00C2:0068 60           ret
```