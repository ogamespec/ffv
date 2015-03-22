Вызывается из start (где-то ближе к концу главного цикла).

C2:0000 - [BattleEngine](BattleEngine.md)

```
00C0:CCF0 A6 06        mov  x,[06]		// x = null
00C0:CCF2 8E A8 16     mov  [16A8],x		// [16A8] = null
00C0:CCF5 A9 6F        mov  a,6F
00C0:CCF7 20 3C 46     call 463C		// звук ВЖЖЖЖЖЖ (0x6F)
00C0:CCFA 20 DD CC     call CCDD		// Battle-effect мозаика
00C0:CCFD 9C 0B 42     mov  [420B],0		// Regular DMA Channel Enable = 0
00C0:CD00 9C 0C 42     mov  [420C],0		// H-DMA Channel Enable = 0
00C0:CD03 A9 00        mov  a,00
00C0:CD05 8D 00 42     mov  [4200],a		// NMI, V/H Count, and Joypad Enable = 0
00C0:CD08 A9 80        mov  a,80
00C0:CD0A 8D 00 21     mov  [2100],a		// Screen off
00C0:CD0D 78           di			// Disable IRQ
00C0:CD0E 22 00 00 C2  call far C20000		// Battle engine
00C0:CD12 20 E3 44     call 44E3

00C0:CD15 AD C4 09     mov  a,[09C4]		// Игрок проиграл ?
00C0:CD18 29 01        and  a,01
00C0:CD1A F0 08        jz   CD24
00C0:CD1C A9 F0        mov  a,F0		
00C0:CD1E 8D 00 1D     mov  [1D00],a
00C0:CD21 4C 00 00     jmp  0000		// Перейти на начало

00C0:CD24 AD 3B 01     mov  a,[013B]		// Loot (до 8 итемов)
00C0:CD27 0D 3C 01     or   a,[013C]
00C0:CD2A 0D 3D 01     or   a,[013D]
00C0:CD2D 0D 3E 01     or   a,[013E]
00C0:CD30 0D 3F 01     or   a,[013F]
00C0:CD33 0D 40 01     or   a,[0140]
00C0:CD36 0D 41 01     or   a,[0141]
00C0:CD39 0D 42 01     or   a,[0142]
00C0:CD3C F0 08        jz   CD46
00C0:CD3E A9 01        mov  a,01
00C0:CD40 8D 34 01     mov  [0134],a
00C0:CD43 20 4F 45     call 454F		// показать Loot-меню

00C0:CD46 20 D7 1C     call 1CD7		// такой же вызов вызывается при выходе из меню.
00C0:CD49 60           ret

----------------------------------------------------

Проиграть SFX начала битвы (A - номер звука)

00C0:463C 8D 01 1D     mov  [1D01],a
00C0:463F A9 02        mov  a,02
00C0:4641 8D 00 1D     mov  [1D00],a
00C0:4644 A9 0F        mov  a,0F
00C0:4646 8D 02 1D     mov  [1D02],a
00C0:4649 A9 88        mov  a,88
00C0:464B 8D 03 1D     mov  [1D03],a
00C0:464E 22 04 00 C4  call far C40004		// вызвать SFX-engine
00C0:4652 60           ret

----------------------------------------------------
```