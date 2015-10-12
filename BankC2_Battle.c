// C2:0000 ... C2:A000 - Battle Engine  ~550 procedures
//

BattleStart ()          // C2:0000
{
    InitBattleMem ();       // DB = 0x7E
                            // D = 0

    //
    // Increase global battle counter
    //

    C = GlobalBattleCount + 1;

    if ( Carry )
        C = 0xFFFF;

    GlobalBattleCount = C;

    //
    // Run battle engine until RepeatBattle is set
    //

    RepeatBattle = 0;

    do
    {
        BattleMain ();

        byte_7E420C = 0;
        byte_7E420B = 0;
        byte_7E4200 = 0;
    } while ( RepeatBattle );

    InitBattleMem ();
}

BattleMain ()           // C2:4CE0
{
        // Summary external ROM Usage:
        //      D1:2976 - Copy defaults
        //      D0:ECF2 - Set BattleMode
        //      D0:3000 - Copy monster party data based on index 
        //      D0:0000
        //      D0:2000
        //      D0:8900 - Monster party Ids

    ResetBattleVars ();

    //
    // Entropy 1
    //

    A = 0;
    X = 0;
    while (X != 1000)
    {
        A += byte_7E0000[X];
        X++;
    }

    A += byte_7E0AF9;

    byte.[D + 0x3A] = A;

    //
    // Entropy 2
    //

    while ( X != 2000 )
    {
        A += byte_7E0000[X];
        X++;
    }

    byte.[D + 0x3B] = A;

    //
    // Copy defaults 1
    //

    memcpy ( 7E:3ED9, D1:2976, 0xB );

    //
    // Set BattleMode based upon Battle speed / mode settings
    //

    BattleMode = byte_D0ECF2[byte_7E0970 & 0xF];

    //
    // Copy monster party data from D0:3000
    //

    X = word_7E04F0 << 4;           // Monster party index

    memcpy ( byte_7E3EEF, unk_D03000 + X, 0x10 );

    //
    // 1
    //

    sub_C24E25 ();

    //
    // Count monsters (?)
    //

    X = Y = 0;

    do
    {
        A = byte_7E3EF3[X];
        byte_7E4020[Y] = A;

        if ( A != 0xFF )
        {
            if ( byte_7E3EFE & 0x20 )
                byte_7E4021[Y] = 1;
        }
        else
            byte_7E4021[Y] = 0xFF;

        X++;
        Y += 2;
    } while (Y != 8*2);

    //
    // Monster party related (?) 
    //

    word.[D + 0x10] = 0;
    byte.[D + 0x14] = 0xD0;
    word.[D + 0x12] = 0;            // D0:0000

    if ( byte_7E4021[0] )
    {
        byte.[D + 0x14] = 0xD0;
        word.[D + 0x12] = 0x2000;       // D0:2000
    }

    X = 0;

    do
    {
        Y = word.[D + 0x10];
        A = byte_7E3EF3[Y];
        Y = A << 5;             // *32

        byte.[D + 0xE] = 0;

        do
        {
            A = byte.[ tword.[D + 0x12] + Y];
            byte_7E3EFF[X] = A;

            X++;
            Y++;

            byte.[D + 0xE]++;
        } while ( byte.[D + 0xE] != 0x20 );

        byte.[D + 0x10]++;
    } while ( byte.[D + 0x10] != 8 );

    //
    // 2
    //

    byte_7E3FFF = byte_7E3EF2;
    byte_7E4048 = byte_7E3EF2;
    byte_7E7C09 = byte_7E3EF2;
    byte_7E7C0A = byte_7E3EF2 ^ 0xFF;

    A = byte_7E3EF2;
    X = 0;
    do
    {
        A <<= 1;

        if ( Carry )
            byte_7E4018[X]++;

        X++;
    } while ( X != 8 );

    //
    // Copy monster Ids (max. 8 per party)
    //

    X = word_7E04F0;         // Monster party index

    Y = 0;
    do
    {
        byte_7E4000[Y] = byte_D08900[X];

        X++;
        Y++;
    } while (Y != 8);

    //
    // 4
    //

    X = 0;
    do
    {
        A = byte_7E3EF3[X];

        if ( A == 0xFF )
        {
            byte_7E7C09 |= 0x80 >> X;
        }

        X++;
    } while (X != 8);

    // 
    // 5
    //

    sub_C23EA2 ();

    sub_C241AF ();

    sub_C21FD2 ();

    sub_C22447 ();

    sub_C25A41 ();

    sub_C25921 ();

    sub_C2505C ();

    sub_C24F7A ();

    CallBattleFX (2);

    sub_C24E9F ();

    if ( byte_7E3C5F )
        CallBattleFX (0xa);

    goto BattleLoop;
}

ResetBattleVars ()      // C2:4F0A
{
    memclr ( 7E:0000, 7E:0067 );

    memclr ( 7E:2000, 7E:7CD7 );

    byte_7E41A9 = 0xFF;
    byte_7E41AA = 0xFF;
    byte_7E41AB = 0xFF;
    byte_7E41AC = 0xFF;
    byte_7E41AD = 0xFF;
    byte_7E41CC = 0xFF;
    byte_7E7C4B = 0xFF;

    memset ( 7E:384C, 0xFF, 0x200 );      // 0x200 bytes

    memcpy ( 7E:7C74, 7E:09B4, 0x20 );      // 7E:09B5  -- Flee Counter

    byte_7E7C94 = byte_7E0AFB;          // Nothing Happened?
    byte_7E7C95 = byte_7E0AFC;          // Some count-down counter
    byte_7E7C96 = byte_7E0AFD;
    byte_7E7C72 = 1;
    byte_7E2200 = 0x40;
    byte_7E2280 = 0x40;
    byte_7E2300 = 0x40;
    byte_7E2380 = 0x40;
    byte_7E2400 = 0x40;
    byte_7E2480 = 0x40;
    byte_7E2500 = 0x40;
    byte_7E2580 = 0x40;
}

BattleLoop ()               // C2:5872
{
    while (1)
    {

    }
}
