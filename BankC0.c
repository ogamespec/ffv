// FFV Core. Bank C0:0000 ... C0:FFFF.  ~450 procedures
//

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

    // DB = 0;
    // S = 0x1FFF;
    // D = 0xB00;

    word.[D + 6] = 0;           // Zero Word Constant

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
    // Load party menu
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

        LoadMapFromSave ();
    }
    else
    {
        //
        // Show Tycoon Intro
        //

        LoadDefaultParty ();

        sub_C048ED ();

        sub_C048DD ();

        sub_C04528 ();

        sub_C0450A ();

        byte.[D + 0xBD] = 1;
        byte.[D + 0xBC] = 1;
        word.[D + 0xCE] = 0x10;         // Scene number for GameScript Engine
        byte.[D + 0x57] = 1;

        HW.NMI_V_H_COUNT_AND_JOYPAD_ENABLE = 0x81;

        HW.CLI;            // Enable interrupts

        GameScript ();

        byte.[D + 0x57] = 0;
        byte.[D + 0x58] = 0;
        byte.[D + 0x55] = 0;
    }

    //
    // Main Loop with many cases
    //

    while ( 1 )
    {
        WaitVBlank ();

        //
        // Special case: Launch Game Menu
        //

        if ( byte.[D + 2] & 0x40 && 
             (byte.[D + 0x53] == 0 && byte.[D + 0x5D] == 0) &&
             ((byte_7E0B61 & 0x1F) == 0 && (byte_7E0B63 & 0x1F) == 0) )
        {
                                                        // C0:00CF

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
            byte_7E0134 = 0;                    // Menu type

            SwitchToMenu ();                      // Run Menu

            byte.[D + 0x55] = 2;

            word_7E1088 = word_7E0AD8;

            ReloadMap ();                      // Reload map

            if ( byte_7E0139 == 0xF0 )
                sub_C0046A ( X = 0x22 );        // Party Rest: Small camp animation
            else if ( byte_7E0139 == 0xF1 )
                sub_C0046A ( X = 0x24 );        // Party Rest: Cottage animation
            else if ( byte_7E0139 == 0x3E )
                sub_C0046A ( X = 0x32 );        // Warp animation

            byte_7E16AA = 0;

            DisablePoisonWalk ();                // Disable poison walk effect

            continue;
        }

        //
        // Default case
        //

        sub_C0061A ();                                  // loc_C00147

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

        if ( word_7E0AD6 < 5 )
        {
            //
            // Case A: World Map
            //

                                                        // loc_C0016B

            sub_C0073E ();

            if ( byte.[D + 0x58] )
            {
                byte.[D + 0x58] = 0;
                continue;
            }

            if ( (byte.[D + 0x61] & 0x1F) == 0 && (byte.[D + 0x63] & 0x1F) == 0 )
            {
                if ( byte_7E0AD6 != 1 || byte_7E0AD9 != 0xA1 || byte_7E0AD8 < 0x9F || byte_7E0AD8 >= 0xA2 )
                {
                    if ( byte_7E0AD6 || byte_7E0ADC != 6 || byte_7E0AD8 < 0x3D || byte_7E0AD8 >= 0x43 
                         || byte_7E0AD9 < 0x9E || byte_7E0AD9 >= 0xA5 )
                    {
                        if ( ! ( byte_7E0AD6 !=2 || byte_7E0ADC < 5 || byte_7E0AD8 < 0xB6 || 
                                 byte_7E0AD8 >= 0xBA || byte_7E0AD9 < 0x87 || byte_7E0AD9 >= 0x8B ) )
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

            SelectWorldMonsterParty ();

            if ( byte.[D + 0x55] )
            {
                if ( sub_C0CA3C ( A = 0xFF ) == 0 )
                {
                    RandomBattle ();
                    word_7E1088 = word_7E0AD8;
                    ReloadMap ();
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
                    ReloadMap ();
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
            // Case B: Location Map
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

            SelectLocalMonsterParty ();

            if ( byte.[D + 0x55] )
            {
                if ( sub_C0CA3C ( A = 0xFF ) )
                {
                    RandomBattle ();
                    ReloadMap ();
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

// ------------------------------------------------------------------------------------------

// NMI Handler (VBlank)

NMI_Handler ()          // C0:02D1
{
    // D = 0xB00
    // DB = 0

    A = HW.NMI_ENABLE;
    A = HW.NMI_ENABLE;

    HW.REGULAR_DMA_CHANNEL_ENABLE = 0;

    byte.[D + 0x40] = 0;

    HW.ADD_SUBTRACT_SELECT_AND_ENABLE = byte.[D + 0x47];

    HW.BG_AND_OBJECT_ENABLE_SUB_SCREEN = byte.[D + 0x49];

    //
    // Handle PPU hardware
    //

    CgramDma ();            // Palette

    OamDma ();          // Sprites

    FadeControl ();         // Fade-in / Fade-out

    MosaicControl ();

    FixedColorControl ();

    //
    // VRAM DMA
    //

    if ( byte.[D + 0xA3] )
    {
        byte.[D + 0xA3] = 0;

        VramDma ();   
    }

    //
    // 3
    //

    if ( byte.[D + 0x52] == 0 )
    {
        if ( byte.[D + 0x53] )
        {
            if ( byte.[D + 0xA0] == 0 )
            {
                if ( byte.[D + 0xA5] == 0 )
                {
                    if ( byte.[D + 0xA6] == 0 )
                    {
                        if ( byte.[D + 0xA7] )
                            sub_C08E23 ();

                        sub_C08F78 ();

                        if ( byte.[D + 0x9F] )
                        {
                            byte.[D + 0x9F] = 0;

                            if ( byte.[D + 0x70] & 1 )
                            {
                                word.[D + 0x71] = 0;

                                sub_C06E7A ();

                                if ( (byte_7E1121 & 0x40) == 0 )
                                {
                                    word.[D + 0x71] = 0x1000;
                                    sub_C06E7A ();
                                }

                                if ( (byte_7E1121 & 0x80) == 0 )
                                {
                                    word.[D + 0x71] = 0x2000;
                                    sub_C06E7A ();
                                }                                       // Continue 3.1
                            }
                            else
                            {
                                word.[D + 0x71] = 0;

                                sub_C06DF5 ();

                                if ( (byte_7E1121 & 0x40) == 0 )
                                {
                                    word.[D + 0x71] = 0x1000;
                                    sub_C06DF5 ();                                    
                                }

                                if ( (byte_7E1121 & 0x80) == 0 )
                                {
                                    word.[D + 0x71] = 0x2000;
                                    sub_C06DF5 ();                                    
                                }                                       // Continue 3.1
                            }
                        }
                        else
                        {
                            if ( byte.[D + 0xA1] )
                            {
                                byte.[D + 0xA1] = 0;
                                sub_C01D1E ();   
                            }
                            else
                            {
                                if ( byte.[D + 0xA2] )
                                {
                                    byte.[D + 0xA2] = 0;
                                    sub_C01E14 ();   
                                }
                                else
                                    sub_C0996D ();   
                            }                               // Continue 3.1
                        }
                    }
                    else
                    {
                        byte.[D + 0xA6] = 0;
                        word.[D + 0x71] = 0;
                        sub_C06E7A ();
                        sub_C08BE4 ();

                        if ( byte.[D + 0xA2] )
                        {
                            byte.[D + 0xA2] = 0;
                            sub_C01E14 ();   
                        }
                        else
                            sub_C0996D ();
                    }                           // Continue 3.1
                }
                else
                {
                    byte.[D + 0xA5] = 0;
                    sub_C08BA4 ();
                }                           // Continue 3.1
            }
            else
            {
                byte.[D + 0xA0] = 0;
                sub_C05E2B ();
            }                           // Continue 3.1
        }
        else
        {
            sub_C0637E ();

            sub_C09695 ();

            sub_C0975F ();

            sub_C0964C ();

            sub_C09722 ();

            if ( byte.[D + 0x9F] )
            {
                byte.[D + 0x9F] = 0;

                if ( byte.[D + 0xBA] )
                {
                    if ( byte.[D + 0xBA] & 1 )
                        sub_C06465 ();
                    else
                        sub_C064BB ();
                }
            }

            if ( byte.[D + 0xA1] )
            {
                byte.[D + 0xA1] = 0;
                sub_C01D1E ();
            }
            else
            {
                if ( byte.[D + 0xA2] )
                {
                    byte.[D + 0xA2] = 0;
                    sub_C01E14 ();
                }
            }
        }

        //
        // 3.1
        //

        sub_C05E8A ();

        sub_C05F3E ();

        HW.H_DMA_CHANNEL_ENABLE = byte.[D + 0x5E];

        sub_C09A00 ();

        sub_C09799 ();

        sub_C04931 ();

        sub_C047AA ();
    }

    //
    // End
    //

    sub_C04C90 ();

    sub_C04D8E ();

    DWORD.FrameCounter++;

    byte.[D + 0x3F]++;
    byte.[D + 0x3E]++;
    byte.[D + 0x51]++;              // Polled in WaitVBlank
}

// ------------------------------------------------------------------------------------------

SetupIntHandlers ()             // C0:4E4A
{
    byte_7E1F00 = 0x5C;         // NMI Handler - C0:02D1
    word_7E1F01 = 0x02D1;
    byte_7E1F03 = 0xC0;

    byte_7E1F04 = 0x5C;         // IRQ Handler - C0:0446
    word_7E1F05 = 0x0446;
    byte_7E1F07 = 0xC0;
}

LoadMapFromSave ()                  // C0:545D
{
    if ( word_7E0AD6 >= 5 )
    {
        sub_C0574C ();          // Location Map
        sub_C06100 ();
        sub_C09267 ();
    }
    else
    {
        sub_C05528 ();          // World Map
        sub_C06100 ();
    }
}

ReloadMap ()                      // C0:5476
{
    if ( word_7E0AD6 >= 5 )
    {
        sub_C0577C ();          // Location Map
        sub_C06100 ();
        sub_C09267 ();
    }
    else
    {
        sub_C05532 ();          // World Map
        sub_C06100 ();
    }
}

SelectWorldMonsterParty ()      // C0:CB11
{
    if ( byte.[D + 0x5A] )      // Global random battle disabler
        return;

    if ( byte_7E0ADC )
    {
        if ( byte_7E0ADC == 6 )
        {
            if ( byte.[D + 0x6F] )
                return;
        }
        else if ( byte_7E0ADC != 5 )
        {
            return;
        }
    }

    if ( byte.[D + 0x56] == 0 )
        return;

    byte.[D + 0x56] = 0;

    //
    // 1
    //

    X = word_7E10C6 * 3;

    byte.[D + 8] = (byte_7E0AD6 & 1) << 4;

    X = (byte_7E1188[X] & 0xF) | byte.[D + 8];

    byte_7E04F2 = byte_C0CC21[X];

    if ( byte_7E0ADC >= 5 )
        byte_7E04F2 = 0x15;

    //
    // 2
    //

    byte.[D + 0x11] = unk_C0CC3A[X & 0xF];
    byte.[D + 0x12] = 0;

    byte.[D + 0xF] = unk_C0CC42[X & 0xF];
    byte.[D + 0x10] = 0;

    byte.[D + 0xD] = byte_7E0AD6 << 6;      // * 64
    byte.[D + 0xD] += (byte_7E0AD9 >> 2) & 0x38;

    X = byte_7E0AD8 >> 5 + byte.[D + 0xD];

    A = byte_D08400[X];

    Y = word.[D + 0x11];

    while (Y--)
        A >>= 1;

    A &= 3;

    //
    // 3
    //

    if ( A )
    {
        A16 = word_7E16A8 + word_C0CC4A[A];

        if ( Carry )         // ADC, BCS
            A16 = 0xFF00;

        word_7E16A8 = A16;

        A = Rand1 ();

        if ( A < byte_7E16A9 )
        {
            word.[D + 0xD] = (byte_7E0AD9 & 0xE0) << 1;

            word.[D + 0x23] = word.[D + 0xD] + (word_7E0AD8 >> 2) & 0x38;

            X = (SWAP(word_7E0AD6) << 1) + word.[D + 0x23] + word.[D + 0xF];

            X = word_D07A00[X / 2] << 3;    // * 8

            A = Rand2 ();               // Select one-of-four party

                                        // Party 0 ~ 35%
            if (A >= 90) X += 2;        // Party 1 ~ 35%
            if ( A >= 180) X += 2;      // Party 2 ~ 23%
            if ( A >= 240 ) X += 2;     // Party 3 ~ 6%

            word_7E04F0 = word_D06800[X / 2];       // Select monster party

            byte.[D + 0x55]++;              // Start random battle
        }
    }
}

.C0:CC21 00          unk_C0CC21:     .BYTE   0 
.C0:CC22 01                          .BYTE   1
.C0:CC23 02                          .BYTE   2
.C0:CC24 03                          .BYTE   3
.C0:CC25 04                          .BYTE   4
.C0:CC26 05                          .BYTE   5
.C0:CC27 03                          .BYTE   3
.C0:CC28 07                          .BYTE   7
.C0:CC29 08                          .BYTE   8
.C0:CC2A 00                          .BYTE   0
.C0:CC2B 00                          .BYTE   0
.C0:CC2C 00                          .BYTE   0
.C0:CC2D 00                          .BYTE   0
.C0:CC2E 00                          .BYTE   0
.C0:CC2F 00                          .BYTE   0
.C0:CC30 00                          .BYTE   0
.C0:CC31 21                          .BYTE $21 ; !
.C0:CC32 01                          .BYTE   1
.C0:CC33 02                          .BYTE   2
.C0:CC34 03                          .BYTE   3
.C0:CC35 04                          .BYTE   4
.C0:CC36 05                          .BYTE   5
.C0:CC37 03                          .BYTE   3
.C0:CC38 07                          .BYTE   7
.C0:CC39 08                          .BYTE   8

byte_C0CC3A:    .BYTE 3, 2, 1, 0, 3, 2, 1, 0

byte_C0CC42:    .BYTE 0, 2, 4, 6, 0, 2, 4, 6

word_C0CC4A:    .WORD $100, $10, $180, 0


RandomBattle ()                 // C0:CCF0
{
    word_7E16A8 = word.[D + 6];

    PlaySoundEffect ( 0x6F );   // Play start battle sound

    BattleMosaicEffect ();

    HW.REGULAR_DMA_CHANNEL_ENABLE = 0;
    HW.H_DMA_CHANNEL_ENABLE = 0;
    HW.NMI_V_H_COUNT_AND_JOYPAD_ENABLE = 0;
    HW.SCREEN_DISPLAY_REGISTER = 0x80;

    HW.SEI;             // Disable interrupts

    BattleStart ();

    PpuDisable ();

    if ( byte_7E09C4 & 1 )          // Game Over (party is wiped out)
    {
        byte3_7E1D00 = 0xF0;
        goto start;
    }

    A = byte_7E013B;            // Any item looted ? (Max = 8)
    A |= byte_7E013C;
    A |= byte_7E013D;
    A |= byte_7E013E;
    A |= byte_7E013F;
    A |= byte_7E0140;
    A |= byte_7E0141;
    A |= byte_7E0142;

    if ( A )              // Loot Menu
    {
        byte_7E0134 = 1;        // Menu type

        ShowMenu ();
    }

    sub_C01CD7 ();
}

Emulation_mode_RESET ()         // C0:CEC0
{
    HW.SEI;        // Interrupt disable
    HW.CLC;
    HW.XCE;        // Native mode enabled

    goto start;
}

//
// Random data (for Rand1 / Rand2 procedures), 256 bytes
//

RandomData:                             // C0:FEC0

    .BYTE 7, $B6, $F0, $1F, $55, $5B, $37, $E3, $AE, $4F, $B2
    .BYTE $5E, $99, $F6, $77, $CB, $60, $8F, $43, $3E, $A7
    .BYTE $4C, $2D, $88, $C7, $68, $D7, $D1, $C2, $F2, $C1
    .BYTE $DD, $AA, $93, $16, $F7, $26, 4, $36, $A1, $46, $4E
    .BYTE $56, $BE, $6C, $6E, $80, $D5, $B5, $8E, $A4, $9E
    .BYTE $E7, $CA, $CE, $21, $FF, $F, $D4, $8C, $E6, $D3
    .BYTE $98, $47, $F4, $D, $15, $ED, $C4, $E4, $35, $78
    .BYTE $BA, $DA, $27, $61, $AB, $B9, $C3, $7D, $85, $FC
    .BYTE $95, $6B, $30, $AD, $86, 0, $8D, $CD, $7E, $9F, $E5
    .BYTE $EF, $DB, $59, $EB, 5, $14, $C9, $24, $2C, $A0, $3C
    .BYTE $44, $69, $40, $71, $64, $3A, $74, $7C, $84, $13
    .BYTE $94, $9C, $96, $AC, $B4, $BC, 3, $DE, $54, $DC, $C5
    .BYTE $D8, $C, $B7, $25, $B, 1, $1C, $23, $2B, $33, $3B
    .BYTE $97, $1B, $62, $2F, $B0, $E0, $73, $CC, 2, $4A, $FE
    .BYTE $9B, $A3, $6D, $19, $38, $75, $BD, $66, $87, $3F
    .BYTE $AF, $F3, $FB, $83, $A, $12, $1A, $22, $53, $90
    .BYTE $CF, $7A, $8B, $52, $5A, $49, $6A, $72, $28, $58
    .BYTE $8A, $BF, $E, 6, $A2, $FD, $FA, $41, $65, $D2, $4D
    .BYTE $E2, $5C, $1D, $45, $1E, 9, $11, $B3, $5F, $29, $79
    .BYTE $39, $2E, $2A, $51, $D9, $5D, $A6, $EA, $31, $81
    .BYTE $89, $10, $67, $F5, $A9, $42, $82, $70, $9D, $92
    .BYTE $57, $E1, $3D, $F1, $F9, $EE, 8, $91, $18, $20, $B1
    .BYTE $A5, $BB, $C6, $48, $50, $9A, $D6, $7F, $7B, $E9
    .BYTE $76, $DF, $32, $6F, $34, $A8, $D0, $B8, $63, $C8
    .BYTE $C0, $EC, $4B, $E8, $17, $F8

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
