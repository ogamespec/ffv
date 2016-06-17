// FFV SPC Program   ~55 subs, 18 are big

// SPC is working closely with DSP for audio playback

start ()        // 0x200
{
    P = 0;              // ZP = 0
    I = 0;
    SP = 0x1FF;

    //
    // Clear low RAM (except HW regs)
    //

    memset (0, 0, 0xF0);

    *(PUSHORT)0xeb = 0xFFFF;

    //
    // Reset DSP
    //

    DSP_Write (0xc, 0);
    DSP_Write (0x1c, 0);
    DSP_Write (0x2c, 0);
    DSP_Write (0x3c, 0);
    DSP_Write (0x2d, 0);
    DSP_Write (0x3d, 0);
    DSP_Write (0x4d, 0);
    DSP_Write (0x5d, 0x1b);

    //
    // Set 0x7, 0x17, 0x27, 0x37, 0x47, 0x57, 0x67, 0x77  DSP Regs to 0xa0
    //

    y = 7;
    while(1)
    {
        *(PUCHAR)0xf2 = y;
        *(PUCHAR)0xf3 = 0xa0;

        y = y + 0x10;
        if ( y >= 0x80 )
            break;
    }

    *(PUCHAR)0xf1 = 0xf0;           // CONTROL
    *(PUCHAR)0xfa = 0x24;       // T0TARGET
    *(PUCHAR)0xfb = 0x80;       // T1TARGET
    *(PUCHAR)0xf1 = 3;          // CONTROL

    sub_13c8 ();

    DSP_Write (0x6d, 0xd2);
    DSP_Write (0x7d, 5);

    //
    // Sleep a bit (Timer1)
    //

    a = 0x10;
    while (a--)
    {
        while ( *(PUCHAR)0xfe == 0 )  ;         // Wait T1OUT
    }

    DSP_Write (0xc, 0x7f);
    DSP_Write (0x1c, 0x7f);

    *(PUCHAR)0xbd = 0xff;
    *(PUCHAR)0xea = 7;

    *(PUCHAR)0x9c.7 = 1;
    *(PUCHAR)0x9e.7 = 1;
    *(PUCHAR)0xa8.7 = 1;
    *(PUCHAR)0xaa.7 = 1;

    //
    // SPC Main Loop
    //

    while(1)
    {
        //
        // 1
        //

        while (1)
        {
            sub_0d68 ();
            if (*(PUCHAR)0xfd != 0 )        // T0OUT
                break;
        }

        //
        // 2
        //

        y = 8;
        while(1)
        {
            *(PUCHAR)0xf2 = *(PUCHAR)(0x19df + y);
            x = *(PUCHAR)(0x19e7 + y);
            *(PUCHAR)0xf3 = *(PUCHAR)x; 

            y--;
            if ( y == 0 )
                break;
        }

        //
        // 3
        //

        *(PUCHAR)0xbd = 0;
        *(PUCHAR)0xbc = 0;
        if ( *(PUCHAR)0xbe.7 )
        {
            sub_1739 ();
        }
        else
        {
            *(PUSHORT)0xf6 = *(PUSHORT)0xb9;
            *(PUCHAR)0xf5 = *(PUCHAR)0xd1;
        }

        //
        // 4
        //

        if ( *(PUSHORT)0xd8 == 0 )
        {
            *(PUCHAR)0xea--;
            if ( *(PUCHAR)0xea == 0 )
            {
                *(PUCHAR)0xea = 7;
                sub_1790 ();
            }
        }

        //
        // 5
        //

        Sub_5 ();

        //
        // Entropy?  8 iterations
        //

        x = 0;
        *(PUCHAR)0xbf = 1;          // Mask
        a = *(PUCHAR)0xba;
        a |= *(PUCHAR)0xbb;
        a ^= 0xff;
        a &= *(PUCHAR)0xb9;
        *(PUCHAR)0x02 = a;

        while (1)
        {
            Carry = *(PUCHAR)0x02 & 1; 
            *(PUCHAR)0x02 >>= 1;
            if ( Carry )
            {
                *(PUCHAR)0x05 = x;
                sub_0b43 ();
            }

            x += 2;
            *(PUCHAR)0xbf <<= 1;
            if ( *(PUCHAR)0xbf == 0 )
                break;
        }

        //
        // Entropy 2 ?  4 iterations
        //

        x = 0x1e;
        *(PUCHAR)0xbf = 0x80;           // Mask
        a = *(PUCHAR)0xba;
        a |= *(PUCHAR)0xbb;
        *(PUCHAR)0x02 = a;

        while (1)
        {
            Carry = *(PUCHAR)0x02 >> 7;
            *(PUCHAR)0x02 <<= 1;
            if ( Carry )
            {
                *(PUCHAR)0x05 = x;
                sub_0b43 ();
            }

            x -= 2;
            *(PUCHAR)0xbf >>= 1;
            if ( *(PUCHAR)0xbf & 8 )        // Break on bit3 set
                break;
        }
    }
}

--------------------------------------------------------------------------------------

Sub_5 ()            // 0x304
{

}

0304: e4 9c     mov   a,$9c
0306: 48 80     eor   a,#$80
0308: eb 7d     mov   y,$7d
030a: cf        mul   ya
030b: dd        mov   a,y
030c: f3 9c 0a  bbc7  $9c,$0318
030f: 1c        asl   a
0310: 60        clrc
0311: 84 7d     adc   a,$7d
0313: 90 07     bcc   $031c
0315: e8 ff     mov   a,#$ff
0317: 2f 03     bra   $031c
0319: d0 01     bne   $031c
031b: bc        inc   a
031c: 60        clrc
031d: 84 7e     adc   a,$7e
031f: c4 7e     mov   $7e,a
0321: 33 be 01  bbc1  $be,$0324
0324: 80        setc
0325: 90 5c     bcc   $0383
0327: cd 00     mov   x,#$00
0329: 8f 01 bf  mov   $bf,#$01
032c: fa b9 02  mov   ($02),($b9)
032f: 4b 02     lsr   $02
0331: 90 32     bcc   $0365
0333: d8 05     mov   $05,x
0335: 9b 3c     dec   $3c+x
0337: d0 05     bne   $033e
0339: 3f e7 03  call  $03e7
033c: 2f 23     bra   $0361
033e: e4 ba     mov   a,$ba
0340: 04 bb     or    a,$bb
0342: 24 bf     and   a,$bf
0344: d0 1f     bne   $0365
0346: e8 02     mov   a,#$02
0348: de 3c 09  cbne  $3c+x,$0353
034b: e4 cf     mov   a,$cf
034d: 24 bf     and   a,$bf
034f: d0 03     bne   $0354
0351: 09 bf bd  or    ($bd),($bf)
0354: 40        setp
0355: f4 00     mov   a,$00+x
0357: f0 02     beq   $035b
0359: 9b 00     dec   $00+x
035b: f4 01     mov   a,$01+x
035d: f0 02     beq   $0361
035f: 9b 01     dec   $01+x
0361: 20        clrp
0362: 3f 62 0a  call  $0a62
0365: 3d        inc   x
0366: 3d        inc   x
0367: 0b bf     asl   $bf
0369: d0 c4     bne   $032f
036b: e4 80     mov   a,$80
036d: f0 08     beq   $0377
036f: 8b 80     dec   $80
0371: ba 81     movw  ya,$81
0373: 7a 7c     addw  ya,$7c
0375: da 7c     movw  $7c,ya
0377: e4 b7     mov   a,$b7
0379: f0 08     beq   $0383
037b: 8b b7     dec   $b7
037d: ba b5     movw  ya,$b5
037f: 7a b3     addw  ya,$b3
0381: da b3     movw  $b3,ya
0383: e4 9e     mov   a,$9e
0385: 48 80     eor   a,#$80
0387: 8d 78     mov   y,#$78
0389: cf        mul   ya
038a: dd        mov   a,y
038b: f3 9e 0a  bbc7  $9e,$0397
038e: 1c        asl   a
038f: 60        clrc
0390: 88 78     adc   a,#$78
0392: 90 07     bcc   $039b
0394: e8 ff     mov   a,#$ff
0396: 2f 03     bra   $039b
0398: d0 01     bne   $039b
039a: bc        inc   a
039b: 60        clrc
039c: 84 7f     adc   a,$7f
039e: c4 7f     mov   $7f,a
03a0: 33 be 01  bbc1  $be,$03a3
03a3: 80        setc
03a4: 90 40     bcc   $03e6
03a6: cd 18     mov   x,#$18
03a8: 8f 10 bf  mov   $bf,#$10
03ab: e4 ba     mov   a,$ba
03ad: 04 bb     or    a,$bb
03af: 9f        xcn   a
03b0: c4 02     mov   $02,a
03b2: 4b 02     lsr   $02
03b4: 90 2a     bcc   $03e0
03b6: d8 05     mov   $05,x
03b8: 9b 3c     dec   $3c+x
03ba: d0 05     bne   $03c1
03bc: 3f e7 03  call  $03e7
03bf: 2f 1b     bra   $03dc
03c1: e8 02     mov   a,#$02
03c3: de 3c 09  cbne  $3c+x,$03ce
03c6: e4 d0     mov   a,$d0
03c8: 24 bf     and   a,$bf
03ca: d0 03     bne   $03cf
03cc: 09 bf bd  or    ($bd),($bf)
03cf: 40        setp
03d0: f4 00     mov   a,$00+x
03d2: f0 02     beq   $03d6
03d4: 9b 00     dec   $00+x
03d6: f4 01     mov   a,$01+x
03d8: f0 02     beq   $03dc
03da: 9b 01     dec   $01+x
03dc: 20        clrp
03dd: 3f 62 0a  call  $0a62
03e0: 3d        inc   x
03e1: 3d        inc   x
03e2: 0b bf     asl   $bf
03e4: d0 cc     bne   $03b2
03e6: 6f        ret

--------------------------------------------------------------------------------------

03e7: 3f 9c 05  call  $059c
03ea: 68 d2     cmp   a,#$d2
03ec: 90 05     bcc   $03f3
03ee: 3f 88 05  call  $0588
03f1: 2f f4     bra   $03e7
03f3: 8d 00     mov   y,#$00
03f5: cd 0f     mov   x,#$0f
03f7: 9e        div   ya,x
03f8: f8 05     mov   x,$05
03fa: f6 2f 19  mov   a,$192f+y
03fd: d4 3c     mov   $3c+x,a
03ff: 3f a7 05  call  $05a7
0402: 78 b4 04  cmp   $04,#$b4
0405: 90 09     bcc   $0410
0407: 78 c3 04  cmp   $04,#$c3
040a: b0 03     bcs   $040f
040c: 5f bf 04  jmp   $04bf
040f: 6f        ret


0410: c8 10     cmp   x,#$10
0412: b0 08     bcs   $041c
0414: e4 ba     mov   a,$ba
0416: 04 bb     or    a,$bb
0418: 24 bf     and   a,$bf
041a: d0 f3     bne   $040f
041c: e4 04     mov   a,$04
041e: 8d 00     mov   y,#$00
0420: cd 0f     mov   x,#$0f
0422: 9e        div   ya,x
0423: c4 04     mov   $04,a
0425: f8 05     mov   x,$05
0427: f4 3d     mov   a,$3d+x
0429: 8d 0c     mov   y,#$0c
042b: cf        mul   ya
042c: 60        clrc
042d: 84 04     adc   a,$04
042f: 60        clrc
0430: 95 61 fb  adc   a,$fb61+x
0433: 80        setc
0434: a8 0a     sbc   a,#$0a
0436: d5 41 fb  mov   $fb41+x,a
0439: 3f 27 05  call  $0527
043c: e4 08     mov   a,$08
043e: d5 60 fc  mov   $fc60+x,a
0441: e4 09     mov   a,$09
0443: d5 61 fc  mov   $fc61+x,a
0446: 8d 07     mov   y,#$07
0448: f5 21 01  mov   a,$0121+x
044b: f0 22     beq   $046f
044d: 68 c0     cmp   a,#$c0
044f: b0 04     bcs   $0455
0451: e8 00     mov   a,#$00
0453: 2f 02     bra   $0457
0455: e8 80     mov   a,#$80
0457: d5 c0 fb  mov   $fbc0+x,a
045a: e8 01     mov   a,#$01
045c: d5 e0 fa  mov   $fae0+x,a
045f: f5 60 01  mov   a,$0160+x
0462: d5 00 01  mov   $0100+x,a
0465: f0 03     beq   $046a
0467: dd        mov   a,y
0468: 2f 02     bra   $046c
046a: e8 00     mov   a,#$00
046c: d5 00 fc  mov   $fc00+x,a
046f: f5 40 01  mov   a,$0140+x
0472: f0 24     beq   $0498
0474: 68 c0     cmp   a,#$c0
0476: b0 04     bcs   $047c
0478: e8 00     mov   a,#$00
047a: 2f 02     bra   $047e
047c: e8 80     mov   a,#$80
047e: d5 c1 fb  mov   $fbc1+x,a
0481: e8 01     mov   a,#$01
0483: d5 e1 fa  mov   $fae1+x,a
0486: f5 61 01  mov   a,$0161+x
0489: d5 01 01  mov   $0101+x,a
048c: f0 03     beq   $0491
048e: dd        mov   a,y
048f: 2f 02     bra   $0493
0491: e8 00     mov   a,#$00
0493: d5 01 fc  mov   $fc01+x,a
0496: e8 00     mov   a,#$00
0498: d5 40 fc  mov   $fc40+x,a
049b: d5 41 fc  mov   $fc41+x,a
049e: d5 01 fb  mov   $fb01+x,a
04a1: d5 80 fb  mov   $fb80+x,a
04a4: d5 81 fb  mov   $fb81+x,a
04a7: c8 10     cmp   x,#$10
04a9: b0 08     bcs   $04b3
04ab: e4 ba     mov   a,$ba
04ad: 04 bb     or    a,$bb
04af: 24 bf     and   a,$bf
04b1: d0 0c     bne   $04bf
04b3: 09 bf d6  or    ($d6),($bf)
04b6: 09 bf d7  or    ($d7),($bf)
04b9: 09 bf bc  or    ($bc),($bf)
04bc: 3f 12 09  call  $0912


04bf: f5 20 01  mov   a,$0120+x
04c2: f0 62     beq   $0526
04c4: 60        clrc
04c5: 95 41 fb  adc   a,$fb41+x
04c8: d5 41 fb  mov   $fb41+x,a
04cb: 3f 27 05  call  $0527
04ce: f5 60 fc  mov   a,$fc60+x
04d1: c4 34     mov   $34,a
04d3: f5 61 fc  mov   a,$fc61+x
04d6: c4 35     mov   $35,a
04d8: ba 08     movw  ya,$08
04da: 80        setc
04db: 9a 34     subw  ya,$34
04dd: da 34     movw  $34,ya
04df: 0d        push  psw
04e0: b0 08     bcs   $04ea
04e2: 58 ff 34  eor   $34,#$ff
04e5: 58 ff 35  eor   $35,#$ff
04e8: 3a 34     incw  $34
04ea: f5 c1 fa  mov   a,$fac1+x
04ed: d0 08     bne   $04f7
04ef: fa 35 34  mov   ($34),($35)
04f2: 8f 00 35  mov   $35,#$00
04f5: 2f 0d     bra   $0504
04f7: 5d        mov   x,a
04f8: e4 35     mov   a,$35
04fa: 8d 00     mov   y,#$00
04fc: 9e        div   ya,x
04fd: c4 35     mov   $35,a
04ff: e4 34     mov   a,$34
0501: 9e        div   ya,x
0502: c4 34     mov   $34,a
0504: ba 34     movw  ya,$34
0506: d0 02     bne   $050a
0508: ab 34     inc   $34
050a: 8e        pop   psw
050b: b0 08     bcs   $0515
050d: 58 ff 34  eor   $34,#$ff
0510: 58 ff 35  eor   $35,#$ff
0513: 3a 34     incw  $34
0515: f8 05     mov   x,$05
0517: e4 34     mov   a,$34
0519: d5 80 fb  mov   $fb80+x,a
051c: e4 35     mov   a,$35
051e: d5 81 fb  mov   $fb81+x,a
0521: e8 00     mov   a,#$00
0523: d5 20 01  mov   $0120+x,a
0526: 6f        ret

----------------------------------------------------------------------------

