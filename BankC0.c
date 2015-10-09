// FFV. Bank C0:0000 ... C0:FFFF.

start ()    // C0:0000
{
    HW.SEI;     // Disable interrupts

    // HW.CLC;
    // HW.XCE;     // Set native mode

    // REP #0x10;  // .I16
    // SEP #0x20;  // .A8

    //
    // Hardware init
    //

    HW.CYCLE_SPEED_DESIGNATION = 0;
    HW.REGULAR_DMA_CHANNEL_ENABLE = 0;
    HW.H_DMA_CHANNEL_ENABLE = 0;
    HW.SCREEN_DISPLAY_REGISTER = 0x8F;
    HW.NMI_V_H_COUNT_AND_JOYPAD_ENABLE = 0;

    // B = 0;
    // S = 0x1FFF;
    // D = 0xB00;

    word.[D + 6] = 0;

    //
    // SpcInit
    //

    SpcInit ();

    //
    // Game Intro sequence
    //

    PlayBgfx ( 0xF1 );

    BigPpuSetup ();

    ClearVars ();

    //
    // Load game menu
    //

    byte_7E0134 = 3;        // Menu type
    GameMenu ();

    //
    // First actions: load game save or show Tycoon intro
    //

    PpuDisable ();

    BigPpuSetup ();

    SetupIntHandlers ();

    if ( byte_7E0139 )      // Menu result
    {
        //
        // Load Save
        //

        sub_C0491D ();

        byte_7E0B60 = byte_7E0AF9;
        byte_7E0B5F = byte_7E0AF9 >> 1;

        byte.[D + 0xBD] = 1;
        byte.[D + 0xBC] = 1;        
        byte.[D + 0xB9] = 2;

        word_7E1088 = word_7E0AD8;

        sub_C0545D ();
    }
    else
    {
        //
        // Show Tycoon Intro
        //

        sub_C048FA ();

        sub_C048ED ();

        sub_C048DD ();

        sub_C04528 ();

        sub_C0450A ();

        byte.[D + 0xBD] = 1;
        byte.[D + 0xBC] = 1;
        word.[D + 0xCE] = 0x10;
        byte.[D + 0x57] = 1;

        HW.NMI_V_H_COUNT_AND_JOYPAD_ENABLE = 0x81;

        HW.CLI;            // Enable interrupts

        sub_C0A217 ();

        byte.[D + 0x57] = 0;
        byte.[D + 0x58] = 0;
        byte.[D + 0x55] = 0;
    }

    //
    // Main Loop with many cases
    //

    while ( 1 )
    {
        sub_C04E41 ();

        //
        // Special case: byte.[D + 2] & 0x40
        //

        if ( byte.[D + 2] & 0x40 )
        {
            if ( byte.[D + 0x53] == 0 && byte.[D + 0x5D] == 0 )
            {
                if ( (byte_7E0B61 & 0x1F) == 0 && (byte_7E0B63 & 0x1F) == 0 )
                {
                    byte_7E0135 = 0;

                    if ( byte_7E0ADC == 0 )
                    {
                        if ( (word_7E0AD6 <BCC> 5) || sub_C0CA3C ( 0xFD ) )
                            byte_7E0135 = 0x80;
                    }

                    byte.[D + 8] = 0;

                    if ( byte.[D + 0x53] )
                        byte.[D + 8] = byte_7E110F & 3;

                    byte_7E0135 |= byte.[D + 8];
                    byte_7E0134 = 0;

                    sub_C0454C ();

                    byte.[D + 0x55] = 2;

                    word_7E1088 = word_7E0AD8;

                    sub_C05476 ();

                    if ( byte_7E0139 == 0xF0 )
                        sub_C0046A ( X = 0x22 );
                    else if ( byte_7E0139 == 0xF0 )
                        sub_C0046A ( X = 0x24 );
                    else if ( byte_7E0139 == 0x3E )
                        sub_C0046A ( X = 0x32 );

                    byte_7E16AA = 0;

                    sub_C014E9 ();

                    continue;
                }
            }
        }

        //
        // Default case
        //

        sub_C0061A ();                                          // loc_C00147

        sub_C0A18B ();

        if ( byte.[D + 0x58] )
        {
            byte.[D + 0x58] = 0;
            continue;
        }

        if ( byte.[D + 0x6E] )
        {
            sub_C0545A ();
            continue;
        }

        if ( word_7E0AD6 <BCC> 5 )
        {
            //
            // Case A
            //

            sub_C0073E ();

            if ( byte.[D + 0x58] )
            {
                byte.[D + 0x58] = 0;
                continue;
            }

            if ( (byte.[D + 0x61] & 0x1F) == 0 && (byte.[D + 0x63] & 0x1F) == 0 )
            {
                if ( byte_7E0AD6 != 1 || byte_7E0AD9 != 0xA1 || byte_7E0AD8 <BCC> 0x9F || byte_7E0AD8 <BCS> 0xA2 )
                {
                    if ( byte_7E0AD6 || byte_7E0ADC != 6 || byte_7E0AD8 <BCC> 0x3D || byte_7E0AD8 <BCS> 0x3D 
                         || byte_7E0AD9 <BCC> 0x9E || byte_7E0AD9 <BCS> 0xA5 )
                    {
                        if ( ! ( byte_7E0AD6 !=2 || byte_7E0ADC <BCC> 5 || byte_7E0AD8 <BCC> 0xB6 || 
                                 byte_7E0AD8 <BCS> 0xBA || byte_7E0AD9 <BCC> 0x87 || byte_7E0AD9 <BCS> 0x8B ) )
                            X = 0x18;
                        else
                            X = 0;
                    }
                    else 
                        X = 0x20;
                }
                else
                    X = 0x12;

                if ( X )
                {
                    sub_C0046A ( X );

                    if ( byte.[D + 0x58] )
                    {
                        byte.[D + 0x58] = 0;
                        continue;
                    }
                }
            }

            //
            // loc_C001FB
            //

            sub_C0CB11 ();

            if ( byte.[D + 0x55] )
            {
                if ( sub_C0CA3C ( X = 0xFF ) == 0 )
                {
                    sub_C0CCF0 ();
                    word_7E1088 = word_7E0AD8;
                    sub_C05476 ();
                    continue;
                }
            }

            byte.[D + 0x55] = 0;

            if ( byte.[D + 3] & 0x40 )
            {
                if ( sub_C0CA3C ( A = 0xFB ) )
                {
                    sub_C06632 ();
                    word_7E1088 = word_7E0AD8;
                    sub_C05476 ();
                    continue;
                }
            }

            //
            // loc_C00246
            //

            sub_C00F8C ();
            sub_C01A1D ();
            sub_C04C95 ();
            sub_C02137 ();
            sub_C0612B ();
            sub_C01EC5 ();
            sub_C01E64 ():
            sub_C0420A ();
        }
        else                                            // loc_C00262
        {
            //
            // Case B
            //

            sub_C00D3D ();

            if ( byte.[D + 0x58] )
            {
                byte.[D + 0x58] = 0;
                continue;
            }                    

            if ( byte_7E10FB == 0 )
            {
                sub_C0548F ();

                sub_C0046A ( X = 0x1C );

                continue;
            }

            sub_C0CA69 ();

            if ( byte.[D + 0x55] )
            {
                if ( sub_C0CA3C ( A = 0xFF ) )
                {
                    sub_C0CCF0 ();

                    sub_C05476 ();

                    continue;
                }
            }

            byte.[D + 0x55] = 0;

            sub_C032AB ();

            sub_C011C2 ();

            if ( byte.[D + 0x6E] )
            {
                sub_C0545A ();

                continue;
            }

            if ( byte.[D + 0x58] == 0 )
            {
                sub_C01AE4 ();
                sub_C03BAC ();
                sub_C04C95 ();
                sub_C04834 ();
                sub_C0237C ();
                sub_C039B3 ();
                sub_C02842 ();
                sub_C0420A ();
            }
            else
                byte.[D + 0x58] = 0;
        }
    
    }   // End while
}

Emulation_mode_RESET ()         // C0:CEC0
{
    HW.SEI;        // Interrupt disable
    HW.CLC;
    HW.XCE;        // Native mode enabled

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
