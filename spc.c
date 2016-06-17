// FFV SPC Engine
// C4:0000

// SPC Entrypoint : 0x200

//
// Thunks
//

SpcInit ()              // C4:0000
{
    goto SpcInitReal;    
}

SpcCommand ()           // C4:0004
{
    goto SpcCommandReal;
}

// Chunks offsets (Bank C4)

// .C4:0008 4D 06       word_C40008:    .WORD $64D              ; DATA XREF: SpcInitReal+78r
// .C4:000A 95 1F                       .WORD $1F95
// .C4:000C 3F 1E                       .WORD $1E3F
// .C4:000E 4F 1F                       .WORD $1F4F
// .C4:0010 71 1F                       .WORD $1F71
// .C4:0012 83 1F                       .WORD $1F83

// Target address 

// .C4:0014 00 02       word_C40014:    .WORD $200              ; DATA XREF: SpcInitReal+5Ar
// .C4:0014                                                     ; SpcInitReal+BEr ...
// .C4:0016 00 2C                       .WORD $2C00
// .C4:0018 00 48                       .WORD $4800
// .C4:001A 00 1B                       .WORD $1B00
// .C4:001C 80 1A                       .WORD $1A80
// .C4:001E 00 1A                       .WORD $1A00

/*
    SPC program chunks:

[0] : C4:064D => 0x200                  0x17F0 bytes
[1] : C4:1F95 => 0x2C00                 0x1C00
[2] : C4:1E3F => 0x4800                 0x10E
[3] : C4:1F4F => 0x1B00                 0x20
[4] : C4:1F71 => 0x1A80                 0x10
[5] : C4:1F83 => 0x1A00                 0x10


*/

// -------------------------------------------------------------------------------
// SPC Init
//


// To properly manipulate this into uploading your data, the following procedure
// seems to work:
//  1. Wait for a 16-bit read on $2140-1 to return $BBAA.
//  2. Write the target address to $2142-3.
//  3. Write non-zero to $2141.
//  4. Write $CC to $2140.
//  5. Wait until reading $2140 returns $CC.
//  6. Set your first byte to $2141.
//  7. Set your byte index ($00 for the first byte) to $2140.
//  8. Wait for $2140 to echo your byte index.
//  9. Go back to step 6 with your next byte and ++index until you're done.
// 10. If you want to write another block, write the next address to $2142-3,
//     non-zero to $2141, and index+2 (or +3 if that would be zero, otherwise
//     it'll screw up the next transfer) to $2140 and wait for the echo. Then go
//     to step 6 with index=0.
// 11. Otherwise, you can jump to some code you've just uploaded. Put the target
//     address in $2142-3, $00 in $2141, and index+2 in $2140 and wait for the
//     echo. Shortly afterwards, your code will be executing.

SpcInitReal ()          // C4:002C
{
    // A8, I16

    D = 0x1D00;

    X = 0xBBAA;
    Y = 0x800;          // Timeout value

    //
    // Wait for a 16-bit read on $2140-1 to return $BBAA
    //

    while (1)
    {
        if ( *(PUSHORT)APU_I_O_PORT_0 == 0xBBAA )
            break;

        Y--;
        if ( Y != 0 )
            continue;

        //
        // Timeout expired (do soft reset)
        //

        if ( *(PUSHORT)(D + 0xF8) != 0 && 
             *(PUSHORT)(D + 0x48) == 0 &&
             *(PUCHAR)(D + 0) == 0xF0 )
        {
            //
            // Special case -- Soft Reset
            //

            APU_I_O_PORT_1 = 8;
            APU_I_O_PORT_0 = 0;

            //
            // Clear SPC Data
            //

            memset ( 0x7E1D00, 0, 0xf8 );

            *(PUSHORT)(D + 0x48) = *(PUSHORT)(D + 0xF8);
            *(PUCHAR)(D + 5) = 0xFF;
            *(PUCHAR)(D + 0) = 0xF0;

            goto SpcCommandLoop;
        }
    }

    while ( *(PUSHORT)APU_I_O_PORT_0 != 0xBBAA ) ;      // Wait BBAA

    // Write the target address to $2142-3
    // Write non-zero to $2141
    // Write $CC to $2140

    APU_I_O_PORT_2 = byte_C40014[0];           // Target address[0]: 0x200
    APU_I_O_PORT_3 = unk_C40015[0];
    APU_I_O_PORT_1 = 0xCC;
    APU_I_O_PORT_0 = 0xCC;    

    //
    // Wait until reading $2140 returns $CC
    //

    while ( APU_I_O_PORT_0 != 0xCC ) ;         // Wait

    //
    // Transfer SPC Program
    //

    X = 0;

    while (1)
    {
        B = 0;

        *(PUCHAR)(D + 0x14) = unk_C40008 + X;           // Set long pointer
        *(PUCHAR)(D + 0x15) = unk_C40009 + X;
        *(PUCHAR)(D + 0x16) = 0xC4;

        *(PUCHAR)(D + 0x10) = *(D + 0x14)[0] + 2;       // Length (+2 for extra index)
        *(PUCHAR)(D + 0x11) = *(D + 0x14)[1];

        Y = 2;

        while (1)
        {
            APU_I_O_PORT_1 = *(D + 0x14)[Y];
            APU_I_O_PORT_0 = B;

            while ( APU_I_O_PORT_0 != B ) ;         // Wait

            B++;

            Y++;
            if (Y == *(PUSHORT)(D + 0x10))
                break;
        }

        B += 3;
        if ( B == 0 )
            B++;

        X += 2;                 // Set next chunk
        if ( X == 0xC)
            break;

        APU_I_O_PORT_2 = byte_C40014[X];            // Set another target address
        APU_I_O_PORT_3 = byte_C40015[X];

        APU_I_O_PORT_1 = B;
        APU_I_O_PORT_0 = B;

        while ( APU_I_O_PORT_0 != B ) ;             // Wait
    }

    //
    // Run SPC Program
    //

    *(PUSHORT)APU_I_O_PORT_2 = 0x200;
    APU_I_O_PORT_1 = 0;
    APU_I_O_PORT_0 = 0;

    while ( APU_I_O_PORT_0 != 0 ) ;             // Wait

    APU_I_O_PORT_0 = 0;

    memset ( 0x7E1D00, 0, 0x100 );          // Clear SPC Data

    *(PUCHAR)(D + 5) = 0xFF;

    A16 = *(PUSHORT)SPC_Prg_2 + 0x4800;         // Free SPC RAM start address
    *(PUSHORT)(D + 0xF8) = A16;
    *(PUSHORT)(D + 0x48) = A16;

    //
    // Sleep, shortly afterwards SPC program begin to executing.
    //

    X = 0x800;
    while (X--) ;
}

// ------------------------------------------------------------------------------
// SPC Command
//