0527: cd 0c     mov   x,#$0c
0529: 8d 00     mov   y,#$00
052b: 9e        div   ya,x
052c: f8 05     mov   x,$05
052e: c4 03     mov   $03,a
0530: dd        mov   a,y
0531: 1c        asl   a
0532: fd        mov   y,a
0533: f6 f5 18  mov   a,$18f5+y
0536: c4 0a     mov   $0a,a
0538: f6 f6 18  mov   a,$18f6+y
053b: c4 0b     mov   $0b,a
053d: fd        mov   y,a
053e: f5 20 fb  mov   a,$fb20+x
0541: 60        clrc
0542: 95 40 fb  adc   a,$fb40+x
0545: 0d        push  psw
0546: 2d        push  a
0547: cf        mul   ya
0548: da 08     movw  $08,ya
054a: eb 0a     mov   y,$0a
054c: ae        pop   a
054d: cf        mul   ya
054e: dd        mov   a,y
054f: 8d 00     mov   y,#$00
0551: 7a 08     addw  ya,$08
0553: da 08     movw  $08,ya
0555: f5 21 fb  mov   a,$fb21+x
0558: f0 08     beq   $0562
055a: cf        mul   ya
055b: dd        mov   a,y
055c: 8d 00     mov   y,#$00
055e: 7a 08     addw  ya,$08
0560: 2f 02     bra   $0564
0562: e4 08     mov   a,$08
0564: 8e        pop   psw
0565: 30 02     bmi   $0569
0567: 7a 0a     addw  ya,$0a
0569: da 08     movw  $08,ya
056b: e8 04     mov   a,#$04
056d: eb 03     mov   y,$03
056f: 30 0e     bmi   $057f
0571: 64 03     cmp   a,$03
0573: b0 0f     bcs   $0584
0575: 0b 08     asl   $08
0577: 2b 09     rol   $09
0579: bc        inc   a
057a: 2e 03 f8  cbne  $03,$0574
057d: 2f 08     bra   $0587
057f: 4b 09     lsr   $09
0581: 6b 08     ror   $08
0583: 9c        dec   a
0584: 2e 03 f8  cbne  $03,$057e
0587: 6f        ret

--------------------------------------------------------------------------------------

0588: a8 d2     sbc   a,#$d2
058a: 1c        asl   a
058b: fd        mov   y,a
058c: f6 2c 18  mov   a,$182c+y
058f: 2d        push  a
0590: f6 2b 18  mov   a,$182b+y
0593: 2d        push  a
0594: dd        mov   a,y
0595: 5c        lsr   a
0596: fd        mov   y,a
0597: f6 87 18  mov   a,$1887+y
059a: f0 0a     beq   $05a6
059c: e7 0c     mov   a,($0c+x)
059e: c4 04     mov   $04,a
05a0: bb 0c     inc   $0c+x
05a2: d0 02     bne   $05a6
05a4: bb 0d     inc   $0d+x
05a6: 6f        ret

--------------------------------------------------------------------------------------

05a7: f4 0c     mov   a,$0c+x
05a9: fb 0d     mov   y,$0d+x
05ab: da 2c     movw  $2c,ya
05ad: f4 5c     mov   a,$5c+x
05af: c4 ed     mov   $ed,a
05b1: 8d 00     mov   y,#$00
05b3: f7 2c     mov   a,($2c)+y
05b5: 68 d2     cmp   a,#$d2
05b7: 90 76     bcc   $062f
05b9: 3a 2c     incw  $2c
05bb: 68 f2     cmp   a,#$f2
05bd: f0 70     beq   $062f
05bf: 68 fa     cmp   a,#$fa
05c1: d0 0e     bne   $05d1
05c3: f7 2c     mov   a,($2c)+y
05c5: 2d        push  a
05c6: fc        inc   y
05c7: f7 2c     mov   a,($2c)+y
05c9: fd        mov   y,a
05ca: ae        pop   a
05cb: 7a 06     addw  ya,$06
05cd: da 2c     movw  $2c,ya
05cf: 2f e0     bra   $05b1
05d1: 68 f1     cmp   a,#$f1
05d3: d0 27     bne   $05fc
05d5: eb ed     mov   y,$ed
05d7: f6 c0 fc  mov   a,$fcc0+y
05da: f0 11     beq   $05ed
05dc: 9c        dec   a
05dd: d0 0e     bne   $05ed
05df: 8b ed     dec   $ed
05e1: 7d        mov   a,x
05e2: 1c        asl   a
05e3: 9c        dec   a
05e4: 2e ed ca  cbne  $ed,$05b0
05e7: 60        clrc
05e8: 98 04 ed  adc   $ed,#$04
05eb: 2f c4     bra   $05b1
05ed: dd        mov   a,y
05ee: 1c        asl   a
05ef: fd        mov   y,a
05f0: f6 00 fd  mov   a,$fd00+y
05f3: c4 2c     mov   $2c,a
05f5: f6 01 fd  mov   a,$fd01+y
05f8: c4 2d     mov   $2d,a
05fa: 2f b5     bra   $05b1
05fc: 68 f9     cmp   a,#$f9
05fe: d0 11     bne   $0611
0600: eb ed     mov   y,$ed
0602: f6 a0 fc  mov   a,$fca0+y
0605: bc        inc   a
0606: 77 2c     cmp   a,($2c)+y
0608: d0 03     bne   $060d
060a: fc        inc   y
060b: 2f b6     bra   $05c3
060d: 8d 03     mov   y,#$03
060f: 2f 18     bra   $0629
0611: 68 fb     cmp   a,#$fb
0613: d0 0a     bne   $061f
0615: e4 bf     mov   a,$bf
0617: 24 d1     and   a,$d1
0619: d0 a8     bne   $05c3
061b: 8d 02     mov   y,#$02
061d: 2f 0a     bra   $0629
061f: 80        setc
0620: a8 d2     sbc   a,#$d2
0622: fd        mov   y,a
0623: f6 87 18  mov   a,$1887+y
0626: f0 89     beq   $05b1
0628: fd        mov   y,a
0629: 3a 2c     incw  $2c
062b: fe fc     dbnz  y,$0629
062d: 2f 84     bra   $05b3
062f: fd        mov   y,a
0630: e4 bf     mov   a,$bf
0632: ad c3     cmp   y,#$c3
0634: b0 12     bcs   $0648
0636: ad b4     cmp   y,#$b4
0638: 90 0e     bcc   $0648
063a: c8 10     cmp   x,#$10
063c: b0 05     bcs   $0643
063e: 0e cf 00  tset1 $00cf
0641: 2f 11     bra   $0654
0643: 0e d0 00  tset1 $00d0
0646: 2f 0c     bra   $0654
0648: c8 10     cmp   x,#$10
064a: b0 05     bcs   $0651
064c: 4e cf 00  tclr1 $00cf
064f: 2f 03     bra   $0654
0651: 4e d0 00  tclr1 $00d0
0654: 6f        ret

--------------------------------------------------------------------------------------

DSP_Write (y, a)            // 0x0655
{
    *(PUCHAR)0xf2 = y;
    *(PUCHAR)0xf2 = a;
}

--------------------------------------------------------------------------------------

065a: c8 10     cmp   x,#$10
065c: b0 08     bcs   $0666
065e: c4 7d     mov   $7d,a
0660: e8 00     mov   a,#$00
0662: c4 7c     mov   $7c,a
0664: c4 80     mov   $80,a
0666: 6f        ret

--------------------------------------------------------------------------------------

0667: c4 80     mov   $80,a
0669: 3f 9c 05  call  $059c
066c: c8 10     cmp   x,#$10
066e: b0 2e     bcs   $069e
0670: eb 80     mov   y,$80
0672: f0 e6     beq   $065a
0674: 80        setc
0675: a4 7d     sbc   a,$7d
0677: f0 eb     beq   $0664
0679: 0d        push  psw
067a: b0 03     bcs   $067f
067c: 48 ff     eor   a,#$ff
067e: bc        inc   a
067f: f8 80     mov   x,$80
0681: 8d 00     mov   y,#$00
0683: 9e        div   ya,x
0684: c4 35     mov   $35,a
0686: e8 00     mov   a,#$00
0688: 9e        div   ya,x
0689: c4 34     mov   $34,a
068b: f8 05     mov   x,$05
068d: 8e        pop   psw
068e: b0 08     bcs   $0698
0690: 58 ff 34  eor   $34,#$ff
0693: 58 ff 35  eor   $35,#$ff
0696: 3a 34     incw  $34
0698: ba 34     movw  ya,$34
069a: c4 81     mov   $81,a
069c: cb 82     mov   $82,y
069e: 6f        ret

--------------------------------------------------------------------------------------

069f: c4 b8     mov   $b8,a
06a1: 6f        ret

--------------------------------------------------------------------------------------

06a2: d5 01 fa  mov   $fa01+x,a
06a5: e8 00     mov   a,#$00
06a7: d5 00 fa  mov   $fa00+x,a
06aa: d5 80 fa  mov   $fa80+x,a
06ad: 6f        ret

--------------------------------------------------------------------------------------


06ae: c4 34     mov   $34,a
06b0: d5 80 fa  mov   $fa80+x,a
06b3: 3f 9c 05  call  $059c
06b6: eb 34     mov   y,$34
06b8: f0 e8     beq   $06a2
06ba: 80        setc
06bb: b5 01 fa  sbc   a,$fa01+x
06be: f0 ea     beq   $06aa
06c0: 0d        push  psw
06c1: b0 03     bcs   $06c6
06c3: 48 ff     eor   a,#$ff
06c5: bc        inc   a
06c6: f8 34     mov   x,$34
06c8: 8d 00     mov   y,#$00
06ca: 9e        div   ya,x
06cb: c4 35     mov   $35,a
06cd: e8 00     mov   a,#$00
06cf: 9e        div   ya,x
06d0: c4 34     mov   $34,a
06d2: f8 05     mov   x,$05
06d4: 8e        pop   psw
06d5: b0 08     bcs   $06df
06d7: 58 ff 34  eor   $34,#$ff
06da: 58 ff 35  eor   $35,#$ff
06dd: 3a 34     incw  $34
06df: e4 34     mov   a,$34
06e1: d5 20 fa  mov   $fa20+x,a
06e4: e4 35     mov   a,$35
06e6: d5 21 fa  mov   $fa21+x,a
06e9: 6f        ret

--------------------------------------------------------------------------------------

06ea: c8 10     cmp   x,#$10
06ec: b0 08     bcs   $06f6
06ee: 5c        lsr   a
06ef: c4 b4     mov   $b4,a
06f1: 8f 00 b3  mov   $b3,#$00
06f4: c4 b7     mov   $b7,a
06f6: 6f        ret

--------------------------------------------------------------------------------------


06f7: c4 b7     mov   $b7,a
06f9: 3f 9c 05  call  $059c
06fc: c8 10     cmp   x,#$10
06fe: b0 2f     bcs   $072f
0700: eb b7     mov   y,$b7
0702: f0 e6     beq   $06ea
0704: 5c        lsr   a
0705: 80        setc
0706: a4 b4     sbc   a,$b4
0708: f0 ea     beq   $06f4
070a: 0d        push  psw
070b: b0 03     bcs   $0710
070d: 48 ff     eor   a,#$ff
070f: bc        inc   a
0710: f8 b7     mov   x,$b7
0712: 8d 00     mov   y,#$00
0714: 9e        div   ya,x
0715: c4 35     mov   $35,a
0717: e8 00     mov   a,#$00
0719: 9e        div   ya,x
071a: c4 34     mov   $34,a
071c: f8 05     mov   x,$05
071e: 8e        pop   psw
071f: b0 08     bcs   $0729
0721: 58 ff 34  eor   $34,#$ff
0724: 58 ff 35  eor   $35,#$ff
0727: 3a 34     incw  $34
0729: ba 34     movw  ya,$34
072b: c4 b5     mov   $b5,a
072d: cb b6     mov   $b6,y
072f: 6f        ret

--------------------------------------------------------------------------------------

0730: d5 41 fa  mov   $fa41+x,a
0733: e8 00     mov   a,#$00
0735: d5 40 fa  mov   $fa40+x,a
0738: d5 81 fa  mov   $fa81+x,a
073b: 6f        ret
073c: c4 34     mov   $34,a
073e: d5 81 fa  mov   $fa81+x,a
0741: 3f 9c 05  call  $059c
0744: eb 34     mov   y,$34
0746: f0 e8     beq   $0730
0748: 80        setc
0749: b5 41 fa  sbc   a,$fa41+x
074c: f0 ea     beq   $0738
074e: 0d        push  psw
074f: b0 03     bcs   $0754
0751: 48 ff     eor   a,#$ff
0753: bc        inc   a
0754: f8 34     mov   x,$34
0756: 8d 00     mov   y,#$00
0758: 9e        div   ya,x
0759: c4 35     mov   $35,a
075b: e8 00     mov   a,#$00
075d: 9e        div   ya,x
075e: c4 34     mov   $34,a
0760: f8 05     mov   x,$05
0762: 8e        pop   psw
0763: b0 08     bcs   $076d
0765: 58 ff 34  eor   $34,#$ff
0768: 58 ff 35  eor   $35,#$ff
076b: 3a 34     incw  $34
076d: e4 34     mov   a,$34
076f: d5 60 fa  mov   $fa60+x,a
0772: e4 35     mov   a,$35
0774: d5 61 fa  mov   $fa61+x,a
0777: 6f        ret

--------------------------------------------------------------------------------------

0778: bc        inc   a
0779: d5 c1 fa  mov   $fac1+x,a
077c: 3f 9c 05  call  $059c
077f: d5 20 01  mov   $0120+x,a
0782: 6f        ret

--------------------------------------------------------------------------------------

0783: 60        clrc
0784: 95 61 fb  adc   a,$fb61+x
0787: d5 61 fb  mov   $fb61+x,a
078a: 6f        ret

--------------------------------------------------------------------------------------

078b: c4 d5     mov   $d5,a
078d: 3f 9c 05  call  $059c
0790: c8 10     cmp   x,#$10
0792: 90 01     bcc   $0795
0794: 6f        ret

--------------------------------------------------------------------------------------


0795: 28 03     and   a,#$03
0797: c4 d4     mov   $d4,a
0799: 1c        asl   a
079a: 1c        asl   a
079b: 1c        asl   a
079c: fd        mov   y,a
079d: cd 0f     mov   x,#$0f
079f: f6 0f 19  mov   a,$190f+y
07a2: d8 f2     mov   $f2,x
07a4: c4 f3     mov   $f3,a
07a6: fc        inc   y
07a7: 7d        mov   a,x
07a8: 60        clrc
07a9: 88 10     adc   a,#$10
07ab: 5d        mov   x,a
07ac: 10 f1     bpl   $079f
07ae: f8 05     mov   x,$05
07b0: 8d 0d     mov   y,#$0d
07b2: e4 d5     mov   a,$d5
07b4: 5f 55 06  jmp   DSP_Write

--------------------------------------------------------------------------------------

07b7: d5 60 01  mov   $0160+x,a
07ba: 3f 9c 05  call  $059c
07bd: bc        inc   a
07be: d5 a0 fa  mov   $faa0+x,a
07c1: e8 01     mov   a,#$01
07c3: d5 e0 fa  mov   $fae0+x,a
07c6: 3f 9c 05  call  $059c
07c9: d5 21 01  mov   $0121+x,a
07cc: 6f        ret

--------------------------------------------------------------------------------------

07cd: d5 61 01  mov   $0161+x,a
07d0: 3f 9c 05  call  $059c
07d3: bc        inc   a
07d4: d5 a1 fa  mov   $faa1+x,a
07d7: e8 01     mov   a,#$01
07d9: d5 e1 fa  mov   $fae1+x,a
07dc: 3f 9c 05  call  $059c
07df: d5 40 01  mov   $0140+x,a
07e2: 6f        ret

--------------------------------------------------------------------------------------

07e3: 60        clrc
07e4: bc        inc   a
07e5: d5 c0 fa  mov   $fac0+x,a
07e8: d0 01     bne   $07eb
07ea: 80        setc
07eb: 7c        ror   a
07ec: d0 01     bne   $07ef
07ee: bc        inc   a
07ef: d5 00 fb  mov   $fb00+x,a
07f2: fd        mov   y,a
07f3: 3f 9c 05  call  $059c
07f6: 1c        asl   a
07f7: e4 04     mov   a,$04
07f9: 28 7f     and   a,#$7f
07fb: 90 02     bcc   $07ff
07fd: 48 7f     eor   a,#$7f
07ff: c4 34     mov   $34,a
0801: dd        mov   a,y
0802: 10 05     bpl   $0809
0804: 8f 00 35  mov   $35,#$00
0807: 2f 13     bra   $081c
0809: 5d        mov   x,a
080a: 8d 00     mov   y,#$00
080c: e4 34     mov   a,$34
080e: 9e        div   ya,x
080f: c4 35     mov   $35,a
0811: e8 00     mov   a,#$00
0813: 9e        div   ya,x
0814: c4 34     mov   $34,a
0816: ba 34     movw  ya,$34
0818: d0 02     bne   $081c
081a: ab 34     inc   $34
081c: 90 08     bcc   $0826
081e: 58 ff 34  eor   $34,#$ff
0821: 58 ff 35  eor   $35,#$ff
0824: 3a 34     incw  $34
0826: f8 05     mov   x,$05
0828: e4 34     mov   a,$34
082a: d5 a0 fb  mov   $fba0+x,a
082d: e4 35     mov   a,$35
082f: d5 a1 fb  mov   $fba1+x,a
0832: e4 04     mov   a,$04
0834: d5 41 01  mov   $0141+x,a
0837: e8 00     mov   a,#$00
0839: d5 e0 fb  mov   $fbe0+x,a
083c: d5 e1 fb  mov   $fbe1+x,a
083f: 6f        ret

--------------------------------------------------------------------------------------

0840: f5 3d 00  mov   a,$003d+x
0843: bc        inc   a
0844: 2f 04     bra   $084a
0846: f5 3d 00  mov   a,$003d+x
0849: 9c        dec   a
084a: d5 3d 00  mov   $003d+x,a
084d: 6f        ret

--------------------------------------------------------------------------------------

084e: c8 10     cmp   x,#$10
0850: b0 05     bcs   $0857
0852: 09 bf c9  or    ($c9),($bf)
0855: 2f 03     bra   $085a
0857: 09 bf ca  or    ($ca),($bf)
085a: e4 ba     mov   a,$ba
085c: 04 bb     or    a,$bb
085e: 48 ff     eor   a,#$ff
0860: 24 c9     and   a,$c9
0862: 04 ca     or    a,$ca
0864: c4 c5     mov   $c5,a
0866: 6f        ret

--------------------------------------------------------------------------------------

0867: e4 bf     mov   a,$bf
0869: c8 10     cmp   x,#$10
086b: b0 05     bcs   $0872
086d: 4e c9 00  tclr1 $00c9
0870: 2f e8     bra   $085a
0872: 4e ca 00  tclr1 $00ca
0875: 2f e3     bra   $085a
0877: c8 10     cmp   x,#$10
0879: b0 05     bcs   $0880
087b: 09 bf cb  or    ($cb),($bf)
087e: 2f 05     bra   $0885
0880: 09 bf cc  or    ($cc),($bf)
0883: 02 cc     set0  $cc
0885: fa cc 34  mov   ($34),($cc)
0888: 12 34     clr0  $34
088a: e4 c8     mov   a,$c8
088c: 28 e0     and   a,#$e0
088e: 03 cc 04  bbs0  $cc,$0894
0891: 04 d2     or    a,$d2
0893: 2f 02     bra   $0897
0895: 04 d3     or    a,$d3
0897: c4 c8     mov   $c8,a
0899: e4 ba     mov   a,$ba
089b: 04 bb     or    a,$bb
089d: 48 ff     eor   a,#$ff
089f: 24 cb     and   a,$cb
08a1: 04 34     or    a,$34
08a3: c4 c6     mov   $c6,a
08a5: 6f        ret

--------------------------------------------------------------------------------------

08a6: e4 bf     mov   a,$bf
08a8: c8 10     cmp   x,#$10
08aa: b0 05     bcs   $08b1
08ac: 4e cb 00  tclr1 $00cb
08af: 2f d4     bra   $0885
08b1: 4e cc 00  tclr1 $00cc
08b4: e4 cc     mov   a,$cc
08b6: 28 f0     and   a,#$f0
08b8: d0 cb     bne   $0885
08ba: 12 cc     clr0  $cc
08bc: 2f c7     bra   $0885
08be: 28 1f     and   a,#$1f
08c0: c8 10     cmp   x,#$10
08c2: b0 04     bcs   $08c8
08c4: c4 d2     mov   $d2,a
08c6: 2f bd     bra   $0885
08c8: c4 d3     mov   $d3,a
08ca: 2f b9     bra   $0885
08cc: c8 10     cmp   x,#$10
08ce: b0 05     bcs   $08d5
08d0: 09 bf cd  or    ($cd),($bf)
08d3: 2f 03     bra   $08d8
08d5: 09 bf ce  or    ($ce),($bf)
08d8: e4 ba     mov   a,$ba
08da: 04 bb     or    a,$bb
08dc: 48 ff     eor   a,#$ff
08de: 24 cd     and   a,$cd
08e0: 04 ce     or    a,$ce
08e2: c4 c7     mov   $c7,a
08e4: 6f        ret

--------------------------------------------------------------------------------------

08e5: e4 bf     mov   a,$bf
08e7: c8 10     cmp   x,#$10
08e9: b0 05     bcs   $08f0
08eb: 4e cd 00  tclr1 $00cd
08ee: 2f e8     bra   $08d8
08f0: 4e ce 00  tclr1 $00ce
08f3: 2f e3     bra   $08d8
08f5: d4 5d     mov   $5d+x,a
08f7: 1c        asl   a
08f8: fd        mov   y,a
08f9: f6 00 1a  mov   a,$1a00+y
08fc: d5 20 fb  mov   $fb20+x,a
08ff: f6 01 1a  mov   a,$1a01+y
0902: d5 21 fb  mov   $fb21+x,a
0905: f6 80 1a  mov   a,$1a80+y
0908: d5 80 fc  mov   $fc80+x,a
090b: f6 81 1a  mov   a,$1a81+y
090e: d5 81 fc  mov   $fc81+x,a
0911: 6f        ret

--------------------------------------------------------------------------------------

0912: fb 5d     mov   y,$5d+x
0914: 7d        mov   a,x
0915: 9f        xcn   a
0916: 5c        lsr   a
0917: 08 04     or    a,#$04
0919: c4 f2     mov   $f2,a
091b: cb f3     mov   $f3,y
091d: 2f 10     bra   $092f
091f: 28 0f     and   a,#$0f
0921: c4 04     mov   $04,a
0923: f5 80 fc  mov   a,$fc80+x
0926: 28 70     and   a,#$70
0928: 04 04     or    a,$04
092a: 08 80     or    a,#$80
092c: d5 80 fc  mov   $fc80+x,a
092f: c8 10     cmp   x,#$10
0931: b0 09     bcs   $093c
0933: e4 ba     mov   a,$ba
0935: 04 bb     or    a,$bb
0937: 24 bf     and   a,$bf
0939: f0 01     beq   $093c
093b: 6f        ret

--------------------------------------------------------------------------------------

093c: 7d        mov   a,x
093d: 9f        xcn   a
093e: 5c        lsr   a
093f: 08 05     or    a,#$05
0941: fd        mov   y,a
0942: f5 80 fc  mov   a,$fc80+x
0945: 3f 55 06  call  DSP_Write
0948: fc        inc   y
0949: f5 81 fc  mov   a,$fc81+x
094c: 5f 55 06  jmp   DSP_Write

--------------------------------------------------------------------------------------

094f: 28 07     and   a,#$07
0951: 9f        xcn   a
0952: c4 04     mov   $04,a
0954: f5 80 fc  mov   a,$fc80+x
0957: 28 0f     and   a,#$0f
0959: 04 04     or    a,$04
095b: 08 80     or    a,#$80
095d: d5 80 fc  mov   $fc80+x,a
0960: 2f cd     bra   $092f
0962: 28 07     and   a,#$07
0964: 9f        xcn   a
0965: 1c        asl   a
0966: c4 04     mov   $04,a
0968: f5 81 fc  mov   a,$fc81+x
096b: 28 1f     and   a,#$1f
096d: 04 04     or    a,$04
096f: d5 81 fc  mov   $fc81+x,a
0972: 2f bb     bra   $092f
0974: 28 1f     and   a,#$1f
0976: c4 04     mov   $04,a
0978: f5 81 fc  mov   a,$fc81+x
097b: 28 e0     and   a,#$e0
097d: 04 04     or    a,$04
097f: d5 81 fc  mov   $fc81+x,a
0982: 2f ab     bra   $092f
0984: f4 5d     mov   a,$5d+x
0986: 1c        asl   a
0987: fd        mov   y,a
0988: f6 80 1a  mov   a,$1a80+y
098b: d5 80 fc  mov   $fc80+x,a
098e: f6 81 1a  mov   a,$1a81+y
0991: d5 81 fc  mov   $fc81+x,a
0994: 2f 99     bra   $092f
0996: fd        mov   y,a
0997: 3f 9c 05  call  $059c
099a: c8 10     cmp   x,#$10
099c: b0 09     bcs   $09a7
099e: dd        mov   a,y
099f: eb 04     mov   y,$04
09a1: 7a 06     addw  ya,$06
09a3: d4 0c     mov   $0c+x,a
09a5: db 0d     mov   $0d+x,y
09a7: 6f        ret

------------------------------------------------------------------------------------

09a8: c4 36     mov   $36,a
09aa: 3f 9c 05  call  $059c
09ad: c4 34     mov   $34,a
09af: 3f 9c 05  call  $059c
09b2: c4 35     mov   $35,a
09b4: c8 10     cmp   x,#$10
09b6: b0 14     bcs   $09cc
09b8: fb 5c     mov   y,$5c+x
09ba: f6 a0 fc  mov   a,$fca0+y
09bd: bc        inc   a
09be: d6 a0 fc  mov   $fca0+y,a
09c1: 2e 36 08  cbne  $36,$09cb
09c4: ba 34     movw  ya,$34
09c6: 7a 06     addw  ya,$06
09c8: d4 0c     mov   $0c+x,a
09ca: db 0d     mov   $0d+x,y
09cc: 6f        ret

--------------------------------------------------------------------------------------

09cd: bb 5c     inc   $5c+x
09cf: 7d        mov   a,x
09d0: 1c        asl   a
09d1: 60        clrc
09d2: 88 04     adc   a,#$04
09d4: de 5c 05  cbne  $5c+x,$09db
09d7: 80        setc
09d8: a8 04     sbc   a,#$04
09da: d4 5c     mov   $5c+x,a
09dc: fb 5c     mov   y,$5c+x
09de: e4 04     mov   a,$04
09e0: f0 01     beq   $09e3
09e2: bc        inc   a
09e3: d6 c0 fc  mov   $fcc0+y,a
09e6: c8 10     cmp   x,#$10
09e8: b0 05     bcs   $09ef
09ea: e8 00     mov   a,#$00
09ec: d6 a0 fc  mov   $fca0+y,a
09ef: dd        mov   a,y
09f0: 1c        asl   a
09f1: fd        mov   y,a
09f2: f4 0c     mov   a,$0c+x
09f4: d6 00 fd  mov   $fd00+y,a
09f7: f4 0d     mov   a,$0d+x
09f9: d6 01 fd  mov   $fd01+y,a
09fc: 6f        ret

--------------------------------------------------------------------------------------

09fd: fb 5c     mov   y,$5c+x
09ff: f6 c0 fc  mov   a,$fcc0+y
0a02: f0 15     beq   $0a19
0a04: 9c        dec   a
0a05: d0 0f     bne   $0a16
0a07: 7d        mov   a,x
0a08: 1c        asl   a
0a09: 9c        dec   a
0a0a: 9b 5c     dec   $5c+x
0a0c: de 5c 17  cbne  $5c+x,$0a25
0a0f: 60        clrc
0a10: 88 04     adc   a,#$04
0a12: d4 5c     mov   $5c+x,a
0a14: 2f 10     bra   $0a26
0a16: d6 c0 fc  mov   $fcc0+y,a
0a19: dd        mov   a,y
0a1a: 1c        asl   a
0a1b: fd        mov   y,a
0a1c: f6 00 fd  mov   a,$fd00+y
0a1f: d4 0c     mov   $0c+x,a
0a21: f6 01 fd  mov   a,$fd01+y
0a24: d4 0d     mov   $0d+x,a
0a26: 6f        ret

--------------------------------------------------------------------------------------

0a27: fd        mov   y,a
0a28: 3f 9c 05  call  $059c
0a2b: c8 10     cmp   x,#$10
0a2d: b0 12     bcs   $0a41
0a2f: e4 bf     mov   a,$bf
0a31: 24 d1     and   a,$d1
0a33: f0 0c     beq   $0a41
0a35: 4e d1 00  tclr1 $00d1
0a38: dd        mov   a,y
0a39: eb 04     mov   y,$04
0a3b: 7a 06     addw  ya,$06
0a3d: d4 0c     mov   $0c+x,a
0a3f: db 0d     mov   $0d+x,y
0a41: 6f        ret
0a42: d5 40 fb  mov   $fb40+x,a
0a45: 6f        ret

--------------------------------------------------------------------------------------

0a46: ae        pop   a
0a47: ae        pop   a
0a48: e4 bf     mov   a,$bf
0a4a: c8 10     cmp   x,#$10
0a4c: b0 05     bcs   $0a53
0a4e: 4e b9 00  tclr1 $00b9
0a51: 2f 06     bra   $0a59
0a53: 4e ba 00  tclr1 $00ba
0a56: 4e bb 00  tclr1 $00bb
0a59: 3f a6 08  call  $08a6
0a5c: 3f e5 08  call  $08e5
0a5f: 5f 67 08  jmp   $0867

--------------------------------------------------------------------------------------

0a62: f5 80 fa  mov   a,$fa80+x
0a65: f0 26     beq   $0a8d
0a67: 9c        dec   a
0a68: d5 80 fa  mov   $fa80+x,a
0a6b: f5 00 fa  mov   a,$fa00+x
0a6e: c4 34     mov   $34,a
0a70: f5 01 fa  mov   a,$fa01+x
0a73: c4 35     mov   $35,a
0a75: f5 21 fa  mov   a,$fa21+x
0a78: fd        mov   y,a
0a79: f5 20 fa  mov   a,$fa20+x
0a7c: 7a 34     addw  ya,$34
0a7e: d5 00 fa  mov   $fa00+x,a
0a81: dd        mov   a,y
0a82: 75 01 fa  cmp   a,$fa01+x
0a85: d5 01 fa  mov   $fa01+x,a
0a88: f0 03     beq   $0a8d
0a8a: 09 bf d6  or    ($d6),($bf)
0a8d: f5 81 fa  mov   a,$fa81+x
0a90: f0 26     beq   $0ab8
0a92: 9c        dec   a
0a93: d5 81 fa  mov   $fa81+x,a
0a96: f5 40 fa  mov   a,$fa40+x
0a99: c4 34     mov   $34,a
0a9b: f5 41 fa  mov   a,$fa41+x
0a9e: c4 35     mov   $35,a
0aa0: f5 61 fa  mov   a,$fa61+x
0aa3: fd        mov   y,a
0aa4: f5 60 fa  mov   a,$fa60+x
0aa7: 7a 34     addw  ya,$34
0aa9: d5 40 fa  mov   $fa40+x,a
0aac: dd        mov   a,y
0aad: 75 41 fa  cmp   a,$fa41+x
0ab0: d5 41 fa  mov   $fa41+x,a
0ab3: f0 03     beq   $0ab8
0ab5: 09 bf d6  or    ($d6),($bf)
0ab8: f5 80 fb  mov   a,$fb80+x
0abb: c4 34     mov   $34,a
0abd: f5 81 fb  mov   a,$fb81+x
0ac0: c4 35     mov   $35,a
0ac2: ba 34     movw  ya,$34
0ac4: f0 22     beq   $0ae8
0ac6: f5 c1 fa  mov   a,$fac1+x
0ac9: 9c        dec   a
0aca: d0 06     bne   $0ad2
0acc: d5 80 fb  mov   $fb80+x,a
0acf: d5 81 fb  mov   $fb81+x,a
0ad2: d5 c1 fa  mov   $fac1+x,a
0ad5: f5 61 fc  mov   a,$fc61+x
0ad8: fd        mov   y,a
0ad9: f5 60 fc  mov   a,$fc60+x
0adc: 7a 34     addw  ya,$34
0ade: d5 60 fc  mov   $fc60+x,a
0ae1: dd        mov   a,y
0ae2: d5 61 fc  mov   $fc61+x,a
0ae5: 09 bf d7  or    ($d7),($bf)
0ae8: f5 41 01  mov   a,$0141+x
0aeb: f0 55     beq   $0b42
0aed: f5 a0 fb  mov   a,$fba0+x
0af0: c4 34     mov   $34,a
0af2: f5 a1 fb  mov   a,$fba1+x
0af5: c4 35     mov   $35,a
0af7: f5 e1 fb  mov   a,$fbe1+x
0afa: fd        mov   y,a
0afb: c4 36     mov   $36,a
0afd: f5 e0 fb  mov   a,$fbe0+x
0b00: 7a 34     addw  ya,$34
0b02: d5 e0 fb  mov   $fbe0+x,a
0b05: dd        mov   a,y
0b06: e3 35 09  bbs7  $35,$0b11
0b09: e3 36 0d  bbs7  $36,$0b18
0b0c: 10 0b     bpl   $0b19
0b0e: e8 7f     mov   a,#$7f
0b10: 2f 07     bra   $0b19
0b12: f3 36 04  bbc7  $36,$0b18
0b15: 30 02     bmi   $0b19
0b17: e8 80     mov   a,#$80
0b19: 75 e1 fb  cmp   a,$fbe1+x
0b1c: d5 e1 fb  mov   $fbe1+x,a
0b1f: f0 03     beq   $0b24
0b21: 09 bf d6  or    ($d6),($bf)
0b24: f5 00 fb  mov   a,$fb00+x
0b27: 9c        dec   a
0b28: d0 15     bne   $0b3f
0b2a: 58 ff 34  eor   $34,#$ff
0b2d: 58 ff 35  eor   $35,#$ff
0b30: 3a 34     incw  $34
0b32: e4 34     mov   a,$34
0b34: d5 a0 fb  mov   $fba0+x,a
0b37: e4 35     mov   a,$35
0b39: d5 a1 fb  mov   $fba1+x,a
0b3c: f5 c0 fa  mov   a,$fac0+x
0b3f: d5 00 fb  mov   $fb00+x,a
0b42: 6f        ret

--------------------------------------------------------------------------------------

0b43: f5 21 01  mov   a,$0121+x
0b46: f0 6c     beq   $0bb4
0b48: fd        mov   y,a
0b49: f5 00 01  mov   a,$0100+x
0b4c: d0 66     bne   $0bb4
0b4e: f5 e0 fa  mov   a,$fae0+x
0b51: 9c        dec   a
0b52: d0 5d     bne   $0bb1
0b54: f5 00 fc  mov   a,$fc00+x
0b57: da 34     movw  $34,ya
0b59: f5 c0 fb  mov   a,$fbc0+x
0b5c: c4 36     mov   $36,a
0b5e: 3f 17 0d  call  $0d17
0b61: d5 c0 fb  mov   $fbc0+x,a
0b64: 1c        asl   a
0b65: d0 03     bne   $0b6a
0b67: fd        mov   y,a
0b68: 2f 3a     bra   $0ba4
0b6a: 0d        push  psw
0b6b: 2d        push  a
0b6c: 2d        push  a
0b6d: e4 34     mov   a,$34
0b6f: d5 00 fc  mov   $fc00+x,a
0b72: 8d 0f     mov   y,#$0f
0b74: f5 61 fc  mov   a,$fc61+x
0b77: cf        mul   ya
0b78: da 36     movw  $36,ya
0b7a: 8d 0f     mov   y,#$0f
0b7c: f5 60 fc  mov   a,$fc60+x
0b7f: cf        mul   ya
0b80: dd        mov   a,y
0b81: 8d 00     mov   y,#$00
0b83: 7a 36     addw  ya,$36
0b85: c4 36     mov   $36,a
0b87: ae        pop   a
0b88: cf        mul   ya
0b89: da 38     movw  $38,ya
0b8b: ae        pop   a
0b8c: eb 36     mov   y,$36
0b8e: cf        mul   ya
0b8f: dd        mov   a,y
0b90: 8d 00     mov   y,#$00
0b92: 7a 38     addw  ya,$38
0b94: 8e        pop   psw
0b95: 90 0d     bcc   $0ba4
0b97: 48 ff     eor   a,#$ff
0b99: c4 38     mov   $38,a
0b9b: dd        mov   a,y
0b9c: 48 ff     eor   a,#$ff
0b9e: c4 39     mov   $39,a
0ba0: 3a 38     incw  $38
0ba2: ba 38     movw  ya,$38
0ba4: d5 40 fc  mov   $fc40+x,a
0ba7: dd        mov   a,y
0ba8: d5 41 fc  mov   $fc41+x,a
0bab: 09 bf d7  or    ($d7),($bf)
0bae: f5 a0 fa  mov   a,$faa0+x
0bb1: d5 e0 fa  mov   $fae0+x,a
0bb4: f5 40 01  mov   a,$0140+x
0bb7: f0 2d     beq   $0be6
0bb9: fd        mov   y,a
0bba: f5 01 01  mov   a,$0101+x
0bbd: d0 27     bne   $0be6
0bbf: f5 e1 fa  mov   a,$fae1+x
0bc2: 9c        dec   a
0bc3: d0 1e     bne   $0be3
0bc5: f5 01 fc  mov   a,$fc01+x
0bc8: da 34     movw  $34,ya
0bca: f5 c1 fb  mov   a,$fbc1+x
0bcd: c4 36     mov   $36,a
0bcf: 3f 17 0d  call  $0d17
0bd2: d5 c1 fb  mov   $fbc1+x,a
0bd5: d5 01 fb  mov   $fb01+x,a
0bd8: e4 34     mov   a,$34
0bda: d5 01 fc  mov   $fc01+x,a
0bdd: 09 bf d6  or    ($d6),($bf)
0be0: f5 a1 fa  mov   a,$faa1+x
0be3: d5 e1 fa  mov   $fae1+x,a
0be6: ba d6     movw  ya,$d6
0be8: d0 01     bne   $0beb
0bea: 6f        ret

--------------------------------------------------------------------------------------

0beb: 7d        mov   a,x
0bec: 28 0f     and   a,#$0f
0bee: c4 34     mov   $34,a
0bf0: 9f        xcn   a
0bf1: 5c        lsr   a
0bf2: c4 35     mov   $35,a
0bf4: e4 bf     mov   a,$bf
0bf6: 24 d6     and   a,$d6
0bf8: d0 03     bne   $0bfd
0bfa: 5f b7 0c  jmp   $0cb7
0bfd: 8f 80 36  mov   $36,#$80
0c00: 03 be 3e  bbs0  $be,$0c40
0c03: e4 bf     mov   a,$bf
0c05: 24 bb     and   a,$bb
0c07: d0 38     bne   $0c41
0c09: c8 10     cmp   x,#$10
0c0b: b0 04     bcs   $0c11
0c0d: e4 90     mov   a,$90
0c0f: 2f 02     bra   $0c13
0c11: e4 92     mov   a,$92
0c13: 48 80     eor   a,#$80
0c15: 60        clrc
0c16: 30 09     bmi   $0c21
0c18: 95 41 fa  adc   a,$fa41+x
0c1b: 90 0b     bcc   $0c28
0c1d: e8 ff     mov   a,#$ff
0c1f: 2f 07     bra   $0c28
0c21: 95 41 fa  adc   a,$fa41+x
0c24: b0 02     bcs   $0c28
0c26: e8 00     mov   a,#$00
0c28: 60        clrc
0c29: 95 e1 fb  adc   a,$fbe1+x
0c2c: 2d        push  a
0c2d: f5 e1 fb  mov   a,$fbe1+x
0c30: ae        pop   a
0c31: 30 06     bmi   $0c39
0c33: 90 08     bcc   $0c3d
0c35: e8 ff     mov   a,#$ff
0c37: 2f 04     bra   $0c3d
0c39: b0 02     bcs   $0c3d
0c3b: e8 00     mov   a,#$00
0c3d: 48 ff     eor   a,#$ff
0c3f: c4 36     mov   $36,a
0c41: f5 01 fa  mov   a,$fa01+x
0c44: fd        mov   y,a
0c45: c4 37     mov   $37,a
0c47: f5 01 fb  mov   a,$fb01+x
0c4a: 1c        asl   a
0c4b: f0 10     beq   $0c5d
0c4d: 90 03     bcc   $0c52
0c4f: 48 ff     eor   a,#$ff
0c51: bc        inc   a
0c52: cf        mul   ya
0c53: b0 08     bcs   $0c5d
0c55: dd        mov   a,y
0c56: 84 37     adc   a,$37
0c58: 90 02     bcc   $0c5c
0c5a: e8 ff     mov   a,#$ff
0c5c: fd        mov   y,a
0c5d: c8 10     cmp   x,#$10
0c5f: b0 07     bcs   $0c68
0c61: e4 84     mov   a,$84
0c63: cf        mul   ya
0c64: e4 b8     mov   a,$b8
0c66: 2f 0c     bra   $0c74
0c68: e4 bf     mov   a,$bf
0c6a: 24 bb     and   a,$bb
0c6c: f0 04     beq   $0c72
0c6e: e8 ff     mov   a,#$ff
0c70: 2f 02     bra   $0c74
0c72: e4 86     mov   a,$86
0c74: cf        mul   ya
0c75: cb 37     mov   $37,y
0c77: c8 10     cmp   x,#$10
0c79: 90 06     bcc   $0c81
0c7b: aa be 60  mov1  c,$0c17,6
0c7e: ca 34 00  mov1  $0006,4,c
0c81: e4 36     mov   a,$36
0c83: fd        mov   y,a
0c84: c8 10     cmp   x,#$10
0c86: b0 01     bcs   $0c89
0c88: cf        mul   ya
0c89: e4 37     mov   a,$37
0c8b: cf        mul   ya
0c8c: e4 bf     mov   a,$bf
0c8e: 24 c0     and   a,$c0
0c90: f0 02     beq   $0c94
0c92: 8d 00     mov   y,#$00
0c94: dd        mov   a,y
0c95: eb 34     mov   y,$34
0c97: d6 da 00  mov   $00da+y,a
0c9a: 5c        lsr   a
0c9b: fd        mov   y,a
0c9c: e4 35     mov   a,$35
0c9e: c8 10     cmp   x,#$10
0ca0: 90 05     bcc   $0ca7
0ca2: 73 be 02  bbc3  $be,$0ca6
0ca5: 48 01     eor   a,#$01
0ca7: c4 f2     mov   $f2,a
0ca9: cb f3     mov   $f3,y
0cab: e4 36     mov   a,$36
0cad: 48 ff     eor   a,#$ff
0caf: ea 34 00  not1  $0006,4
0cb2: ab 35     inc   $35
0cb4: 33 35 cc  bbc1  $35,$0c82
0cb7: 22 35     set1  $35
0cb9: e4 bf     mov   a,$bf
0cbb: 24 d7     and   a,$d7
0cbd: f0 4f     beq   $0d0e
0cbf: f5 60 fc  mov   a,$fc60+x
0cc2: c4 36     mov   $36,a
0cc4: f5 61 fc  mov   a,$fc61+x
0cc7: c4 37     mov   $37,a
0cc9: f5 41 fc  mov   a,$fc41+x
0ccc: fd        mov   y,a
0ccd: f5 40 fc  mov   a,$fc40+x
0cd0: 7a 36     addw  ya,$36
0cd2: da 36     movw  $36,ya
0cd4: 2d        push  a
0cd5: e4 bf     mov   a,$bf
0cd7: 24 bb     and   a,$bb
0cd9: ae        pop   a
0cda: d0 25     bne   $0d01
0cdc: c8 10     cmp   x,#$10
0cde: b0 04     bcs   $0ce4
0ce0: e4 a8     mov   a,$a8
0ce2: 2f 02     bra   $0ce6
0ce4: e4 aa     mov   a,$aa
0ce6: 48 80     eor   a,#$80
0ce8: 0d        push  psw
0ce9: 2d        push  a
0cea: cf        mul   ya
0ceb: da 38     movw  $38,ya
0ced: ae        pop   a
0cee: eb 36     mov   y,$36
0cf0: cf        mul   ya
0cf1: dd        mov   a,y
0cf2: 8d 00     mov   y,#$00
0cf4: 7a 38     addw  ya,$38
0cf6: 8e        pop   psw
0cf7: 30 08     bmi   $0d01
0cf9: 1c        asl   a
0cfa: 2d        push  a
0cfb: dd        mov   a,y
0cfc: 3c        rol   a
0cfd: fd        mov   y,a
0cfe: ae        pop   a
0cff: 7a 36     addw  ya,$36
0d01: f8 35     mov   x,$35
0d03: d8 f2     mov   $f2,x
0d05: c4 f3     mov   $f3,a
0d07: 3d        inc   x
0d08: d8 f2     mov   $f2,x
0d0a: cb f3     mov   $f3,y
0d0c: f8 05     mov   x,$05
0d0e: e4 bf     mov   a,$bf
0d10: 4e d6 00  tclr1 $00d6
0d13: 4e d7 00  tclr1 $00d7
0d16: 6f        ret

--------------------------------------------------------------------------------------

0d17: dd        mov   a,y
0d18: 28 3f     and   a,#$3f
0d1a: 1c        asl   a
0d1b: bc        inc   a
0d1c: f3 35 09  bbc7  $35,$0d27
0d1f: d3 35 06  bbc6  $35,$0d27
0d22: f3 36 3e  bbc7  $36,$0d62
0d25: 8f 00 36  mov   $36,#$00
0d28: 0b 36     asl   $36
0d2a: d0 29     bne   $0d55
0d2c: eb 34     mov   y,$34
0d2e: f0 27     beq   $0d57
0d30: 13 34 09  bbc0  $34,$0d3b
0d33: 12 34     clr0  $34
0d35: 5c        lsr   a
0d36: 5c        lsr   a
0d37: d0 1e     bne   $0d57
0d39: bc        inc   a
0d3a: 2f 1b     bra   $0d57
0d3c: 33 34 08  bbc1  $34,$0d46
0d3f: 32 34     clr1  $34
0d41: 5c        lsr   a
0d42: d0 13     bne   $0d57
0d44: bc        inc   a
0d45: 2f 10     bra   $0d57
0d47: 52 34     clr2  $34
0d49: 5c        lsr   a
0d4a: c4 38     mov   $38,a
0d4c: 5c        lsr   a
0d4d: 60        clrc
0d4e: 84 38     adc   a,$38
0d50: d0 05     bne   $0d57
0d52: bc        inc   a
0d53: 2f 02     bra   $0d57
0d55: e8 00     mov   a,#$00
0d57: 38 40 35  and   $35,#$40
0d5a: 0b 35     asl   $35
0d5c: 58 80 35  eor   $35,#$80
0d5f: 04 35     or    a,$35
0d61: 2f 04     bra   $0d67
0d63: e4 36     mov   a,$36
0d65: 08 80     or    a,#$80
0d67: 6f        ret

--------------------------------------------------------------------------------------

0d68: f8 f4     mov   x,$f4
0d6a: f0 3b     beq   $0da7
0d6c: ba f6     movw  ya,$f6
0d6e: da c3     movw  $c3,ya
0d70: ba f4     movw  ya,$f4
0d72: da c1     movw  $c1,ya
0d74: c4 f4     mov   $f4,a
0d76: 64 f4     cmp   a,$f4
0d78: f0 fc     beq   $0d76
0d7a: 5d        mov   x,a
0d7b: 10 0d     bpl   $0d8a
0d7d: c8 fe     cmp   x,#$fe
0d7f: d0 03     bne   $0d84
0d81: 5f db 12  jmp   $12db
0d84: 8f 00 f4  mov   $f4,#$00
0d87: 5f fe 0f  jmp   $0ffe
0d8a: c8 01     cmp   x,#$01
0d8c: f0 1a     beq   $0da8
0d8e: c8 03     cmp   x,#$03
0d90: f0 16     beq   $0da8
0d92: 8f 00 f4  mov   $f4,#$00
0d95: c8 02     cmp   x,#$02
0d97: d0 03     bne   $0d9c
0d99: 5f e2 0e  jmp   $0ee2
0d9c: c8 10     cmp   x,#$10
0d9e: 90 07     bcc   $0da7
0da0: c8 20     cmp   x,#$20
0da2: b0 03     bcs   $0da7
0da4: 5f a5 0f  jmp   $0fa5
0da7: 6f        ret

--------------------------------------------------------------------------------------

0da8: e8 ff     mov   a,#$ff
0daa: 8d 5c     mov   y,#$5c
0dac: 3f 55 06  call  DSP_Write
0daf: 8f 00 f1  mov   $f1,#$00
0db2: 8f 40 fa  mov   $fa,#$40
0db5: 8f 01 f1  mov   $f1,#$01
0db8: e4 fd     mov   a,$fd
0dba: e4 fd     mov   a,$fd
0dbc: f0 fc     beq   $0dba
0dbe: 8f 00 f1  mov   $f1,#$00
0dc1: 8f 24 fa  mov   $fa,#$24
0dc4: 8f 01 f1  mov   $f1,#$01
0dc7: 3f db 12  call  $12db
0dca: 78 03 c1  cmp   $c1,#$03
0dcd: d0 05     bne   $0dd4
0dcf: 3f de 13  call  $13de
0dd2: e8 00     mov   a,#$00
0dd4: fa c2 ec  mov   ($ec),($c2)
0dd7: fd        mov   y,a
0dd8: da b9     movw  $b9,ya
0dda: c4 bb     mov   $bb,a
0ddc: da c9     movw  $c9,ya
0dde: da cb     movw  $cb,ya
0de0: da cd     movw  $cd,ya
0de2: c4 c5     mov   $c5,a
0de4: c4 c6     mov   $c6,a
0de6: c4 c7     mov   $c7,a
0de8: 32 be     clr1  $be
0dea: da bc     movw  $bc,ya
0dec: c4 b4     mov   $b4,a
0dee: c4 b7     mov   $b7,a
0df0: c4 9c     mov   $9c,a
0df2: c4 9e     mov   $9e,a
0df4: e2 9c     set7  $9c
0df6: e2 9e     set7  $9e
0df8: c4 a3     mov   $a3,a
0dfa: c4 a5     mov   $a5,a
0dfc: c4 a8     mov   $a8,a
0dfe: c4 aa     mov   $aa,a
0e00: e2 a8     set7  $a8
0e02: e2 aa     set7  $aa
0e04: c4 af     mov   $af,a
0e06: c4 b1     mov   $b1,a
0e08: da d6     movw  $d6,ya
0e0a: da cf     movw  $cf,ya
0e0c: c4 d1     mov   $d1,a
0e0e: da d8     movw  $d8,ya
0e10: 8f 01 7d  mov   $7d,#$01
0e13: 8f ff 7e  mov   $7e,#$ff
0e16: 8f ff b8  mov   $b8,#$ff
0e19: e3 be 02  bbs7  $be,$0e1d
0e1c: c4 c0     mov   $c0,a
0e1e: e8 00     mov   a,#$00
0e20: 8d 4d     mov   y,#$4d
0e22: 3f 55 06  call  DSP_Write
0e25: 8d 0d     mov   y,#$0d
0e27: 3f 55 06  call  DSP_Write
0e2a: 8d 2c     mov   y,#$2c
0e2c: 3f 55 06  call  DSP_Write
0e2f: 8d 3c     mov   y,#$3c
0e31: 3f 55 06  call  DSP_Write
0e34: 3f c8 13  call  $13c8
0e37: 73 04 03  bbc3  $04,$0e3c
0e3a: 5f b2 0e  jmp   $0eb2
0e3d: 69 ec eb  cmp   ($eb),($ec)
0e40: d0 05     bne   $0e47
0e42: 3f 87 15  call  $1587
0e45: 2f 43     bra   $0e8a
0e47: cd 10     mov   x,#$10
0e49: f5 01 1c  mov   a,$1c01+x
0e4c: d4 0b     mov   $0b+x,a
0e4e: 1d        dec   x
0e4f: d0 f8     bne   $0e49
0e51: e5 00 1c  mov   a,$1c00
0e54: c4 06     mov   $06,a
0e56: e5 01 1c  mov   a,$1c01
0e59: c4 07     mov   $07,a
0e5b: e8 14     mov   a,#$14
0e5d: 8d 1c     mov   y,#$1c
0e5f: 9a 06     subw  ya,$06
0e61: da 06     movw  $06,ya
0e63: cd 0e     mov   x,#$0e
0e65: 8f 80 bf  mov   $bf,#$80
0e68: e5 12 1c  mov   a,$1c12
0e6b: ec 13 1c  mov   y,$1c13
0e6e: da 34     movw  $34,ya
0e70: f4 0c     mov   a,$0c+x
0e72: fb 0d     mov   y,$0d+x
0e74: 5a 34     cmpw  ya,$34
0e76: f0 0c     beq   $0e84
0e78: 09 bf b9  or    ($b9),($bf)
0e7b: 7a 06     addw  ya,$06
0e7d: d4 0c     mov   $0c+x,a
0e7f: db 0d     mov   $0d+x,y
0e81: 3f ba 0e  call  $0eba
0e84: 1d        dec   x
0e85: 1d        dec   x
0e86: 4b bf     lsr   $bf
0e88: d0 e6     bne   $0e70
0e8a: e4 c3     mov   a,$c3
0e8c: 28 0f     and   a,#$0f
0e8e: f0 03     beq   $0e93
0e90: 9f        xcn   a
0e91: c4 90     mov   $90,a
0e93: e4 c4     mov   a,$c4
0e95: 28 f0     and   a,#$f0
0e97: 9f        xcn   a
0e98: 8d 11     mov   y,#$11
0e9a: cf        mul   ya
0e9b: c4 84     mov   $84,a
0e9d: e4 c3     mov   a,$c3
0e9f: 28 f0     and   a,#$f0
0ea1: c4 c2     mov   $c2,a
0ea3: e4 c4     mov   a,$c4
0ea5: 28 0f     and   a,#$0f
0ea7: 04 c2     or    a,$c2
0ea9: c4 c2     mov   $c2,a
0eab: e8 81     mov   a,#$81
0ead: c4 c1     mov   $c1,a
0eaf: 3f 14 10  call  $1014
0eb2: cd ff     mov   x,#$ff
0eb4: bd        mov   sp,x
0eb5: e4 fd     mov   a,$fd
0eb7: 5f 8c 02  jmp   $028c
0eba: 7d        mov   a,x
0ebb: 1c        asl   a
0ebc: d4 5c     mov   $5c+x,a
0ebe: e8 00     mov   a,#$00
0ec0: d5 20 01  mov   $0120+x,a
0ec3: d5 80 fb  mov   $fb80+x,a
0ec6: d5 81 fb  mov   $fb81+x,a
0ec9: d5 21 01  mov   $0121+x,a
0ecc: d5 40 01  mov   $0140+x,a
0ecf: d5 41 01  mov   $0141+x,a
0ed2: d5 e0 fb  mov   $fbe0+x,a
0ed5: d5 e1 fb  mov   $fbe1+x,a
0ed8: d5 40 fb  mov   $fb40+x,a
0edb: d5 61 fb  mov   $fb61+x,a
0ede: bc        inc   a
0edf: d4 3c     mov   $3c+x,a
0ee1: 6f        ret

--------------------------------------------------------------------------------------

0ee2: fa c2 2c  mov   ($2c),($c2)
0ee5: 8f 00 2d  mov   $2d,#$00
0ee8: 0b 2c     asl   $2c
0eea: 2b 2d     rol   $2d
0eec: 0b 2c     asl   $2c
0eee: 2b 2d     rol   $2d
0ef0: e8 00     mov   a,#$00
0ef2: 8d 2c     mov   y,#$2c
0ef4: 7a 2c     addw  ya,$2c
0ef6: da 2c     movw  $2c,ya
0ef8: cd 1e     mov   x,#$1e
0efa: 8f 80 bf  mov   $bf,#$80
0efd: e4 ba     mov   a,$ba
0eff: d0 04     bne   $0f05
0f01: e4 bb     mov   a,$bb
0f03: 48 f0     eor   a,#$f0
0f05: c4 03     mov   $03,a
0f07: e4 03     mov   a,$03
0f09: 24 bf     and   a,$bf
0f0b: d0 07     bne   $0f14
0f0d: 4b bf     lsr   $bf
0f0f: 1d        dec   x
0f10: 1d        dec   x
0f11: b3 bf f3  bbc5  $bf,$0f06
0f14: 8d 03     mov   y,#$03
0f16: 8f 00 03  mov   $03,#$00
0f19: f7 2c     mov   a,($2c)+y
0f1b: f0 2c     beq   $0f49
0f1d: d4 0d     mov   $0d+x,a
0f1f: dc        dec   y
0f20: f7 2c     mov   a,($2c)+y
0f22: d4 0c     mov   $0c+x,a
0f24: 09 bf 03  or    ($03),($bf)
0f27: 3f ba 0e  call  $0eba
0f2a: bb 3c     inc   $3c+x
0f2c: e8 60     mov   a,#$60
0f2e: d5 01 fa  mov   $fa01+x,a
0f31: e8 80     mov   a,#$80
0f33: d5 41 fa  mov   $fa41+x,a
0f36: e8 00     mov   a,#$00
0f38: d5 80 fa  mov   $fa80+x,a
0f3b: d5 81 fa  mov   $fa81+x,a
0f3e: 6d        push  y
0f3f: 3f f5 08  call  $08f5
0f42: ee        pop   y
0f43: 1d        dec   x
0f44: 1d        dec   x
0f45: 4b bf     lsr   $bf
0f47: 2f 01     bra   $0f4a
0f49: dc        dec   y
0f4a: dc        dec   y
0f4b: 10 cc     bpl   $0f19
0f4d: e4 ba     mov   a,$ba
0f4f: 04 03     or    a,$03
0f51: 4e bc 00  tclr1 $00bc
0f54: 4e d0 00  tclr1 $00d0
0f57: 0e bd 00  tset1 $00bd
0f5a: c4 02     mov   $02,a
0f5c: cd 1e     mov   x,#$1e
0f5e: 8f 80 bf  mov   $bf,#$80
0f61: 0b 02     asl   $02
0f63: 90 03     bcc   $0f68
0f65: 3f 48 0a  call  $0a48
0f68: 1d        dec   x
0f69: 1d        dec   x
0f6a: 4b bf     lsr   $bf
0f6c: 73 bf f2  bbc3  $bf,$0f60
0f6f: e4 03     mov   a,$03
0f71: c4 ba     mov   $ba,a
0f73: 4e c5 00  tclr1 $00c5
0f76: 4e c7 00  tclr1 $00c7
0f79: 4e c6 00  tclr1 $00c6
0f7c: e4 c3     mov   a,$c3
0f7e: 28 0f     and   a,#$0f
0f80: 8d 11     mov   y,#$11
0f82: cf        mul   ya
0f83: c4 86     mov   $86,a
0f85: e4 c4     mov   a,$c4
0f87: f0 1b     beq   $0fa4
0f89: 28 f0     and   a,#$f0
0f8b: f0 02     beq   $0f8f
0f8d: c4 92     mov   $92,a
0f8f: e4 c3     mov   a,$c3
0f91: 28 f0     and   a,#$f0
0f93: c4 c2     mov   $c2,a
0f95: e4 c4     mov   a,$c4
0f97: 28 0f     and   a,#$0f
0f99: 04 c2     or    a,$c2
0f9b: c4 c2     mov   $c2,a
0f9d: e8 85     mov   a,#$85
0f9f: c4 c1     mov   $c1,a
0fa1: 5f 8f 10  jmp   $108f
0fa4: 6f        ret

--------------------------------------------------------------------------------------

0fa5: 7d        mov   a,x
0fa6: 28 0f     and   a,#$0f
0fa8: 1c        asl   a
0fa9: fd        mov   y,a
0faa: cd 20     mov   x,#$20
0fac: e4 ba     mov   a,$ba
0fae: 04 bb     or    a,$bb
0fb0: 28 f0     and   a,#$f0
0fb2: 8f 80 bf  mov   $bf,#$80
0fb5: 68 f0     cmp   a,#$f0
0fb7: f0 0c     beq   $0fc5
0fb9: 1d        dec   x
0fba: 1d        dec   x
0fbb: 1c        asl   a
0fbc: 90 14     bcc   $0fd2
0fbe: 4b bf     lsr   $bf
0fc0: 73 bf f6  bbc3  $bf,$0fb8
0fc3: 2f 0d     bra   $0fd2
0fc5: 1d        dec   x
0fc6: 1d        dec   x
0fc7: e4 bb     mov   a,$bb
0fc9: 24 bf     and   a,$bf
0fcb: d0 05     bne   $0fd2
0fcd: 4b bf     lsr   $bf
0fcf: 73 bf f3  bbc3  $bf,$0fc4
0fd2: f6 3f 19  mov   a,$193f+y
0fd5: f0 26     beq   $0ffd
0fd7: d4 0d     mov   $0d+x,a
0fd9: f6 3e 19  mov   a,$193e+y
0fdc: d4 0c     mov   $0c+x,a
0fde: 3f ba 0e  call  $0eba
0fe1: bb 3c     inc   $3c+x
0fe3: 3f 48 0a  call  $0a48
0fe6: e4 bf     mov   a,$bf
0fe8: 4e d0 00  tclr1 $00d0
0feb: 0e bd 00  tset1 $00bd
0fee: 4e bc 00  tclr1 $00bc
0ff1: 4e c5 00  tclr1 $00c5
0ff4: 4e c7 00  tclr1 $00c7
0ff7: 4e c6 00  tclr1 $00c6
0ffa: 09 bf bb  or    ($bb),($bf)
0ffd: 6f        ret

--------------------------------------------------------------------------------------

0ffe: c8 f0     cmp   x,#$f0
1000: b0 04     bcs   $1006
1002: c8 90     cmp   x,#$90
1004: b0 0d     bcs   $1013
1006: 7d        mov   a,x
1007: 28 1f     and   a,#$1f
1009: 1c        asl   a
100a: fd        mov   y,a
100b: f6 b6 18  mov   a,$18b6+y
100e: 2d        push  a
100f: f6 b5 18  mov   a,$18b5+y
1012: 2d        push  a
1013: 6f        ret

--------------------------------------------------------------------------------------

1014: e4 c2     mov   a,$c2
1016: 38 f0 c2  and   $c2,#$f0
1019: 28 0f     and   a,#$0f
101b: 8d 11     mov   y,#$11
101d: cf        mul   ya
101e: c4 c3     mov   $c3,a
1020: cd 00     mov   x,#$00
1022: e4 c1     mov   a,$c1
1024: 13 c1 03  bbc0  $c1,$1029
1027: bc        inc   a
1028: 2f 0d     bra   $1037
102a: 33 c1 05  bbc1  $c1,$1031
102d: bc        inc   a
102e: cd 02     mov   x,#$02
1030: 2f 05     bra   $1037
1032: ab c1     inc   $c1
1034: 60        clrc
1035: 88 03     adc   a,#$03
1037: c4 34     mov   $34,a
1039: eb c3     mov   y,$c3
103b: e4 c2     mov   a,$c2
103d: d4 8b     mov   $8b+x,a
103f: d0 0a     bne   $104b
1041: db 84     mov   $84+x,y
1043: d4 83     mov   $83+x,a
1045: d4 88     mov   $88+x,a
1047: d4 87     mov   $87+x,a
1049: 2f 35     bra   $1080
104b: dd        mov   a,y
104c: 80        setc
104d: b4 84     sbc   a,$84+x
104f: f0 ec     beq   $103d
1051: 4d        push  x
1052: 0d        push  psw
1053: b0 03     bcs   $1058
1055: 48 ff     eor   a,#$ff
1057: bc        inc   a
1058: f8 c2     mov   x,$c2
105a: 8d 00     mov   y,#$00
105c: 9e        div   ya,x
105d: c4 37     mov   $37,a
105f: e8 00     mov   a,#$00
1061: 9e        div   ya,x
1062: c4 36     mov   $36,a
1064: ba 36     movw  ya,$36
1066: d0 02     bne   $106a
1068: ab 36     inc   $36
106a: 8e        pop   psw
106b: b0 08     bcs   $1075
106d: 58 ff 36  eor   $36,#$ff
1070: 58 ff 37  eor   $37,#$ff
1073: 3a 36     incw  $36
1075: ba 36     movw  ya,$36
1077: ce        pop   x
1078: d4 87     mov   $87+x,a
107a: db 88     mov   $88+x,y
107c: e8 00     mov   a,#$00
107e: d4 83     mov   $83+x,a
1080: ab c1     inc   $c1
1082: 69 34 c1  cmp   ($c1),($34)
1085: f0 04     beq   $108b
1087: 3d        inc   x
1088: 3d        inc   x
1089: 2f ae     bra   $1039
108b: 8f ff d6  mov   $d6,#$ff
108e: 6f        ret

--------------------------------------------------------------------------------------

108f: ab c1     inc   $c1
1091: e4 c2     mov   a,$c2
1093: 28 0f     and   a,#$0f
1095: f0 71     beq   $1108
1097: 38 f0 c2  and   $c2,#$f0
109a: 9f        xcn   a
109b: c4 c3     mov   $c3,a
109d: cd 00     mov   x,#$00
109f: e4 c1     mov   a,$c1
10a1: 13 c1 03  bbc0  $c1,$10a6
10a4: bc        inc   a
10a5: 2f 0d     bra   $10b4
10a7: 33 c1 05  bbc1  $c1,$10ae
10aa: bc        inc   a
10ab: cd 02     mov   x,#$02
10ad: 2f 05     bra   $10b4
10af: ab c1     inc   $c1
10b1: 60        clrc
10b2: 88 03     adc   a,#$03
10b4: c4 34     mov   $34,a
10b6: eb c3     mov   y,$c3
10b8: e4 c2     mov   a,$c2
10ba: d4 97     mov   $97+x,a
10bc: d0 0a     bne   $10c8
10be: db 90     mov   $90+x,y
10c0: d4 8f     mov   $8f+x,a
10c2: d4 94     mov   $94+x,a
10c4: d4 93     mov   $93+x,a
10c6: 2f 35     bra   $10fd
10c8: dd        mov   a,y
10c9: 80        setc
10ca: b4 90     sbc   a,$90+x
10cc: f0 ec     beq   $10ba
10ce: 4d        push  x
10cf: 0d        push  psw
10d0: b0 03     bcs   $10d5
10d2: 48 ff     eor   a,#$ff
10d4: bc        inc   a
10d5: f8 c2     mov   x,$c2
10d7: 8d 00     mov   y,#$00
10d9: 9e        div   ya,x
10da: c4 37     mov   $37,a
10dc: e8 00     mov   a,#$00
10de: 9e        div   ya,x
10df: c4 36     mov   $36,a
10e1: ba 36     movw  ya,$36
10e3: d0 02     bne   $10e7
10e5: ab 36     inc   $36
10e7: 8e        pop   psw
10e8: b0 08     bcs   $10f2
10ea: 58 ff 36  eor   $36,#$ff
10ed: 58 ff 37  eor   $37,#$ff
10f0: 3a 36     incw  $36
10f2: ba 36     movw  ya,$36
10f4: ce        pop   x
10f5: d4 93     mov   $93+x,a
10f7: db 94     mov   $94+x,y
10f9: e8 00     mov   a,#$00
10fb: d4 8f     mov   $8f+x,a
10fd: ab c1     inc   $c1
10ff: 69 34 c1  cmp   ($c1),($34)
1102: f0 04     beq   $1108
1104: 3d        inc   x
1105: 3d        inc   x
1106: 2f ae     bra   $10b6
1108: 8f ff d6  mov   $d6,#$ff
110b: 6f        ret

--------------------------------------------------------------------------------------

110c: e4 c2     mov   a,$c2
110e: 28 07     and   a,#$07
1110: f0 0a     beq   $111c
1112: 73 c2 01  bbc3  $c2,$1115
1115: 9c        dec   a
1116: 8d 12     mov   y,#$12
1118: cf        mul   ya
1119: 63 c2 02  bbs3  $c2,$111d
111c: 48 80     eor   a,#$80
111e: c4 c3     mov   $c3,a
1120: 38 f0 c2  and   $c2,#$f0
1123: cd 00     mov   x,#$00
1125: e4 c1     mov   a,$c1
1127: 13 c1 03  bbc0  $c1,$112c
112a: bc        inc   a
112b: 2f 0d     bra   $113a
112d: 23 c1 05  bbs1  $c1,$1134
1130: bc        inc   a
1131: cd 02     mov   x,#$02
1133: 2f 05     bra   $113a
1135: ab c1     inc   $c1
1137: 60        clrc
1138: 88 03     adc   a,#$03
113a: c4 34     mov   $34,a
113c: eb c3     mov   y,$c3
113e: e4 c2     mov   a,$c2
1140: d4 a3     mov   $a3+x,a
1142: d0 0a     bne   $114e
1144: db 9c     mov   $9c+x,y
1146: d4 9b     mov   $9b+x,a
1148: d4 a0     mov   $a0+x,a
114a: d4 9f     mov   $9f+x,a
114c: 2f 35     bra   $1183
114e: dd        mov   a,y
114f: 80        setc
1150: b4 9c     sbc   a,$9c+x
1152: f0 ec     beq   $1140
1154: 4d        push  x
1155: 0d        push  psw
1156: b0 03     bcs   $115b
1158: 48 ff     eor   a,#$ff
115a: bc        inc   a
115b: f8 c2     mov   x,$c2
115d: 8d 00     mov   y,#$00
115f: 9e        div   ya,x
1160: c4 37     mov   $37,a
1162: e8 00     mov   a,#$00
1164: 9e        div   ya,x
1165: c4 36     mov   $36,a
1167: ba 36     movw  ya,$36
1169: d0 02     bne   $116d
116b: ab 36     inc   $36
116d: 8e        pop   psw
116e: b0 08     bcs   $1178
1170: 58 ff 36  eor   $36,#$ff
1173: 58 ff 37  eor   $37,#$ff
1176: 3a 36     incw  $36
1178: ba 36     movw  ya,$36
117a: ce        pop   x
117b: d4 9f     mov   $9f+x,a
117d: db a0     mov   $a0+x,y
117f: e8 00     mov   a,#$00
1181: d4 9b     mov   $9b+x,a
1183: ab c1     inc   $c1
1185: 69 34 c1  cmp   ($c1),($34)
1188: f0 04     beq   $118e
118a: 3d        inc   x
118b: 3d        inc   x
118c: 2f ae     bra   $113c
118e: 6f        ret

--------------------------------------------------------------------------------------

118f: ab c1     inc   $c1
1191: e4 c2     mov   a,$c2
1193: 28 07     and   a,#$07
1195: f0 0a     beq   $11a1
1197: 73 c2 01  bbc3  $c2,$119a
119a: 9c        dec   a
119b: 8d 12     mov   y,#$12
119d: cf        mul   ya
119e: 63 c2 02  bbs3  $c2,$11a2
11a1: 48 80     eor   a,#$80
11a3: c4 c3     mov   $c3,a
11a5: 38 f0 c2  and   $c2,#$f0
11a8: cd 00     mov   x,#$00
11aa: e4 c1     mov   a,$c1
11ac: 13 c1 03  bbc0  $c1,$11b1
11af: bc        inc   a
11b0: 2f 0d     bra   $11bf
11b2: 23 c1 05  bbs1  $c1,$11b9
11b5: bc        inc   a
11b6: cd 02     mov   x,#$02
11b8: 2f 05     bra   $11bf
11ba: ab c1     inc   $c1
11bc: 60        clrc
11bd: 88 03     adc   a,#$03
11bf: c4 34     mov   $34,a
11c1: eb c3     mov   y,$c3
11c3: e4 c2     mov   a,$c2
11c5: d4 af     mov   $af+x,a
11c7: d0 0a     bne   $11d3
11c9: db a8     mov   $a8+x,y
11cb: d4 a7     mov   $a7+x,a
11cd: d4 ac     mov   $ac+x,a
11cf: d4 ab     mov   $ab+x,a
11d1: 2f 35     bra   $1208
11d3: dd        mov   a,y
11d4: 80        setc
11d5: b4 a8     sbc   a,$a8+x
11d7: f0 ec     beq   $11c5
11d9: 4d        push  x
11da: 0d        push  psw
11db: b0 03     bcs   $11e0
11dd: 48 ff     eor   a,#$ff
11df: bc        inc   a
11e0: f8 c2     mov   x,$c2
11e2: 8d 00     mov   y,#$00
11e4: 9e        div   ya,x
11e5: c4 37     mov   $37,a
11e7: e8 00     mov   a,#$00
11e9: 9e        div   ya,x
11ea: c4 36     mov   $36,a
11ec: ba 36     movw  ya,$36
11ee: d0 02     bne   $11f2
11f0: ab 36     inc   $36
11f2: 8e        pop   psw
11f3: b0 08     bcs   $11fd
11f5: 58 ff 36  eor   $36,#$ff
11f8: 58 ff 37  eor   $37,#$ff
11fb: 3a 36     incw  $36
11fd: ba 36     movw  ya,$36
11ff: ce        pop   x
1200: d4 ab     mov   $ab+x,a
1202: db ac     mov   $ac+x,y
1204: e8 00     mov   a,#$00
1206: d4 a7     mov   $a7+x,a
1208: ab c1     inc   $c1
120a: 69 34 c1  cmp   ($c1),($34)
120d: f0 04     beq   $1213
120f: 3d        inc   x
1210: 3d        inc   x
1211: 2f ae     bra   $11c1
1213: 6f        ret

--------------------------------------------------------------------------------------

1214: 13 c1 04  bbc0  $c1,$121a
1217: 12 be     clr0  $be
1219: 2f 02     bra   $121d
121b: 02 be     set0  $be
121d: 8f ff d6  mov   $d6,#$ff
1220: 6f        ret

--------------------------------------------------------------------------------------

1221: 23 c1 29  bbs1  $c1,$124c
1224: e4 ba     mov   a,$ba
1226: 04 bb     or    a,$bb
1228: 48 ff     eor   a,#$ff
122a: 0e bd 00  tset1 $00bd
122d: 4e bc 00  tclr1 $00bc
1230: 4e c5 00  tclr1 $00c5
1233: 4e c7 00  tclr1 $00c7
1236: 4e c6 00  tclr1 $00c6
1239: e8 00     mov   a,#$00
123b: c4 b9     mov   $b9,a
123d: c4 d8     mov   $d8,a
123f: c4 c9     mov   $c9,a
1241: c4 cd     mov   $cd,a
1243: c4 cb     mov   $cb,a
1245: 9c        dec   a
1246: c4 eb     mov   $eb,a
1248: c4 ec     mov   $ec,a
124a: 03 c1 1d  bbs0  $c1,$1269
124d: e4 ba     mov   a,$ba
124f: 0e bd 00  tset1 $00bd
1252: 4e bc 00  tclr1 $00bc
1255: c4 02     mov   $02,a
1257: cd 1e     mov   x,#$1e
1259: 8f 80 bf  mov   $bf,#$80
125c: 0b 02     asl   $02
125e: 90 03     bcc   $1263
1260: 3f 48 0a  call  $0a48
1263: 1d        dec   x
1264: 1d        dec   x
1265: 4b bf     lsr   $bf
1267: 73 bf f2  bbc3  $bf,$125b
126a: 6f        ret
126b: fa c2 c0  mov   ($c0),($c2)
126e: 8f ff d6  mov   $d6,#$ff
1271: 6f        ret
1272: fa b9 d1  mov   ($d1),($b9)
1275: 6f        ret

--------------------------------------------------------------------------------------

1276: 60        clrc
1277: e8 ff     mov   a,#$ff
1279: 84 c2     adc   a,$c2
127b: ca be 60  mov1  $0c17,6,c
127e: 6f        ret
127f: 03 c1 3a  bbs0  $c1,$12bb
1282: 8d 05     mov   y,#$05
1284: cb f2     mov   $f2,y
1286: e4 f3     mov   a,$f3
1288: 28 7f     and   a,#$7f
128a: c4 f3     mov   $f3,a
128c: dd        mov   a,y
128d: 60        clrc
128e: 88 10     adc   a,#$10
1290: fd        mov   y,a
1291: 10 f1     bpl   $1284
1293: cd 00     mov   x,#$00
1295: 8d 00     mov   y,#$00
1297: cb f2     mov   $f2,y
1299: d8 f3     mov   $f3,x
129b: fc        inc   y
129c: cb f2     mov   $f2,y
129e: d8 f3     mov   $f3,x
12a0: dd        mov   a,y
12a1: 60        clrc
12a2: 88 0f     adc   a,#$0f
12a4: fd        mov   y,a
12a5: 10 f0     bpl   $1297
12a7: ba b9     movw  ya,$b9
12a9: f0 06     beq   $12b1
12ab: da d8     movw  $d8,ya
12ad: ba 00     movw  ya,$00
12af: da b9     movw  $b9,ya
12b1: c4 bc     mov   $bc,a
12b3: 8d 10     mov   y,#$10
12b5: d6 d9 00  mov   $00d9+y,a
12b8: fe fb     dbnz  y,$12b5
12ba: 2f 1e     bra   $12da
12bc: 8d 05     mov   y,#$05
12be: cb f2     mov   $f2,y
12c0: e4 f3     mov   a,$f3
12c2: 08 80     or    a,#$80
12c4: c4 f3     mov   $f3,a
12c6: dd        mov   a,y
12c7: 60        clrc
12c8: 88 10     adc   a,#$10
12ca: fd        mov   y,a
12cb: 10 f1     bpl   $12be
12cd: ba d8     movw  ya,$d8
12cf: f0 09     beq   $12da
12d1: 8f ff d6  mov   $d6,#$ff
12d4: da b9     movw  $b9,ya
12d6: ba 00     movw  ya,$00
12d8: da d8     movw  $d8,ya
12da: 6f        ret

--------------------------------------------------------------------------------------

12db: e4 f5     mov   a,$f5
12dd: c4 04     mov   $04,a
12df: 28 07     and   a,#$07
12e1: c4 f5     mov   $f5,a
12e3: d0 04     bne   $12e9
12e5: d8 f4     mov   $f4,x
12e7: 2f 1b     bra   $1304
12e9: 1c        asl   a
12ea: 2d        push  a
12eb: ba f6     movw  ya,$f6
12ed: da 2c     movw  $2c,ya
12ef: ee        pop   y
12f0: f6 1c 18  mov   a,$181c+y
12f3: 2d        push  a
12f4: f6 1b 18  mov   a,$181b+y
12f7: 2d        push  a
12f8: 8d 00     mov   y,#$00
12fa: f8 f4     mov   x,$f4
12fc: d8 f4     mov   $f4,x
12fe: 3e f4     cmp   x,$f4
1300: f0 fc     beq   $12fe
1302: f8 f4     mov   x,$f4
1304: 6f        ret

--------------------------------------------------------------------------

1305: e4 f5     mov   a,$f5
1307: d7 2c     mov   ($2c)+y,a
1309: 3a 2c     incw  $2c
130b: e4 f6     mov   a,$f6
130d: d7 2c     mov   ($2c)+y,a
130f: 3a 2c     incw  $2c
1311: e4 f7     mov   a,$f7
1313: d7 2c     mov   ($2c)+y,a
1315: 3a 2c     incw  $2c
1317: d8 f4     mov   $f4,x
1319: 3e f4     cmp   x,$f4
131b: f0 fc     beq   $1319
131d: f8 f4     mov   x,$f4
131f: d0 e4     bne   $1305
1321: 2f b8     bra   $12db
1323: e4 f6     mov   a,$f6
1325: d7 2c     mov   ($2c)+y,a
1327: 3a 2c     incw  $2c
1329: e4 f7     mov   a,$f7
132b: d7 2c     mov   ($2c)+y,a
132d: 3a 2c     incw  $2c
132f: d8 f4     mov   $f4,x
1331: 3e f4     cmp   x,$f4
1333: f0 fc     beq   $1331
1335: f8 f4     mov   x,$f4
1337: d0 ea     bne   $1323
1339: 2f a0     bra   $12db
133b: e4 f7     mov   a,$f7
133d: d7 2c     mov   ($2c)+y,a
133f: 3a 2c     incw  $2c
1341: d8 f4     mov   $f4,x
1343: 3e f4     cmp   x,$f4
1345: f0 fc     beq   $1343
1347: f8 f4     mov   x,$f4
1349: d0 f0     bne   $133b
134b: 2f 8e     bra   $12db
134d: d8 f4     mov   $f4,x
134f: 3e f4     cmp   x,$f4
1351: f0 fc     beq   $134f
1353: f8 f4     mov   x,$f4
1355: d0 f6     bne   $134d
1357: 5f db 12  jmp   $12db
135a: ba f6     movw  ya,$f6
135c: da 2e     movw  $2e,ya
135e: d8 f4     mov   $f4,x
1360: 3e f4     cmp   x,$f4
1362: f0 fc     beq   $1360
1364: f8 f4     mov   x,$f4
1366: ba f6     movw  ya,$f6
1368: da 34     movw  $34,ya
136a: d8 f4     mov   $f4,x
136c: 8d 00     mov   y,#$00
136e: f7 2c     mov   a,($2c)+y
1370: d7 2e     mov   ($2e)+y,a
1372: fc        inc   y
1373: d0 04     bne   $1379
1375: ab 2d     inc   $2d
1377: ab 2f     inc   $2f
1379: 1a 34     decw  $34
137b: d0 f1     bne   $136e
137d: 3e f4     cmp   x,$f4
137f: f0 fc     beq   $137d
1381: f8 f4     mov   x,$f4
1383: f0 0e     beq   $1393
1385: ba f6     movw  ya,$f6
1387: da 2c     movw  $2c,ya
1389: d8 f4     mov   $f4,x
138b: 3e f4     cmp   x,$f4
138d: f0 fc     beq   $138b
138f: f8 f4     mov   x,$f4
1391: 2f c7     bra   $135a
1393: 5f db 12  jmp   $12db
1396: ea c1 20  not1  $0418,1
1399: aa c1 20  mov1  c,$0418,1
139c: ca be 20  mov1  $0417,6,c
139f: b0 04     bcs   $13a5
13a1: e8 24     mov   a,#$24
13a3: 2f 02     bra   $13a7
13a5: e8 01     mov   a,#$01
13a7: 8f 00 f1  mov   $f1,#$00
13aa: c4 fa     mov   $fa,a
13ac: 8f 01 f1  mov   $f1,#$01
13af: 6f        ret

--------------------------------------------------------------------------------------

13b0: e8 ff     mov   a,#$ff
13b2: 8d fe     mov   y,#$fe
13b4: 5a c1     cmpw  ya,$c1
13b6: d0 0c     bne   $13c4
13b8: e8 fd     mov   a,#$fd
13ba: 8d fc     mov   y,#$fc
13bc: 5a c3     cmpw  ya,$c3
13be: d0 04     bne   $13c4
13c0: e2 be     set7  $be
13c2: 2f 02     bra   $13c6
13c4: f2 be     clr7  $be
13c6: 6f        ret

--------------------------------------------------------------------------------------

13c7: 6f        ret

--------------------------------------------------------------------------------------

13c8: e8 00     mov   a,#$00
13ca: 8d d2     mov   y,#$d2
13cc: da 2c     movw  $2c,ya
13ce: e8 00     mov   a,#$00
13d0: fd        mov   y,a
13d1: d7 2c     mov   ($2c)+y,a
13d3: fc        inc   y
13d4: d0 fb     bne   $13d1
13d6: ab 2d     inc   $2d
13d8: 78 fa 2d  cmp   $2d,#$fa
13db: d0 f4     bne   $13d1
13dd: 6f        ret

--------------------------------------------------------------------------------------

13de: fa ec eb  mov   ($eb),($ec)
13e1: e4 80     mov   a,$80
13e3: c5 80 fd  mov   $fd80,a
13e6: e4 7e     mov   a,$7e
13e8: c5 81 fd  mov   $fd81,a
13eb: e4 b8     mov   a,$b8
13ed: c5 8c fd  mov   $fd8c,a
13f0: e4 b7     mov   a,$b7
13f2: c5 82 fd  mov   $fd82,a
13f5: e4 b9     mov   a,$b9
13f7: c5 83 fd  mov   $fd83,a
13fa: e4 c9     mov   a,$c9
13fc: c5 84 fd  mov   $fd84,a
13ff: e4 cb     mov   a,$cb
1401: c5 85 fd  mov   $fd85,a
1404: e4 cd     mov   a,$cd
1406: c5 86 fd  mov   $fd86,a
1409: e4 cf     mov   a,$cf
140b: c5 87 fd  mov   $fd87,a
140e: e4 d1     mov   a,$d1
1410: c5 88 fd  mov   $fd88,a
1413: e4 d2     mov   a,$d2
1415: c5 89 fd  mov   $fd89,a
1418: e4 d4     mov   a,$d4
141a: c5 8a fd  mov   $fd8a,a
141d: e4 d5     mov   a,$d5
141f: c5 8b fd  mov   $fd8b,a
1422: ba 06     movw  ya,$06
1424: c5 8d fd  mov   $fd8d,a
1427: cc 8e fd  mov   $fd8e,y
142a: ba 7c     movw  ya,$7c
142c: c5 8f fd  mov   $fd8f,a
142f: cc 90 fd  mov   $fd90,y
1432: ba 81     movw  ya,$81
1434: c5 91 fd  mov   $fd91,a
1437: cc 92 fd  mov   $fd92,y
143a: ba b3     movw  ya,$b3
143c: c5 93 fd  mov   $fd93,a
143f: cc 94 fd  mov   $fd94,y
1442: ba b5     movw  ya,$b5
1444: c5 95 fd  mov   $fd95,a
1447: cc 96 fd  mov   $fd96,y
144a: cd 0e     mov   x,#$0e
144c: f4 3c     mov   a,$3c+x
144e: d5 97 fd  mov   $fd97+x,a
1451: f4 3d     mov   a,$3d+x
1453: d5 98 fd  mov   $fd98+x,a
1456: f4 5c     mov   a,$5c+x
1458: d5 a7 fd  mov   $fda7+x,a
145b: f4 5d     mov   a,$5d+x
145d: d5 a8 fd  mov   $fda8+x,a
1460: f5 00 01  mov   a,$0100+x
1463: d5 b7 fd  mov   $fdb7+x,a
1466: f5 01 01  mov   a,$0101+x
1469: d5 b8 fd  mov   $fdb8+x,a
146c: f5 20 01  mov   a,$0120+x
146f: d5 c7 fd  mov   $fdc7+x,a
1472: f5 21 01  mov   a,$0121+x
1475: d5 c8 fd  mov   $fdc8+x,a
1478: f5 40 01  mov   a,$0140+x
147b: d5 d7 fd  mov   $fdd7+x,a
147e: f5 41 01  mov   a,$0141+x
1481: d5 d8 fd  mov   $fdd8+x,a
1484: f5 60 01  mov   a,$0160+x
1487: d5 e7 fd  mov   $fde7+x,a
148a: f5 61 01  mov   a,$0161+x
148d: d5 e8 fd  mov   $fde8+x,a
1490: f5 80 fa  mov   a,$fa80+x
1493: d5 f7 fd  mov   $fdf7+x,a
1496: f5 81 fa  mov   a,$fa81+x
1499: d5 f8 fd  mov   $fdf8+x,a
149c: f5 a0 fa  mov   a,$faa0+x
149f: d5 07 fe  mov   $fe07+x,a
14a2: f5 a1 fa  mov   a,$faa1+x
14a5: d5 08 fe  mov   $fe08+x,a
14a8: f5 c0 fa  mov   a,$fac0+x
14ab: d5 17 fe  mov   $fe17+x,a
14ae: 1d        dec   x
14af: 1d        dec   x
14b0: 10 9a     bpl   $144c
14b2: cd 0e     mov   x,#$0e
14b4: f5 c1 fa  mov   a,$fac1+x
14b7: d5 18 fe  mov   $fe18+x,a
14ba: f5 e0 fa  mov   a,$fae0+x
14bd: d5 27 fe  mov   $fe27+x,a
14c0: f5 e1 fa  mov   a,$fae1+x
14c3: d5 28 fe  mov   $fe28+x,a
14c6: f5 00 fb  mov   a,$fb00+x
14c9: d5 37 fe  mov   $fe37+x,a
14cc: f5 40 fb  mov   a,$fb40+x
14cf: d5 47 fe  mov   $fe47+x,a
14d2: f5 41 fb  mov   a,$fb41+x
14d5: d5 48 fe  mov   $fe48+x,a
14d8: f5 61 fb  mov   a,$fb61+x
14db: d5 58 fe  mov   $fe58+x,a
14de: f5 c0 fb  mov   a,$fbc0+x
14e1: d5 67 fe  mov   $fe67+x,a
14e4: f5 c1 fb  mov   a,$fbc1+x
14e7: d5 68 fe  mov   $fe68+x,a
14ea: f5 01 fb  mov   a,$fb01+x
14ed: d5 38 fe  mov   $fe38+x,a
14f0: f5 00 fc  mov   a,$fc00+x
14f3: d5 77 fe  mov   $fe77+x,a
14f6: f5 01 fc  mov   a,$fc01+x
14f9: d5 78 fe  mov   $fe78+x,a
14fc: 1d        dec   x
14fd: 1d        dec   x
14fe: 10 b4     bpl   $14b4
1500: cd 3f     mov   x,#$3f
1502: f5 00 fd  mov   a,$fd00+x
1505: d5 97 ff  mov   $ff97+x,a
1508: 1d        dec   x
1509: c8 20     cmp   x,#$20
150b: b0 f5     bcs   $1502
150d: f5 00 fd  mov   a,$fd00+x
1510: d5 97 ff  mov   $ff97+x,a
1513: f5 c0 fc  mov   a,$fcc0+x
1516: d5 77 ff  mov   $ff77+x,a
1519: f5 a0 fc  mov   a,$fca0+x
151c: d5 57 ff  mov   $ff57+x,a
151f: 1d        dec   x
1520: c8 10     cmp   x,#$10
1522: b0 e9     bcs   $150d
1524: f5 00 fd  mov   a,$fd00+x
1527: d5 97 ff  mov   $ff97+x,a
152a: f5 c0 fc  mov   a,$fcc0+x
152d: d5 77 ff  mov   $ff77+x,a
1530: f5 a0 fc  mov   a,$fca0+x
1533: d5 57 ff  mov   $ff57+x,a
1536: f4 0c     mov   a,$0c+x
1538: d5 87 fe  mov   $fe87+x,a
153b: f5 00 fa  mov   a,$fa00+x
153e: d5 97 fe  mov   $fe97+x,a
1541: f5 20 fa  mov   a,$fa20+x
1544: d5 a7 fe  mov   $fea7+x,a
1547: f5 40 fa  mov   a,$fa40+x
154a: d5 b7 fe  mov   $feb7+x,a
154d: f5 60 fa  mov   a,$fa60+x
1550: d5 c7 fe  mov   $fec7+x,a
1553: f5 20 fb  mov   a,$fb20+x
1556: d5 d7 fe  mov   $fed7+x,a
1559: f5 80 fb  mov   a,$fb80+x
155c: d5 e7 fe  mov   $fee7+x,a
155f: f5 a0 fb  mov   a,$fba0+x
1562: d5 f7 fe  mov   $fef7+x,a
1565: f5 e0 fb  mov   a,$fbe0+x
1568: d5 07 ff  mov   $ff07+x,a
156b: f5 20 fc  mov   a,$fc20+x
156e: d5 17 ff  mov   $ff17+x,a
1571: f5 40 fc  mov   a,$fc40+x
1574: d5 27 ff  mov   $ff27+x,a
1577: f5 60 fc  mov   a,$fc60+x
157a: d5 37 ff  mov   $ff37+x,a
157d: f5 80 fc  mov   a,$fc80+x
1580: d5 47 ff  mov   $ff47+x,a
1583: 1d        dec   x
1584: 10 9e     bpl   $1524
1586: 6f        ret

--------------------------------------------------------------------------------------

1587: 8f ff eb  mov   $eb,#$ff
158a: e5 80 fd  mov   a,$fd80
158d: c4 80     mov   $80,a
158f: e5 81 fd  mov   a,$fd81
1592: c4 7e     mov   $7e,a
1594: e5 8c fd  mov   a,$fd8c
1597: c4 b8     mov   $b8,a
1599: e5 82 fd  mov   a,$fd82
159c: c4 b7     mov   $b7,a
159e: e5 83 fd  mov   a,$fd83
15a1: c4 b9     mov   $b9,a
15a3: e5 84 fd  mov   a,$fd84
15a6: c4 c9     mov   $c9,a
15a8: c4 c5     mov   $c5,a
15aa: e5 85 fd  mov   a,$fd85
15ad: c4 cb     mov   $cb,a
15af: c4 c6     mov   $c6,a
15b1: e5 86 fd  mov   a,$fd86
15b4: c4 cd     mov   $cd,a
15b6: c4 c7     mov   $c7,a
15b8: e5 87 fd  mov   a,$fd87
15bb: c4 cf     mov   $cf,a
15bd: e5 88 fd  mov   a,$fd88
15c0: c4 d1     mov   $d1,a
15c2: e5 89 fd  mov   a,$fd89
15c5: c4 d2     mov   $d2,a
15c7: c4 c8     mov   $c8,a
15c9: e5 8b fd  mov   a,$fd8b
15cc: c4 d5     mov   $d5,a
15ce: e5 8a fd  mov   a,$fd8a
15d1: 3f 95 07  call  $0795
15d4: e5 8d fd  mov   a,$fd8d
15d7: ec 8e fd  mov   y,$fd8e
15da: da 06     movw  $06,ya
15dc: e5 8f fd  mov   a,$fd8f
15df: ec 90 fd  mov   y,$fd90
15e2: da 7c     movw  $7c,ya
15e4: e5 91 fd  mov   a,$fd91
15e7: ec 92 fd  mov   y,$fd92
15ea: da 81     movw  $81,ya
15ec: e5 93 fd  mov   a,$fd93
15ef: ec 94 fd  mov   y,$fd94
15f2: da b3     movw  $b3,ya
15f4: e5 95 fd  mov   a,$fd95
15f7: ec 96 fd  mov   y,$fd96
15fa: da b5     movw  $b5,ya
15fc: cd 0e     mov   x,#$0e
15fe: f5 97 fd  mov   a,$fd97+x
1601: d4 3c     mov   $3c+x,a
1603: f5 98 fd  mov   a,$fd98+x
1606: d4 3d     mov   $3d+x,a
1608: f5 a7 fd  mov   a,$fda7+x
160b: d4 5c     mov   $5c+x,a
160d: f5 a8 fd  mov   a,$fda8+x
1610: d4 5d     mov   $5d+x,a
1612: f5 b7 fd  mov   a,$fdb7+x
1615: d5 00 01  mov   $0100+x,a
1618: f5 b8 fd  mov   a,$fdb8+x
161b: d5 01 01  mov   $0101+x,a
161e: f5 c7 fd  mov   a,$fdc7+x
1621: d5 20 01  mov   $0120+x,a
1624: f5 c8 fd  mov   a,$fdc8+x
1627: d5 21 01  mov   $0121+x,a
162a: f5 d7 fd  mov   a,$fdd7+x
162d: d5 40 01  mov   $0140+x,a
1630: f5 d8 fd  mov   a,$fdd8+x
1633: d5 41 01  mov   $0141+x,a
1636: f5 e7 fd  mov   a,$fde7+x
1639: d5 60 01  mov   $0160+x,a
163c: f5 e8 fd  mov   a,$fde8+x
163f: d5 61 01  mov   $0161+x,a
1642: f5 f7 fd  mov   a,$fdf7+x
1645: d5 80 fa  mov   $fa80+x,a
1648: f5 f8 fd  mov   a,$fdf8+x
164b: d5 81 fa  mov   $fa81+x,a
164e: f5 07 fe  mov   a,$fe07+x
1651: d5 a0 fa  mov   $faa0+x,a
1654: f5 08 fe  mov   a,$fe08+x
1657: d5 a1 fa  mov   $faa1+x,a
165a: f5 17 fe  mov   a,$fe17+x
165d: d5 c0 fa  mov   $fac0+x,a
1660: 1d        dec   x
1661: 1d        dec   x
1662: 10 9a     bpl   $15fe
1664: cd 0e     mov   x,#$0e
1666: f5 18 fe  mov   a,$fe18+x
1669: d5 c1 fa  mov   $fac1+x,a
166c: f5 27 fe  mov   a,$fe27+x
166f: d5 e0 fa  mov   $fae0+x,a
1672: f5 28 fe  mov   a,$fe28+x
1675: d5 e1 fa  mov   $fae1+x,a
1678: f5 37 fe  mov   a,$fe37+x
167b: d5 00 fb  mov   $fb00+x,a
167e: f5 47 fe  mov   a,$fe47+x
1681: d5 40 fb  mov   $fb40+x,a
1684: f5 48 fe  mov   a,$fe48+x
1687: d5 41 fb  mov   $fb41+x,a
168a: f5 58 fe  mov   a,$fe58+x
168d: d5 61 fb  mov   $fb61+x,a
1690: f5 67 fe  mov   a,$fe67+x
1693: d5 c0 fb  mov   $fbc0+x,a
1696: f5 68 fe  mov   a,$fe68+x
1699: d5 c1 fb  mov   $fbc1+x,a
169c: f5 38 fe  mov   a,$fe38+x
169f: d5 01 fb  mov   $fb01+x,a
16a2: f5 77 fe  mov   a,$fe77+x
16a5: d5 00 fc  mov   $fc00+x,a
16a8: f5 78 fe  mov   a,$fe78+x
16ab: d5 01 fc  mov   $fc01+x,a
16ae: 1d        dec   x
16af: 1d        dec   x
16b0: 10 b4     bpl   $1666
16b2: cd 3f     mov   x,#$3f
16b4: f5 97 ff  mov   a,$ff97+x
16b7: d5 00 fd  mov   $fd00+x,a
16ba: 1d        dec   x
16bb: c8 20     cmp   x,#$20
16bd: b0 f5     bcs   $16b4
16bf: f5 97 ff  mov   a,$ff97+x
16c2: d5 00 fd  mov   $fd00+x,a
16c5: f5 77 ff  mov   a,$ff77+x
16c8: d5 c0 fc  mov   $fcc0+x,a
16cb: f5 57 ff  mov   a,$ff57+x
16ce: d5 a0 fc  mov   $fca0+x,a
16d1: 1d        dec   x
16d2: c8 10     cmp   x,#$10
16d4: b0 e9     bcs   $16bf
16d6: f5 97 ff  mov   a,$ff97+x
16d9: d5 00 fd  mov   $fd00+x,a
16dc: f5 77 ff  mov   a,$ff77+x
16df: d5 c0 fc  mov   $fcc0+x,a
16e2: f5 57 ff  mov   a,$ff57+x
16e5: d5 a0 fc  mov   $fca0+x,a
16e8: f5 87 fe  mov   a,$fe87+x
16eb: d4 0c     mov   $0c+x,a
16ed: f5 97 fe  mov   a,$fe97+x
16f0: d5 00 fa  mov   $fa00+x,a
16f3: f5 a7 fe  mov   a,$fea7+x
16f6: d5 20 fa  mov   $fa20+x,a
16f9: f5 b7 fe  mov   a,$feb7+x
16fc: d5 40 fa  mov   $fa40+x,a
16ff: f5 c7 fe  mov   a,$fec7+x
1702: d5 60 fa  mov   $fa60+x,a
1705: f5 d7 fe  mov   a,$fed7+x
1708: d5 20 fb  mov   $fb20+x,a
170b: f5 e7 fe  mov   a,$fee7+x
170e: d5 80 fb  mov   $fb80+x,a
1711: f5 f7 fe  mov   a,$fef7+x
1714: d5 a0 fb  mov   $fba0+x,a
1717: f5 07 ff  mov   a,$ff07+x
171a: d5 e0 fb  mov   $fbe0+x,a
171d: f5 17 ff  mov   a,$ff17+x
1720: d5 20 fc  mov   $fc20+x,a
1723: f5 27 ff  mov   a,$ff27+x
1726: d5 40 fc  mov   $fc40+x,a
1729: f5 37 ff  mov   a,$ff37+x
172c: d5 60 fc  mov   $fc60+x,a
172f: f5 47 ff  mov   a,$ff47+x
1732: d5 80 fc  mov   $fc80+x,a
1735: 1d        dec   x
1736: 10 9e     bpl   $16d6
1738: 6f        ret

--------------------------------------------------------------------------------------

1739: e8 34     mov   a,#$34
173b: c4 39     mov   $39,a
173d: e8 da     mov   a,#$da
173f: 8f 00 03  mov   $03,#$00
1742: 43 be 05  bbs2  $be,$1749
1745: 8f 09 bf  mov   $bf,#$09
1748: 2f 08     bra   $1752
174a: 8f 49 bf  mov   $bf,#$49
174d: 60        clrc
174e: 88 08     adc   a,#$08
1750: e2 03     set7  $03
1752: c4 3a     mov   $3a,a
1754: 60        clrc
1755: 88 08     adc   a,#$08
1757: c4 02     mov   $02,a
1759: f8 3a     mov   x,$3a
175b: eb bf     mov   y,$bf
175d: cb f2     mov   $f2,y
175f: eb f3     mov   y,$f3
1761: 6d        push  y
1762: bf        mov   a,(x)+
1763: cf        mul   ya
1764: dd        mov   a,y
1765: 28 70     and   a,#$70
1767: c4 38     mov   $38,a
1769: ee        pop   y
176a: bf        mov   a,(x)+
176b: cf        mul   ya
176c: dd        mov   a,y
176d: d8 3a     mov   $3a,x
176f: f8 39     mov   x,$39
1771: 9f        xcn   a
1772: 28 07     and   a,#$07
1774: 04 38     or    a,$38
1776: 04 03     or    a,$03
1778: af        mov   (x)+,a
1779: d8 39     mov   $39,x
177b: 60        clrc
177c: 98 10 bf  adc   $bf,#$10
177f: 69 02 3a  cmp   ($3a),($02)
1782: d0 d5     bne   $1759
1784: ba 34     movw  ya,$34
1786: da f4     movw  $f4,ya
1788: ba 36     movw  ya,$36
178a: da f6     movw  $f6,ya
178c: 58 04 be  eor   $be,#$04
178f: 6f        ret

--------------------------------------------------------------------------------------

1790: e4 8b     mov   a,$8b
1792: f0 0f     beq   $17a3
1794: 8b 8b     dec   $8b
1796: ba 87     movw  ya,$87
1798: 7a 83     addw  ya,$83
179a: 7e 84     cmp   y,$84
179c: da 83     movw  $83,ya
179e: f0 03     beq   $17a3
17a0: 09 b9 d6  or    ($d6),($b9)
17a3: e4 8d     mov   a,$8d
17a5: f0 0f     beq   $17b6
17a7: 8b 8d     dec   $8d
17a9: ba 89     movw  ya,$89
17ab: 7a 85     addw  ya,$85
17ad: 7e 86     cmp   y,$86
17af: da 85     movw  $85,ya
17b1: f0 03     beq   $17b6
17b3: 09 ba d6  or    ($d6),($ba)
17b6: e4 97     mov   a,$97
17b8: f0 0f     beq   $17c9
17ba: 8b 97     dec   $97
17bc: ba 93     movw  ya,$93
17be: 7a 8f     addw  ya,$8f
17c0: 7e 90     cmp   y,$90
17c2: da 8f     movw  $8f,ya
17c4: f0 03     beq   $17c9
17c6: 09 b9 d6  or    ($d6),($b9)
17c9: e4 99     mov   a,$99
17cb: f0 0f     beq   $17dc
17cd: 8b 99     dec   $99
17cf: ba 95     movw  ya,$95
17d1: 7a 91     addw  ya,$91
17d3: 7e 92     cmp   y,$92
17d5: da 91     movw  $91,ya
17d7: f0 03     beq   $17dc
17d9: 09 ba d6  or    ($d6),($ba)
17dc: e4 a3     mov   a,$a3
17de: f0 08     beq   $17e8
17e0: 8b a3     dec   $a3
17e2: ba 9f     movw  ya,$9f
17e4: 7a 9b     addw  ya,$9b
17e6: da 9b     movw  $9b,ya
17e8: e4 a5     mov   a,$a5
17ea: f0 08     beq   $17f4
17ec: 8b a5     dec   $a5
17ee: ba a1     movw  ya,$a1
17f0: 7a 9d     addw  ya,$9d
17f2: da 9d     movw  $9d,ya
17f4: e4 af     mov   a,$af
17f6: f0 0f     beq   $1807
17f8: 8b af     dec   $af
17fa: ba ab     movw  ya,$ab
17fc: 7a a7     addw  ya,$a7
17fe: 7e a8     cmp   y,$a8
1800: da a7     movw  $a7,ya
1802: f0 03     beq   $1807
1804: 09 b9 d7  or    ($d7),($b9)
1807: e4 b1     mov   a,$b1
1809: f0 0f     beq   $181a
180b: 8b b1     dec   $b1
180d: ba ad     movw  ya,$ad
180f: 7a a9     addw  ya,$a9
1811: 7e aa     cmp   y,$aa
1813: da a9     movw  $a9,ya
1815: f0 03     beq   $181a
1817: 09 ba d7  or    ($d7),($ba)
181a: 6f        ret

--------------------------------------------------------------------------------------

//
// Data
// 

// Jump table 1

181b:   4d 13               
        3b 13
        23 13
        05 13
        4d 13 
        4d 13
        4d 13
        5a 13

// Jump table 2

182b: a2
182c: 06
182d: ae        pop   a
182e: 06        or    a,(x)
182f: 30 07     bmi   $1838
1831: 3c        rol   a
1832: 07 78     or    a,($78+x)
1834: 07 b7     or    a,($b7+x)
1836: 07 c9     or    a,($c9+x)
1838: 07 cd     or    a,($cd+x)
183a: 07 df     or    a,($df+x)
183c: 07 e3     or    a,($e3+x)
183e: 07 34     or    a,($34+x)
1840: 08 be     or    a,#$be
1842: 08 77     or    a,#$77
1844: 08 a6     or    a,#$a6
1846: 08 cc     or    a,#$cc
1848: 08 e5     or    a,#$e5
184a: 08 4e     or    a,#$4e
184c: 08 67     or    a,#$67
184e: 08 4a     or    a,#$4a
1850: 08 40     or    a,#$40
1852: 08 46     or    a,#$46
1854: 08 87     or    a,#$87
1856: 07 83     or    a,($83+x)
1858: 07 42     or    a,($42+x)
185a: 0a f5 08  or1   c,$011e,5
185d: 1f 09 4f  jmp   ($4f09+x)
1860: 09 62 09  or    ($09),($62)
1863: 74 09     cmp   a,$09+x
1865: 84 09     adc   a,$09
1867: cd 09     mov   x,#$09
1869: fd        mov   y,a
186a: 09 46 0a  or    ($0a),($46)
186d: 5a 06     cmpw  ya,$06
186f: 67 06     cmp   a,($06+x)
1871: ea 06 f7  not1  $1ee0,6
1874: 06        or    a,(x)
1875: 8b 07     dec   $07
1877: 9f        xcn   a
1878: 06        or    a,(x)
1879: a8 09     sbc   a,#$09
187b: 96 09 27  adc   a,$2709+y
187e: 0a 46 0a  or1   c,$0148,6
1881: 46        eor   a,(x)
1882: 0a 46 0a  or1   c,$0148,6
1885: 46        eor   a,(x)
1886: 0a

// Some data

1887: 01 02  
1889: 01       
188a: 02 02     set0  $02
188c: 03 00 03  bbs0  $00,$1891
188f: 00        nop
1890: 02 00     set0  $00
1892: 01        tcall 0
1893: 00        nop
1894: 00        nop
1895: 00        nop
1896: 00        nop
1897: 00        nop
1898: 00        nop
1899: 01        tcall 0
189a: 00        nop
189b: 00        nop
189c: 01        tcall 0
189d: 01        tcall 0
189e: 01        tcall 0
189f: 01        tcall 0
18a0: 01        tcall 0
18a1: 01        tcall 0
18a2: 01        tcall 0
18a3: 01        tcall 0
18a4: 00        nop
18a5: 01        tcall 0
18a6: 00        nop
18a7: 00        nop
18a8: 01        tcall 0
18a9: 02 01     set0  $01
18ab: 02 02     set0  $02
18ad: 01        tcall 0
18ae: 03 02 02  bbs0  $02,$18b2
18b1: 00        nop
18b2: 00        nop
18b3: 00        nop
18b4: 00        nop

// Jump table 3

18b5: 14 10     or    a,$10+x
18b7: 14 10     or    a,$10+x
18b9: 14 10     or    a,$10+x
18bb: 8f 10 8f  mov   $8f,#$10
18be: 10 8f     bpl   $184f
18c0: 10 0c     bpl   $18ce
18c2: 11        tcall 1
18c3: 0c 11 0c  asl   $0c11
18c6: 11        tcall 1
18c7: 8f 11 8f  mov   $8f,#$11
18ca: 11        tcall 1
18cb: 8f 11 c7  mov   $c7,#$11
18ce: 13 c7 13  bbc0  $c7,$18e3
18d1: c7 13     mov   ($13+x),a
18d3: c7 13     mov   ($13+x),a
18d5: 21        tcall 2
18d6: 12 21     clr0  $21
18d8: 12 21     clr0  $21
18da: 12 14     clr0  $14
18dc: 12 14     clr0  $14
18de: 12 6b     clr0  $6b
18e0: 12 7f     clr0  $7f
18e2: 12 7f     clr0  $7f
18e4: 12 96     clr0  $96
18e6: 13 96 13  bbc0  $96,$18fb
18e9: 96 13 72  adc   a,$7213+y
18ec: 12 76     clr0  $76
18ee: 12 c7     clr0  $c7
18f0: 13 c7 13  bbc0  $c7,$1905
18f3: b0 13     bcs   $1908

// Jump table 4

18f5: 79        cmp   (x),(y)
18f6: 08 fa     or    a,#$fa
18f8: 08 83     or    a,#$83
18fa: 09 14 0a  or    ($0a),($14)
18fd: ad 0a     cmp   y,#$0a
18ff: 50 0b     bvc   $190c
1901: fc        inc   y
1902: 0b b2     asl   $b2
1904: 0c 74 0d  asl   $0d74
1907: 41        tcall 4
1908: 0e 1a 0f  tset1 $0f1a
190b: 00        nop
190c: 10 f3     bpl   $1901
190e: 10


190f: 7f     bpl   $198f
1910: 00        nop
1911: 00        nop
1912: 00        nop
1913: 00        nop
1914: 00        nop
1915: 00        nop
1916: 00        nop
1917: 0c 21 2b  asl   $2b21
191a: 2b 13     rol   $13
191c: fe f3     dbnz  y,$1911
191e: f9 58     mov   x,$58+y
1920: bf        mov   a,(x)+
1921: db f0     mov   $f0+x,y
1923: fe 07     dbnz  y,$192c
1925: 0c 0c 34  asl   $340c
1928: 33 00 d9  bbc1  $00,$1903
192b: e5 01 fc  mov   a,$fc01
192e: eb c0     mov   y,$c0
1930: 90 60     bcc   $1992
1932: 40        setp
1933: 48 30     eor   a,#$30
1935: 20        clrp
1936: 24 18     and   a,$18
1938: 10 0c     bpl   $1946
193a: 08 06     or    a,#$06
193c: 04 03     or    a,$03
193e: 5e 19 69  cmp   y,$6919
1941: 19        or    (x),(y)
1942: 74 19     cmp   a,$19+x
1944: 82 19     set4  $19
1946: 00        nop
1947: 00        nop
1948: 00        nop
1949: 00        nop
194a: 00        nop
194b: 00        nop
194c: 00        nop
194d: 00        nop
194e: 94 19     adc   a,$19+x
1950: ad 19     cmp   y,#$19
1952: c5 19 00  mov   $0019,a
1955: 00        nop
1956: 00        nop
1957: 00        nop
1958: 00        nop
1959: 00        nop
195a: 00        nop
195b: 00        nop
195c: d4 19     mov   $19+x,a
195e: d2 78     clr6  $78
1960: ea 05 d6  not1  $1ac0,5
1963: 06        or    a,(x)
1964: 0c e4 06  asl   $06e4
1967: 74 f2     cmp   a,$f2+x
1969: d2 78     clr6  $78
196b: ea 05 d6  not1  $1ac0,5
196e: 06        or    a,(x)
196f: 0c e4 06  asl   $06e4
1972: a1        tcall 10
1973: f2 d2     clr7  $d2
1975: ff        stop
1976: e4 04     mov   a,$04
1978: f0 03     beq   $197d
197a: ea 06 3b  not1  $0760,6
197d: ea 07 3b  not1  $0760,7
1980: f1        tcall 15
1981: f2 d2     clr7  $d2
1983: 80        setc
1984: ea 03 e2  not1  $1c40,3
1987: eb 0e     mov   y,$0e
1989: ee        pop   y
198a: 16 e4 07  or    a,$07e4+y
198d: 2a 3a 58  or1   c,!($0b07,2)
1990: 75 84 9a  cmp   a,$9a84+x
1993: f2 d2     clr7  $d2
1995: e6        mov   a,(x)
1996: d7 00     mov   ($00)+y,a
1998: 0c 7f ea  asl   $ea7f
199b: 07 e4     or    a,($e4+x)
199d: 05 92 e5  or    a,$e592
19a0: d2 b4     clr6  $b4
19a2: 47 d2     eor   a,($d2+x)
19a4: 82 47     set4  $47
19a6: d2 64     clr6  $64
19a8: 47 d2     eor   a,($d2+x)
19aa: 32 47     clr1  $47
19ac: f2 d2     clr7  $d2
19ae: e6        mov   a,(x)
19af: d7 00     mov   ($00)+y,a
19b1: 0c 7f ea  asl   $ea7f
19b4: 07 e4     or    a,($e4+x)
19b6: 05 47 d2  or    a,$d247
19b9: b4 b0     sbc   a,$b0+x
19bb: d2 82     clr6  $82
19bd: b0 d2     bcs   $1991
19bf: 64 b0     cmp   a,$b0
19c1: d2 32     clr6  $32
19c3: b0 f2     bcs   $19b7
19c5: d2 ff     clr6  $ff
19c7: ea 00 de  not1  $1bc0,0
19ca: dd        mov   a,y
19cb: 10 eb     bpl   $19b8
19cd: 0e ed 05  tset1 $05ed
19d0: ee        pop   y
19d1: 0e 00 f2  tset1 $f200
19d4: d2 80     clr6  $80
19d6: ea 04 e2  not1  $1c40,4
19d9: e4 1d     mov   a,$1d
19db: ee        pop   y
19dc: 12 0e     clr0  $0e
19de: 4b

// See start

19df: f2
19e0: 4c 5c 2d
19e3: 3d      
19e4: 4d      
19e5: 2c 3c

// See start

19e7: 6c
19e8: bc
19e9: bd
19ea: c7 c6
19ec: c5 b4 b4
19ef: c8 ff
