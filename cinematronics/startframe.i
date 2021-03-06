void startFrame_ripoff(void) {
  /*
DIP_START(ripoff_dips)
 DIP_SET4(DIPSW1,0xfc,"Units",0x00,"8",0x01,"16",0x02,"4",0x03,"12",3)
 DIP_SET4(DIPSW1,0xf3,"Coins",0x08,"2Coins 1Credit",0x00,"4Coins 3Credits",0x0c,"1Coin 1Credit",0x04,"2Coins 3Credits",2)
 DIP_SET2(DIPSW1,0xef,"Attract Sound",0x10,"Off",0x00,"On",0)
 DIP_SET2(DIPSW1,0xdf,"Scores",0x20,"Individual",0x00,"Combined",0)
 DIP_SET2(DIPSW1,0xbf,"Diagnostic",0x00,"Off",0x40,"On",0)
DIP_END
   */
#define RO_IO_P1START   0x02  // 1-player start
#define RO_IO_P1LEFT    0x1000
#define RO_IO_P1RIGHT   0x4000
#define RO_IO_P1THRUST  0x8000
#define RO_IO_P1FIRE    0x2000

#define RO_IO_P2START   0x08  // 2-player start
#define RO_IO_P2LEFT    0x01
#define RO_IO_P2RIGHT   0x04
#define RO_IO_P2THRUST  0x10
#define RO_IO_P2FIRE    0x20
  
#define RO_SW_ABORT   SW_ABORT	/* for ioSwitches */
#define RO_SW_COIN    0x080
  
   static int prevButtonState=0;	// for debouncing

   frameCounter += 1;
   DEBUG_OUT("// Frame %d\n", frameCounter);

   v_WaitRecal ();
   // v_doSound();
   v_readButtons ();		// update currentButtonState
   v_readJoystick1Analog ();
   //v_readJoystick2Analog ();  // Apparently we are getting joystick 2 data anyway?????
   // v_playAllSFX();

   // Unfortunately, it's quite common to press LEFT and RIGHT simultaneously by accident with this
   // layout, and accidentally invoke the configuration screen.  Need to think about how we will
   // handle this...
   
   // default inactive:
   ioInputs = initialInputs | RO_IO_P1LEFT | RO_IO_P1RIGHT | RO_IO_P1THRUST | RO_IO_P1FIRE | RO_IO_P1START | 
                              RO_IO_P2LEFT | RO_IO_P2RIGHT | RO_IO_P2THRUST | RO_IO_P2FIRE | RO_IO_P2START;
   ioSwitches = initialSwitches | RO_SW_COIN;

   // digital joysticks...
   if (currentJoy1X < -30) ioInputs &= ~RO_IO_P1LEFT;
   if (currentJoy1X > 30) ioInputs &= ~RO_IO_P1RIGHT;
   if (currentJoy1Y > 30) ioInputs &= ~RO_IO_P1THRUST;

   if (currentJoy2X < -30) ioInputs &= ~RO_IO_P2LEFT;
   if (currentJoy2X > 30) ioInputs &= ~RO_IO_P2RIGHT;
   if (currentJoy2Y > 30) ioInputs &= ~RO_IO_P2THRUST;

   // would be helpful to examine ram and make these context-dependent

   if ((currentButtonState & ~prevButtonState) & (VEC_BUTTON_1_1 | VEC_BUTTON_2_1)) ioSwitches &= ~RO_SW_COIN;	// only on rising edge
   if (currentButtonState & VEC_BUTTON_1_2) ioInputs &= ~RO_IO_P1START; // needs 1 coin
   if (currentButtonState & VEC_BUTTON_2_2) ioInputs &= ~RO_IO_P2START; // needs 2 coins and second controller

   if (currentButtonState & VEC_BUTTON_1_1) ioInputs &= ~RO_IO_P1LEFT;
   if (currentButtonState & VEC_BUTTON_1_2) ioInputs &= ~RO_IO_P1RIGHT;
   if (currentButtonState & VEC_BUTTON_1_3) ioInputs &= ~RO_IO_P1THRUST;
   if (currentButtonState & VEC_BUTTON_1_4) ioInputs &= ~RO_IO_P1FIRE;

   if (currentButtonState & VEC_BUTTON_2_1) ioInputs &= ~RO_IO_P2LEFT;
   if (currentButtonState & VEC_BUTTON_2_2) ioInputs &= ~RO_IO_P2RIGHT;
   if (currentButtonState & VEC_BUTTON_2_3) ioInputs &= ~RO_IO_P2THRUST;
   if (currentButtonState & VEC_BUTTON_2_4) ioInputs &= ~RO_IO_P2FIRE;
   prevButtonState = currentButtonState;

#ifdef NEVER
  /*
# Initialization file for Rip Off (Single Player)
>
>*** Rip Off (Single Player) ***
>
>Keyboard Mapping:
>
>   One Player  = F1
>   Two Players = F2
>   Coin        = F3
>   Reset Game  = F4
>   Exit        = <Esc>
>
>   Left        = 'Z'
>   Right       = 'X'
>   Thrust      = '.'
>   Fire        = '/'

 ; Switch definitions:
 ;
 ;   D------  0=Normal, 1=Diagnostics
 ;   -O-----  0=Individual Scores, 1=Combined Scores
 ;   --S----  0=Sound in attract mode, 1=No Sound (sound not supported)
 ;
 ;   ---CC--  11 = 1 credit per 1 quarter
 ;            10 = 1 credit per 2 quarters
 ;            01 = 3 credits per 2 quarters
 ;            00 = 3 credits per 4 quarters
 ;
 ;   -----TT  11 = 12 fuel pods
 ;            10 = 4 fuel pods
 ;            00 = 8 fuel pods
 ;            01 = 16 fuel pods

 Switches=0011101

[Inputs]
 RstCPU  = 02000000,FFFFFFFF,00000000,FFFFFFFF	; Set bit indicating RESET
 Exit    = 01000000,FFFFFFFF,00000000,FFFFFFFF	; Set bit indicating Exit 
 Coin    = 00000000,FFFFFFFF,00000000,FF7FFFFF

 Player1 = 00000000,FFFFFFFD,00000002,FFFFFFFF
 Player2 = 00000000,FFFFFFF7,00000008,FFFFFFFF

 RFire   = 00000000,FFFFDFFF,00002000,FFFFFFFF
 RThrust = 00000000,FFFF7FFF,00008000,FFFFFFFF
 RRight  = 00000000,FFFFBFFF,00004000,FFFFFFFF
 RLeft   = 00000000,FFFFEFFF,00001000,FFFFFFFF

 LFire   = 00000000,FFFFFFDF,00000020,FFFFFFFF
 LThrust = 00000000,FFFFFFEF,00000010,FFFFFFFF
 LRight  = 00000000,FFFFFFFB,00000004,FFFFFFFF
 LLeft   = 00000000,FFFFFFFE,00000001,FFFFFFFF
   */
#endif
}

#ifdef NEVER
void spacewar_input()
{
  //Spacewar inputs
  ioInputs = 0xffff;

  ioSwitches = 0x00cf; //00ff=45 00ef=2min  00df 1:30 00cf 1min
  // if (GkeyCheck(config.kcoin1)){ioSwitches &= ~SW_COIN;}

  if (key[config.kp1left])   {ioInputs -= 0x0100;}
  if (key[config.kp1right])  {ioInputs -= 0x2000;}
  if (key[config.kp1but1])   {ioSwitches -= 0x04;}
  if (key[config.kp1but2])   {ioInputs -= 0x8000;}
  if (key[config.kp1but3])   {ioSwitches -= 0x02;}

  if (key[config.kp2left])   {ioInputs -= 0x4000;}
  if (key[config.kp2right])  {ioInputs -= 0x1000;}
  if (key[config.kp2but1])   {ioSwitches -= 0x01;}
  if (key[config.kp2but2])   {ioInputs -= 0x0200;}
  if (key[config.kp2but3])   {ioSwitches -= 0x08;}

  if (key[config.pad9])   {ioInputs -= 0x0008;}
  if (key[config.pad8])   {ioInputs -= 0x0002;}
  if (key[config.pad7])   {ioInputs -= 0x0080;}
  if (key[config.pad6])   {ioInputs -= 0x0020;}
  if (key[config.pad5])   {ioInputs -= 0x0400;}
  if (key[config.pad4])   {ioInputs -= 0x0004;}
  if (key[config.pad3])   {ioInputs -= 0x0001;}
  if (key[config.pad2])   {ioInputs -= 0x0040;}
  if (key[config.pad1])   {ioInputs -= 0x0010;}
  if (key[config.pad0])   {ioInputs -= 0x0800;}
}
#endif

void startFrame_spacewars(void) {

#define SW_IO_P1LEFT    0x0100
#define SW_IO_P1RIGHT   0x2000
#define SW_IO_P1THRUST  0x8000

#define SW_SW_P1FIRE    0x04
#define SW_SW_P1HYPER   0x02  // not yet assigned to a key

#define SW_IO_P2LEFT    0x4000
#define SW_IO_P2RIGHT   0x1000
#define SW_IO_P2THRUST  0x0200

#define SW_SW_P2FIRE    0x01
#define SW_SW_P2HYPER   0x08  // not yet assigned to a key

// not yet assigned to keys:
#define SW_IO_Zero    0x0800
#define SW_IO_One     0x0010
#define SW_IO_Two     0x0040
#define SW_IO_Three   0x0001
#define SW_IO_Four    0x0004
#define SW_IO_Five    0x0400
#define SW_IO_Six     0x0020
#define SW_IO_Seven   0x0080
#define SW_IO_Eight   0x0002
#define SW_IO_Nine    0x0008

#define SW_SW_ABORT   SW_ABORT	/* for ioSwitches */
#define SW_SW_COIN    0x080

   // Default of Switches=0000011 doesn't seem compatible with SW_SW_P2FIRE=0x01 and SW_SW_P1HYPER=0x02
   // Code from AAE above suggests the duration bits are the high two bits rather than the low two,
   // so either we have a big/little-endian situation, or it's something to do with the shuffling of
   // switch bits also mentioned in the AAE code. (not shown)
  
   static int prevButtonState=0;	// for debouncing

   frameCounter += 1;
   DEBUG_OUT("// %d\n", frameCounter);

   v_WaitRecal ();
   // v_doSound();
   v_readButtons ();		// update currentButtonState
   v_readJoystick1Analog ();
   //v_readJoystick2Analog ();  // NOT YET IMPLEMENTED.
   // v_playAllSFX();

   // Unfortunately, it's quite common to press LEFT and RIGHT simultaneously by accident with this
   // layout, and accidentally invoke the configuration screen.  Need to think about how we will
   // handle this...
   
   // default inactive:
   ioInputs = initialInputs | 0xffff;
   ioSwitches = initialSwitches | 0x00cf; // force for now...

   ioInputs |= SW_IO_P1LEFT | SW_IO_P1RIGHT | SW_IO_P1THRUST
             | SW_IO_P2LEFT | SW_IO_P2RIGHT | SW_IO_P2THRUST
             | SW_IO_Zero | SW_IO_One | SW_IO_Two | SW_IO_Three | SW_IO_Four | SW_IO_Five | SW_IO_Six | SW_IO_Seven | SW_IO_Eight | SW_IO_Nine;

   ioSwitches |= SW_SW_COIN  | SW_SW_P1FIRE | SW_SW_P1HYPER | SW_SW_P2FIRE | SW_SW_P2HYPER;
   if ((currentButtonState & ~prevButtonState) & (VEC_BUTTON_1_1|VEC_BUTTON_1_1)) ioSwitches &= ~SW_SW_COIN;	// only on rising edge
   prevButtonState = currentButtonState;

   // digital joysticks
   if (currentJoy1X < -30) ioInputs &= ~SW_IO_P1LEFT;
   if (currentJoy1X > 30) ioInputs &= ~SW_IO_P1RIGHT;
   if (currentJoy1Y < -30) ioSwitches &= ~SW_SW_P1HYPER;
   if (currentJoy1Y > 30) ioInputs &= ~SW_IO_P1THRUST;

   if (currentJoy2X < -30) ioInputs &= ~SW_IO_P2LEFT;
   if (currentJoy2X > 30) ioInputs &= ~SW_IO_P2RIGHT;
   if (currentJoy2Y < -30) ioSwitches &= ~SW_SW_P2HYPER;
   if (currentJoy2Y > 30) ioInputs &= ~SW_IO_P2THRUST;

   if (currentButtonState & VEC_BUTTON_1_1) ioInputs &= ~SW_IO_P1LEFT;
   if (currentButtonState & VEC_BUTTON_1_2) ioInputs &= ~SW_IO_P1RIGHT;
   if (currentButtonState & VEC_BUTTON_1_3) ioInputs &= ~SW_IO_P1THRUST;
   if (currentButtonState & VEC_BUTTON_1_4) ioSwitches &= ~SW_SW_P1FIRE;

   if (currentButtonState & VEC_BUTTON_2_1) ioInputs &= ~SW_IO_P2LEFT;
   if (currentButtonState & VEC_BUTTON_2_2) ioInputs &= ~SW_IO_P2RIGHT;
   if (currentButtonState & VEC_BUTTON_2_3) ioInputs &= ~SW_IO_P2THRUST;
   if (currentButtonState & VEC_BUTTON_2_4) ioSwitches &= ~SW_SW_P2FIRE;

#ifdef NEVER
  /*
# Initialization file for Space Wars
>
>*** Space Wars ***
>
>Keyboard Mapping:
>
>   Coin       = F3
>   Reset Game = F4
>   Exit       = <Esc>
>
>   Left Player       Right Player
>   ------------      ----------------------------------
>   Left   = 'Q'       Left   = Keypad '7'
>   Right  = 'A'       Right  = Keypad '5'
>   Walk   = 'X'       Walk   = Keypad '9'
>   Fire   = 'C'       Fire   = Keypad '-' or <Sysreq>
>   HyperS = <Alt>     HyperS = Keypad '+' or <Enter>
>   HyperS = <Ctrl>
>
>   Option keys     = '0'-'9'
>   Space War RESET = <Backspace>

 ; Switch definitions:
 ;
 ;   XXXXX--  Unused (Must be 0)
 ;
 ;   -----TT  00 = 0:45 minutes per coin
 ;            11 = 1:00 minutes per coin
 ;            10 = 1:30 minutes per coin
 ;            01 = 2:00 minutes per coin

 Switches=0000011

[Inputs]
 RstCPU   = 02000000,FFFFFFFF,00000000,FFFFFFFF	; Set bit indicating reset
 Exit     = 01000000,FFFFFFFF,00000000,FFFFFFFF ; Set bit indicating Exit 
 Coin     = 00000000,FFFFFFFF,00000000,FF7FFFFF

 ; Options

 Zero    = 00000000,FFFFF7FF,00000800,FFFFFFFF
 One     = 00000000,FFFFFFEF,00000010,FFFFFFFF
 Two     = 00000000,FFFFFFBF,00000040,FFFFFFFF
 Three   = 00000000,FFFFFFFE,00000001,FFFFFFFF
 Four    = 00000000,FFFFFFFB,00000004,FFFFFFFF
 Five    = 00000000,FFFFFBFF,00000400,FFFFFFFF
 Six     = 00000000,FFFFFFDF,00000020,FFFFFFFF
 Seven   = 00000000,FFFFFF7F,00000080,FFFFFFFF
 Eight   = 00000000,FFFFFFFD,00000002,FFFFFFFF
 Nine    = 00000000,FFFFFFF7,00000008,FFFFFFFF

 Reset   = 00000000,FFBFFFFF,00400000,FFFFFFFF

 ; Left player

 LLeft   = 00000000,FFFFFEFF,00000100,FFFFFFFF
 LRight  = 00000000,FFFFDFFF,00002000,FFFFFFFF
 LThrust = 00000000,FFFF7FFF,00008000,FFFFFFFF
 LFire   = 00000000,FFFBFFFF,00040000,FFFFFFFF
 LHyper  = 00000000,FFFDFFFF,00020000,FFFFFFFF

 ; Right player

 RLeft   = 00000000,FFFFBFFF,00004000,FFFFFFFF
 RRight  = 00000000,FFFFEFFF,00001000,FFFFFFFF
 RThrust = 00000000,FFFFFDFF,00000200,FFFFFFFF
 RFire   = 00000000,FFFEFFFF,00010000,FFFFFFFF
 RHyper  = 00000000,FFF7FFFF,00080000,FFFFFFFF
   */
#endif
}

void startFrame_boxingbugs(void) {
#define BB_SW_ABORT    SW_ABORT	/* for ioSwitches */
#define BB_SW_COIN     0x80

#define BB_IO_P1Panic  0x08 // Right Panic / One Player
#define BB_IO_P1Glove  0x10 // Right Glove
#define BB_IO_P1Cannon 0x20 // Right Cannon
#define BB_IO_P2Cannon 0x01 // Left Cannon
#define BB_IO_P2Glove  0x02 // Left Glove
#define BB_IO_P2Panic  0x04 // Left Panic / Two Player

#define BB_IO_Acct     0x40 // Accounting info on/off - is this a switch?

   static int prevButtonState=0;	// for debouncing
   frameCounter += 1;
   DEBUG_OUT("v_WaitRecal(); v_setBrightness(64);v_readButtons();v_readJoystick1Analog(); // %d\n", frameCounter);

   v_WaitRecal ();
   // v_doSound();
   v_readButtons ();		// update currentButtonState
   v_readJoystick1Analog ();
   // v_playAllSFX();

   ioSwitches = initialSwitches | BB_SW_COIN;
   ioInputs = initialInputs | BB_IO_P1Cannon | BB_IO_P1Glove | BB_IO_P1Panic | BB_IO_P2Cannon | BB_IO_P2Glove | BB_IO_P2Panic | BB_IO_Acct;

   if ((currentButtonState & ~prevButtonState) & (VEC_BUTTON_1_1 | VEC_BUTTON_2_1)) ioSwitches &= ~BB_SW_COIN;	// only on rising edge
   prevButtonState = currentButtonState;


   // this game needs special handling for the joystick... TO DO.

   // testing both to see which one it is...
   if (currentButtonState & VEC_BUTTON_1_1) ioInputs &= ~BB_IO_Acct;   // right does inputs
   
   if (currentButtonState & VEC_BUTTON_1_2) ioInputs &= ~BB_IO_P1Cannon;
   if (currentButtonState & VEC_BUTTON_1_3) ioInputs &= ~BB_IO_P1Glove;
   if (currentButtonState & VEC_BUTTON_1_4) ioInputs &= ~BB_IO_P1Panic;

   if (currentButtonState & VEC_BUTTON_2_2) ioInputs &= ~BB_IO_P2Cannon;
   if (currentButtonState & VEC_BUTTON_2_3) ioInputs &= ~BB_IO_P2Glove;
   if (currentButtonState & VEC_BUTTON_2_4) ioInputs &= ~BB_IO_P2Panic;

#ifdef NEVER
  /*
# Initialization file for Boxing Bugs
>
>*** Boxing Bugs ***
>
>Keyboard Mapping:
>
>   One Player  = F1
>   Two Players = F2
>   Coin        = F3
>   Reset Game  = F4
>   Exit        = <Esc>
>
>   Cannon      = First (Left) Mouse Button
>   Glove       = Second Mouse Button
>   Panic       = Third Mouse Button
>   Panic       = <Spacebar>  (For the "third button challenged" mice)
>
>   Use mouse to aim Cannon/Glove.

; Switch definitions:
 ;
 ;   D------  0=Normal, 1=Diagnositic Mode
 ;   -F-----  0=Normal, 1=Free Play
 ;   --S----  0=No sound during attract, 1=Sound during attract (sound not supported)
 ;   ---B---  0=Bonus at 50k, 1=Bonus at 30k
 ;   ----P--  0=3 cannons per game, 1=5 cannons per game
 ;
 ;   -----CC  00 = 1 credit per 1 quarter
 ;            10 = 1 credit per 2 quarters
 ;            01 = 3 credits per 2 quarters
 ;            11 = 3 credits per 4 quarters

 Switches=0001100

[Inputs]
 RstCPU  = 02000000,FFFFFFFF,00000000,FFFFFFFF	; Set bit indicating RESET
 Exit    = 01000000,FFFFFFFF,00000000,FFFFFFFF	; Set bit indicating Exit 
 Coin    = 00000000,FFFFFFFF,00000000,FF7FFFFF

 ; Define Boxing Bug control panel

 LCannon = 00000000,FFFFFFFE,00000001,FFFFFFFF ; Left Cannon
 LGlove  = 00000000,FFFFFFFD,00000002,FFFFFFFF ; Left Glove
 LPanic  = 00000000,FFFFFFFB,00000004,FFFFFFFF ; Left Panic / Two Player
 RPanic  = 00000000,FFFFFFF7,00000008,FFFFFFFF ; Right Panic / One Player
 RGlove  = 00000000,FFFFFFEF,00000010,FFFFFFFF ; Right Glove
 RCannon = 00000000,FFFFFFDF,00000020,FFFFFFFF ; Right Cannon
 AcctOn  = 00000000,FFFFFFBF,00000000,FFFFFFFF ; Accounting Info On
 AcctOff = 00000040,FFFFFFFF,00000000,FFFFFFFF ; Accounting Info Off
   */
#endif
}

void startFrame_armorattack(void) {

#define AA_IO_P1START   0x02  // 1-player start
#define AA_IO_P1LEFT    0x1000
#define AA_IO_P1RIGHT   0x4000
#define AA_IO_P1THRUST  0x8000
#define AA_IO_P1FIRE    0x2000

#define AA_IO_P2START   0x08  // 2-player start
#define AA_IO_P2LEFT    0x01
#define AA_IO_P2RIGHT   0x04
#define AA_IO_P2THRUST  0x10
#define AA_IO_P2FIRE    0x20
  
#define AA_SW_ABORT   SW_ABORT	/* for ioSwitches */
#define AA_SW_COIN    0x080
  
   static int prevButtonState=0;	// for debouncing
 static int isInit=0;

   frameCounter += 1;
   DEBUG_OUT("// Frame %d\n", frameCounter);

   v_WaitRecal ();
   // v_doSound();
   v_readButtons ();		// update currentButtonState
   v_readJoystick1Analog ();
   //v_readJoystick2Analog ();  // Apparently we are getting joystick 2 data anyway?????
   // v_playAllSFX();

   // Unfortunately, it's quite common to press LEFT and RIGHT simultaneously by accident with this
   // layout, and accidentally invoke the configuration screen.  Need to think about how we will
   // handle this...
   
   // default inactive:
  if (isInit == 0)
  {
    isInit = 1;
    ioInputs = initialInputs | AA_IO_P1LEFT | AA_IO_P1RIGHT | AA_IO_P1THRUST | AA_IO_P1FIRE | AA_IO_P1START | AA_IO_P2LEFT | AA_IO_P2RIGHT | AA_IO_P2THRUST | AA_IO_P2FIRE | AA_IO_P2START;
    ioSwitches = initialSwitches | AA_SW_COIN;
  }
  else
  {
      ioInputs = AA_IO_P1LEFT | AA_IO_P1RIGHT | AA_IO_P1THRUST | AA_IO_P1FIRE | AA_IO_P1START | AA_IO_P2LEFT | AA_IO_P2RIGHT | AA_IO_P2THRUST | AA_IO_P2FIRE | AA_IO_P2START;
      ioSwitches = AA_SW_COIN;
  }

   if ((currentButtonState & ~prevButtonState) & (VEC_BUTTON_1_1 | VEC_BUTTON_2_1)) ioSwitches &= ~AA_SW_COIN;	// only on rising edge
   prevButtonState = currentButtonState;

   // digital joysticks...
   if (currentJoy1X < -30) ioInputs &= ~AA_IO_P1LEFT;
   if (currentJoy1X > 30) ioInputs &= ~AA_IO_P1RIGHT;
   if (currentJoy1Y > 30) ioInputs &= ~AA_IO_P1THRUST;

   if (currentJoy2X < -30) ioInputs &= ~AA_IO_P2LEFT;
   if (currentJoy2X > 30) ioInputs &= ~AA_IO_P2RIGHT;
   if (currentJoy2Y > 30) ioInputs &= ~AA_IO_P2THRUST;

   // would be helpful to examine ram and make these context-dependent

   if (currentButtonState & VEC_BUTTON_1_2) ioInputs &= ~AA_IO_P1START; // needs 1 coin
   if (currentButtonState & VEC_BUTTON_2_2) ioInputs &= ~AA_IO_P2START; // needs 2 coins and second controller

   if (currentButtonState & VEC_BUTTON_1_1) ioInputs &= ~AA_IO_P1LEFT;
   if (currentButtonState & VEC_BUTTON_1_2) ioInputs &= ~AA_IO_P1RIGHT;
   if (currentButtonState & VEC_BUTTON_1_3) ioInputs &= ~AA_IO_P1THRUST;
   if (currentButtonState & VEC_BUTTON_1_4) ioInputs &= ~AA_IO_P1FIRE;

   if (currentButtonState & VEC_BUTTON_2_1) ioInputs &= ~AA_IO_P2LEFT;
   if (currentButtonState & VEC_BUTTON_2_2) ioInputs &= ~AA_IO_P2RIGHT;
   if (currentButtonState & VEC_BUTTON_2_3) ioInputs &= ~AA_IO_P2THRUST;
   if (currentButtonState & VEC_BUTTON_2_4) ioInputs &= ~AA_IO_P2FIRE;

#ifdef NEVER
  /*
>
>*** Armor Attack ***
>
>Keyboard Mapping:
>
>   Coin        = B1
>   One Player  = B2
>   Two Players = B3
>
>   Exit        = F1,F2,F3,F4
>   Calibrate   = F1,F2
>
>   Left        = F1
>   Right       = F2
>   Thrust      = F3
>   Fire        = F4
>

      
 ; Switch definitions:
 ;
 ;   D------  0=Diagnostics, 1=Normal
 ;   -X-----  Unused
 ;   --S----  0=No Sound in attract mode, 1=Sound (sound not supported)
 ;
 ;   ---CC--  00 = 1 credit per 1 quarter
 ;            10 = 1 credit per 2 quarters
 ;            01 = 3 credits per 2 quarters
 ;            11 = 3 credits per 4 quarters
 ;
 ;   -----JJ  00 = 5 jeeps per game
 ;   -----JJ  10 = 4 jeeps per game
 ;   -----JJ  01 = 3 jeeps per game
 ;   -----JJ  11 = 2 jeeps per game

 Switches=1000000      ; diagnostics, no sound, 1 credit per quarter, 5 jeeps per game ???

[Inputs]
 RstCPU  = 02000000,FFFFFFFF,00000000,FFFFFFFF	; Set bit indicating RESET
 Exit    = 01000000,FFFFFFFF,00000000,FFFFFFFF	; Set bit indicating Exit
 Coin    = 00000000,FFFFFFFF,00000000,FF7FFFFF

 Player1 = 00000000,FFFFFFFD,00000002,FFFFFFFF
 Player2 = 00000000,FFFFFFF7,00000008,FFFFFFFF

 RFire   = 00000000,FFFFDFFF,00002000,FFFFFFFF
 RThrust = 00000000,FFFF7FFF,00008000,FFFFFFFF
 RRight  = 00000000,FFFFBFFF,00004000,FFFFFFFF
 RLeft   = 00000000,FFFFEFFF,00001000,FFFFFFFF

 LFire   = 00000000,FFFFFFDF,00000020,FFFFFFFF
 LThrust = 00000000,FFFFFFEF,00000010,FFFFFFFF
 LRight  = 00000000,FFFFFFFB,00000004,FFFFFFFF
 LLeft   = 00000000,FFFFFFFE,00000001,FFFFFFFF
   */
#endif
}

void startFrame_starcastle(void) {
   //static int prevButtonState;	// for debouncing

   frameCounter += 1;
   DEBUG_OUT("v_WaitRecal(); v_setBrightness(64);v_readButtons();v_readJoystick1Analog(); // %d\n", frameCounter);

   v_WaitRecal ();
   // v_doSound();
   //prevButtonState = currentButtonState;
   v_readButtons ();		// update currentButtonState
   v_readJoystick1Analog ();
   // v_playAllSFX();
#ifdef NEVER
  /*
# Initialization file for Star Castle
>
>*** Star Castle ***
>
>Keyboard Mapping:
>
>   One Player  = F1
>   Two Players = F2
>   Coin        = F3
>   Reset Game  = F4
>   Exit        = <Esc>
>
>   Left        = 'Z'
>   Right       = 'X'
>   Thrust      = '.'
>   Fire        = '/'

 ; Switch definitions:
 ;
 ;   D------  0=Test Pattern, 1=Normal
 ;   -XX----  Unused
 ;
 ;   ---CC--  00 = 1 credit per 1 quarter
 ;            10 = 1 credit per 2 quarters
 ;            01 = 3 credit per 2 quarters
 ;            11 = 3 credit per 4 quarters
 ;
 ;   -----SS  00 = 3 ships per game
 ;            10 = 4 ships per game
 ;            01 = 5 ships per game
 ;            11 = 6 ships per game

 Switches=1000011

[Inputs]
 RstCPU  = 02000000,FFFFFFFF,00000000,FFFFFFFF	; Set bit indicating RESET
 Exit    = 01000000,FFFFFFFF,00000000,FFFFFFFF	; Set bit indicating Exit 
 Coin    = 00000000,FFFFFFFF,00000000,FF7FFFFF

 Player1 = 00000000,FFFFFFFE,00000001,FFFFFFFF
 Player2 = 00000000,FFFFFFFB,00000004,FFFFFFFF

 Left    = 00000000,FFFFFFBF,00000040,FFFFFFFF
 Right   = 00000000,FFFFFEFF,00000100,FFFFFFFF
 Thrust  = 00000000,FFFFFBFF,00000400,FFFFFFFF
 Fire    = 00000000,FFFFEFFF,00001000,FFFFFFFF
   */
#endif
}

void startFrame_starhawk(void) {
  static int prevButtonState=0;	// for debouncing

  frameCounter += 1;
  DEBUG_OUT("// Frame %d\n", frameCounter);

  v_WaitRecal ();
  // v_doSound();
  v_readButtons ();		// update currentButtonState
  v_readJoystick1Analog ();
  //v_readJoystick2Analog ();  // Apparently we are getting joystick 2 data anyway?????
  // v_playAllSFX();

#define SH_SW_P1_START 0x01
#define SH_IO_P1_LEFT  0x0002
#define SH_IO_P1_RIGHT 0x0004
#define SH_IO_P1_UP    0x0001
#define SH_IO_P1_DOWN  0x0008
#define SH_SW_P1_FIRE  0x08
#define SH_IO_P1_SLOW  0x4000
#define SH_IO_P1_MED   0x1000
#define SH_IO_P1_FAST  0x0200

#define SH_SW_P2_START 0x04
#define SH_IO_P2_LEFT  0x0400
#define SH_IO_P2_RIGHT 0x0010
#define SH_IO_P2_UP    0x0800
#define SH_IO_P2_DOWN  0x0020
#define SH_SW_P2_FIRE  0x02
#define SH_IO_P2_SLOW  0x0100
#define SH_IO_P2_MED   0x2000
#define SH_IO_P2_FAST  0x8000

#define SH_SW_COIN 0x80

   ioSwitches = initialSwitches | SH_SW_COIN | SH_SW_P1_START | SH_SW_P2_START | SH_SW_P1_FIRE | SH_SW_P2_FIRE;
   if ((currentButtonState & ~prevButtonState) & (VEC_BUTTON_1_1|VEC_BUTTON_2_1)) ioSwitches &= ~SH_SW_COIN;	// only on rising edge

   ioInputs = initialInputs | SH_IO_P1_LEFT | SH_IO_P1_RIGHT | SH_IO_P1_UP | SH_IO_P1_DOWN | SH_IO_P1_SLOW | SH_IO_P1_MED | SH_IO_P1_FAST |
                              SH_IO_P2_LEFT | SH_IO_P2_RIGHT | SH_IO_P2_UP | SH_IO_P2_DOWN | SH_IO_P2_SLOW | SH_IO_P2_MED | SH_IO_P2_FAST;

   if (currentButtonState & VEC_BUTTON_1_2) ioSwitches &= ~SH_SW_P1_START;
   if (currentButtonState & VEC_BUTTON_2_2) ioSwitches &= ~SH_SW_P2_START;

   // Digital joysticks.  Need to do the same sort of hack as
   // in Tailgunner to allow analog injection of cursor values
   // btw the P2 joystick for some reason seems much more responsive!
   
   if (currentJoy1X < -30) ioInputs &= ~SH_IO_P1_LEFT;
   if (currentJoy1X > 30) ioInputs &= ~SH_IO_P1_RIGHT;
   if (currentJoy1Y > 30) ioInputs &= ~SH_IO_P1_UP;
   if (currentJoy1Y < -30) ioInputs &= ~SH_IO_P1_DOWN;

   if (currentJoy2X < -30) ioInputs &= ~SH_IO_P2_LEFT;
   if (currentJoy2X > 30) ioInputs &= ~SH_IO_P2_RIGHT;
   if (currentJoy2Y > 30) ioInputs &= ~SH_IO_P2_UP;
   if (currentJoy2Y < -30) ioInputs &= ~SH_IO_P2_DOWN;

   // again, some context-sensitive decoding will be needed
   
   if (currentButtonState & VEC_BUTTON_1_1) ioInputs &= ~SH_IO_P1_SLOW;
   if (currentButtonState & VEC_BUTTON_2_1) ioInputs &= ~SH_IO_P2_SLOW;

   if (currentButtonState & VEC_BUTTON_1_2) ioInputs &= ~SH_IO_P1_MED;
   if (currentButtonState & VEC_BUTTON_2_2) ioInputs &= ~SH_IO_P2_MED;

   if (currentButtonState & VEC_BUTTON_1_3) ioInputs &= ~SH_IO_P1_FAST;
   if (currentButtonState & VEC_BUTTON_2_3) ioInputs &= ~SH_IO_P2_FAST;

   if (currentButtonState & VEC_BUTTON_1_4) ioSwitches &= ~SH_SW_P1_FIRE;
   if (currentButtonState & VEC_BUTTON_2_4) ioSwitches &= ~SH_SW_P2_FIRE;
  prevButtonState = currentButtonState;

#ifdef NEVER
  /*
# Initialization file for Star Hawk
>
>*** Star Hawk ***
>
>Keyboard Mapping:
>
>   One Player  = F1
>   Two Players = F2
>   Coin        = F3
>   Reset Game  = F4
>   Exit        = <Esc>
>
>   Left Player            Right Player
>   ------------           ----------------------
>   Slow  = '1'            Slow  = '0'
>   Med   = '2'            Med   = '-'
>   Fast  = '3'            Fast  = '='
>   Left  = 'F'            Left  = Keypad '4'
>   Right = 'H'            Right = Keypad '6'
>   Up    = 'T'            Up    = Keypad '8'
>   Down  = 'G' or 'V'     Down  = Keypad '5' or Keypad '2'
>   Fire  = <Left Shift>   Fire  = <Right Shift>

 Switches=0000000

[Inputs]
 RstCPU  = 02000000,FFFFFFFF,00000000,FFFFFFFF	; Set bit indicating RESET
 Exit    = 01000000,FFFFFFFF,00000000,FFFFFFFF	; Set bit indicating Exit 
 Coin    = 00000000,FFFFFFFF,00000000,FF7FFFFF

 Player1 = 00000000,FFFEFFFF,00010000,FFFFFFFF
 Player2 = 00000000,FFFBFFFF,00040000,FFFFFFFF

 RSlow   = 00000000,FFFFBFFF,00004000,FFFFFFFF
 RMed    = 00000000,FFFFEFFF,00001000,FFFFFFFF
 RFast   = 00000000,FFFFFDFF,00000200,FFFFFFFF
 RLeft   = 00000000,FFFFFFFD,00000002,FFFFFFFF
 RRight  = 00000000,FFFFFFFB,00000004,FFFFFFFF
 RUp     = 00000000,FFFFFFFE,00000001,FFFFFFFF
 RDown   = 00000000,FFFFFFF7,00000008,FFFFFFFF
 RFire   = 00000000,FFF7FFFF,00080000,FFFFFFFF

 LSlow   = 00000000,FFFFFEFF,00000100,FFFFFFFF
 LMed    = 00000000,FFFFDFFF,00002000,FFFFFFFF
 LFast   = 00000000,FFFF7FFF,00008000,FFFFFFFF
 LLeft   = 00000000,FFFFFBFF,00000400,FFFFFFFF
 LRight  = 00000000,FFFFFFEF,00000010,FFFFFFFF
 LUp     = 00000000,FFFFF7FF,00000800,FFFFFFFF
 LDown   = 00000000,FFFFFFDF,00000020,FFFFFFFF
 LFire   = 00000000,FFFDFFFF,00020000,FFFFFFFF
   */
#endif
}

void startFrame_solarquest(void) {
   static int prevButtonState=0;	// for debouncing

   frameCounter += 1;
   DEBUG_OUT("v_WaitRecal(); v_setBrightness(64);v_readButtons();v_readJoystick1Analog(); // %d\n", frameCounter);

   v_WaitRecal ();
   // v_doSound();
   v_readButtons ();		// update currentButtonState
   v_readJoystick1Analog ();
   // v_playAllSFX();

#define SQ_SW_COIN 0x80

   ioSwitches = initialSwitches | SQ_SW_COIN;
   if ((currentButtonState & ~prevButtonState) & (VEC_BUTTON_1_1|VEC_BUTTON_2_1)) ioSwitches &= ~SQ_SW_COIN;	// only on rising edge
   ioInputs = initialInputs;
   prevButtonState = currentButtonState;

#ifdef NEVER
  /*
# Initialization file for Solar Quest
>
>*** Solar Quest ***
>
>Keyboard Mapping:
>
>   One Player  = F1
>   Two Players = F2
>   Coin        = F3
>   Reset Game  = F4
>   Exit        = <Esc>
>
>   Left        = 'Z'
>   Right       = 'X'
>   HyperSpace  = 'C'
>
>   Nova        = ','
>   Thrust      = '.'
>   Fire        = '/'

 ; Switch definitions:
 ;
 ;    D------  0=Diagnostics, 1=Normal
 ;    -F-----  0=Normal, 1=Free play
 ;
 ;    --SS---  00 = 2 ships
 ;             10 = 3 ships
 ;             01 = 4 ships
 ;             11 = 5 ships
 ;
 ;    ----C-C  0-0 = 1 coin 1 credit
 ;             1-0 = 2 coin 1 credit
 ;             0-1 = 2 coin 3 credit
 ;             1-1 = 4 coin 3 credit
 ;
 ;    -----E-  0=25 captures for extra ship, 1=40 captures

 Switches=1011000

 ; Default inputs (used to set difficulty level):
 ;
 ;    FFFF = Level 1 (Easiest)
 ;    EFFF = Level 2
 ;    DFFF = Level 3
 ;    CFFF = Level 4
 ;    BFFF = Level 5
 ;    AFFF = Level 6
 ;    9FFF = Level 7
 ;    8FFF = Level 8 (Hardest)
 ;
 ; Any other settings may cause erratic behaviour!

 Inputs=FFFF

[Inputs]
 RstCPU  = 02000000,FFFFFFFF,00000000,FFFFFFFF	; Set bit indicating RESET
 Exit    = 01000000,FFFFFFFF,00000000,FFFFFFFF	; Set bit indicating Exit 
 Coin    = 00000000,FFFFFFFF,00000000,FF7FFFFF

 Player1 = 00000000,FFFFFFF7,00000008,FFFFFFFF	; Also Hyperspace key
 Player2 = 00000000,FFFFFFFE,00000001,FFFFFFFF	; Also Nova key
 Left    = 00000000,FFFFFFDF,00000020,FFFFFFFF
 Right   = 00000000,FFFFFFEF,00000010,FFFFFFFF
 Thrust  = 00000000,FFFFFFFB,00000004,FFFFFFFF
 Fire    = 00000000,FFFFFFFD,00000002,FFFFFFFF
   */
#endif
}

void startFrame_cosmicchasm(void) {
   static int prevButtonState=0;	// for debouncing

   frameCounter += 1;
   DEBUG_OUT("v_WaitRecal(); v_setBrightness(64);v_readButtons();v_readJoystick1Analog(); // %d\n", frameCounter);

   v_WaitRecal ();
   // v_doSound();
   v_readButtons ();		// update currentButtonState
   v_readJoystick1Analog ();
   // v_playAllSFX();

#define CC_SW_COIN 0x80

   ioSwitches = initialSwitches | CC_SW_COIN;
   if ((currentButtonState & ~prevButtonState) & (VEC_BUTTON_1_1|VEC_BUTTON_2_1)) ioSwitches &= ~CC_SW_COIN;	// only on rising edge
   prevButtonState = currentButtonState;
   ioInputs = initialInputs;

#ifdef NEVER
  /*
# Initialization file for Cosmic Chasm - best guess, under development
>
>***Cosmic Chasm ***
>
>Keyboard Mapping:
>
>   One Player  = F1
>   Two Players = F2
>   Coin        = F3
>   Reset Game  = F4
>   Exit        = <Esc>
>

; Switch definitions:
 ;
 ;   D------  0=Normal, 1=Diagnositic Mode
 ;   -F-----  0=Normal, 1=Free Play
 ;   --S----  0=No sound during attract, 1=Sound during attract (sound not supported)
 ;   ---B---  0=Bonus at 50k, 1=Bonus at 30k
 ;   ----P--  0=3 cannons per game, 1=5 cannons per game
 ;
 ;   -----CC  00 = 1 credit per 1 quarter
 ;            10 = 1 credit per 2 quarters
 ;            01 = 3 credits per 2 quarters
 ;            11 = 3 credits per 4 quarters

 Switches=0001100

[Inputs]
 RstCPU  = 02000000,FFFFFFFF,00000000,FFFFFFFF	; Set bit indicating RESET
 Exit    = 01000000,FFFFFFFF,00000000,FFFFFFFF	; Set bit indicating Exit 
 Coin    = 00000000,FFFFFFFF,00000000,FF7FFFFF
   */
#endif
}

void startFrame_waroftheworlds(void) {
   static int prevButtonState=0;	// for debouncing

   frameCounter += 1;
   DEBUG_OUT("v_WaitRecal(); v_setBrightness(64);v_readButtons();v_readJoystick1Analog(); // %d\n", frameCounter);

   v_WaitRecal ();
   // v_doSound();
   v_readButtons ();		// update currentButtonState
   v_readJoystick1Analog ();
   // v_playAllSFX();

#define WW_SW_COIN 0x80

   ioSwitches = initialSwitches | WW_SW_COIN;
   if ((currentButtonState & ~prevButtonState) & (VEC_BUTTON_1_1|VEC_BUTTON_2_1)) ioSwitches &= ~WW_SW_COIN;	// only on rising edge
   prevButtonState = currentButtonState;
   ioInputs = initialInputs;

#ifdef NEVER
  /*
# Initialization file for War of the Worlds
>
>*** War of the Worlds ***
>
>Keyboard Mapping:
>
>   One Player  = F1
>   Two Players = F2
>   Coin        = F3
>   Reset Game  = F4
>   Exit        = <Esc>
>
>   Left        = 'Z'
>   Right       = 'X'
>   Shields     = '.'
>   Fire        = '/'

 ; Switch definitions:
 ;
 ;   D------  0=Normal, 1=Diagnostics
 ;   -F-----  0=Normal, 1=Free Play
 ;   ---C---  0=1 credit per 1 quarter, 1=3 credits per 2 quarters
 ;   -----S-  0=5 ships per game, 1=3 ships per game
 ;
 ;   --?-?-?  *unknown* (no manual exists)

 Switches=0000000

[Inputs]
 RstCPU  = 02000000,FFFFFFFF,00000000,FFFFFFFF	; Set bit indicating RESET
 Exit    = 01000000,FFFFFFFF,00000000,FFFFFFFF	; Set bit indicating Exit 
 Coin    = 00000000,FFFFFFFF,00000000,FF7FFFFF

 Player1 = 00000000,FFFFFFFE,00000001,FFFFFFFF
 Player2 = 00000000,FFFFFFFB,00000004,FFFFFFFF

 Left    = 00000000,FFFFFFBF,00000040,FFFFFFFF
 Right   = 00000000,FFFFFEFF,00000100,FFFFFFFF
 Shields = 00000000,FFFFFBFF,00000400,FFFFFFFF
 Fire    = 00000000,FFFFEFFF,00001000,FFFFFFFF

   */
#endif
}

void startFrame_warrior(void) {
  static int prevButtonState=0;	// for debouncing

  frameCounter += 1;
  DEBUG_OUT("// Frame %d\n", frameCounter);

  v_WaitRecal ();
  // v_doSound();
  v_readButtons ();		// update currentButtonState
  v_readJoystick1Analog ();
  //v_readJoystick2Analog ();  // Apparently we are getting joystick 2 data anyway?????
  // v_playAllSFX();

  // Don't have any input for this game as to Player 1 or Player 2 start....

#define WA_SW_Sw0  0x01
#define WA_SW_Sw1  0x02
#define WA_SW_Sw2  0x04
#define WA_SW_Sw3  0x08
#define WA_SW_Sw6  0x40
    
  //#define WA_IO_P1_START 0x??
#define WA_IO_P1_LEFT  0x02
#define WA_IO_P1_RIGHT 0x01
#define WA_IO_P1_UP    0x04
#define WA_IO_P1_DOWN  0x08
#define WA_IO_P1_SWORD 0x10

  //#define WA_IO_P2_START 0x????
#define WA_IO_P2_LEFT  0x0200
#define WA_IO_P2_RIGHT 0x0100
#define WA_IO_P2_UP    0x0400
#define WA_IO_P2_DOWN  0x0800
#define WA_IO_P2_SWORD 0x1000

#define WA_SW_COIN 0x80

   ioSwitches = initialSwitches | WA_SW_COIN;
   if ((currentButtonState & ~prevButtonState) & (VEC_BUTTON_1_1|VEC_BUTTON_2_1)) ioSwitches &= ~WA_SW_COIN;	// only on rising edge

  prevButtonState = currentButtonState;
   ioInputs = initialInputs | /*WA_IO_P1_START |*/ WA_IO_P1_LEFT | WA_IO_P1_RIGHT | WA_IO_P1_UP | WA_IO_P1_DOWN | WA_IO_P1_SWORD |
                              /*WA_IO_P2_START |*/ WA_IO_P2_LEFT | WA_IO_P2_RIGHT | WA_IO_P2_UP | WA_IO_P2_DOWN | WA_IO_P2_SWORD;

   // How to start?
   //if (currentButtonState & VEC_BUTTON_1_2) ioInputs &= ~WA_IO_P1_START;
   //if (currentButtonState & VEC_BUTTON_2_2) ioInputs &= ~WA_IO_P2_START;

   // USE JOYSTICK
   if (currentJoy1X < -30) ioInputs &= ~WA_IO_P1_LEFT;
   if (currentJoy1X > 30) ioInputs &= ~WA_IO_P1_RIGHT;
   if (currentJoy1Y > 30) ioInputs &= ~WA_IO_P1_UP;
   if (currentJoy1Y < -30) ioInputs &= ~WA_IO_P1_DOWN;

   if (currentJoy2X < -30) ioInputs &= ~WA_IO_P2_LEFT;
   if (currentJoy2X > 30) ioInputs &= ~WA_IO_P2_RIGHT;
   if (currentJoy2Y > 30) ioInputs &= ~WA_IO_P2_UP;
   if (currentJoy2Y < -30) ioInputs &= ~WA_IO_P2_DOWN;

   if (currentButtonState & VEC_BUTTON_1_4) ioInputs &= ~WA_IO_P1_SWORD;
   if (currentButtonState & VEC_BUTTON_2_4) ioInputs &= ~WA_IO_P2_SWORD;

#ifdef NEVER
  /*
# Initialization file for Warrior
>
>*** Warrior ***
>
>Keyboard Mapping:
>
>   One Player  = F1
>   Two Players = F2
>   Coin        = F3
>   Reset Game  = F4
>   Exit        = <Esc>
>
>   Left Player            Right Player
>   ------------           ----------------------
>   Left  = 'F'            Left  = Keypad '4'
>   Right = 'H'            Right = Keypad '6'
>   Up    = 'T'            Up    = Keypad '8'
>   Down  = 'G'            Down  = Keypad '5'
>   Sword = <Left Shift>   Sword = <Right Shift>

 Switches=1111111

[Inputs]
 RstCPU  = 02000000,FFFFFFFF,00000000,FFFFFFFF	; Set bit indicating RESET
 Exit    = 01000000,FFFFFFFF,00000000,FFFFFFFF	; Set bit indicating Exit
 Coin    = 00000000,FFFFFFFF,00000000,FF7FFFFF

 LRight  = 00000000,FFFFFEFF,00000100,FFFFFFFF
 LLeft   = 00000000,FFFFFDFF,00000200,FFFFFFFF
 LUp     = 00000000,FFFFFBFF,00000400,FFFFFFFF
 LDown   = 00000000,FFFFF7FF,00000800,FFFFFFFF
 LSword  = 00000000,FFFFEFFF,00001000,FFFFFFFF

 RRight  = 00000000,FFFFFFFE,00000001,FFFFFFFF
 RLeft   = 00000000,FFFFFFFD,00000002,FFFFFFFF
 RUp     = 00000000,FFFFFFFB,00000004,FFFFFFFF
 RDown   = 00000000,FFFFFFF7,00000008,FFFFFFFF
 RSword  = 00000000,FFFFFFEF,00000010,FFFFFFFF

 Sw0  = 00000000,FFFEFFFF,00010000,FFFFFFFF
 Sw1  = 00000000,FFFDFFFF,00020000,FFFFFFFF
 Sw2  = 00000000,FFFBFFFF,00040000,FFFFFFFF
 Sw3  = 00000000,FFF7FFFF,00080000,FFFFFFFF
 Sw6  = 00000000,FFBFFFFF,00400000,FFFFFFFF

 Key5 = 00000000,FFFFFFDF,00000020,FFFFFFFF
 Key6 = 00000000,FFFFFFBF,00000040,FFFFFFFF
 Key7 = 00000000,FFFFFF7F,00000080,FFFFFFFF
 KeyD = 00000000,FFFFDFFF,00002000,FFFFFFFF
 KeyE = 00000000,FFFFBFFF,00004000,FFFFFFFF
 KeyF = 00000000,FFFF7FFF,00008000,FFFFFFFF
   */
#endif
}

void startFrame_barrier(void) {
  static int prevButtonState=0;	// for debouncing

   frameCounter += 1;
   DEBUG_OUT("// Frame %d\n", frameCounter);

   v_WaitRecal ();
   // v_doSound();
   v_readButtons ();		// update currentButtonState
   v_readJoystick1Analog ();
   //v_readJoystick2Analog ();  // Apparently we are getting joystick 2 data anyway?????
   // v_playAllSFX();

#define BA_IO_P1_START 0x0800
#define BA_IO_P1_LEFT  0x4000
#define BA_IO_P1_RIGHT 0x0200
#define BA_IO_P1_FWD   0x1000
#define BA_IO_P1_REV   0x0008

#define BA_IO_P2_START 0x0010
#define BA_IO_P2_LEFT  0x0100
#define BA_IO_P2_RIGHT 0x8000
#define BA_IO_P2_FWD   0x2000
#define BA_IO_P2_REV   0x0400

#define BA_IO_SKILL_A 0X01
#define BA_IO_SKILL_B 0X04
#define BA_IO_SKILL_C 0X40

#define BA_SW_COIN 0x80

   ioSwitches = initialSwitches | BA_SW_COIN;
   if ((currentButtonState & ~prevButtonState) & (VEC_BUTTON_1_1|VEC_BUTTON_2_1)) ioSwitches &= ~BA_SW_COIN;	// only on rising edge

   ioInputs = initialInputs | BA_IO_P1_START | BA_IO_P1_LEFT | BA_IO_P1_RIGHT | BA_IO_P1_FWD | BA_IO_P1_REV |
                              BA_IO_P2_START | BA_IO_P2_LEFT | BA_IO_P2_RIGHT | BA_IO_P2_FWD | BA_IO_P2_REV |
                              BA_IO_SKILL_A | BA_IO_SKILL_B | BA_IO_SKILL_C;
// USE JOYSTICK
   if (currentJoy1X < -30) ioInputs &= ~BA_IO_P1_LEFT;
   if (currentJoy1X > 30) ioInputs &= ~BA_IO_P1_RIGHT;
   if (currentJoy1Y > 30) ioInputs &= ~BA_IO_P1_FWD;
   if (currentJoy1Y < -30) ioInputs &= ~BA_IO_P1_REV;

   if (currentJoy2X < -30) ioInputs &= ~BA_IO_P2_LEFT;
   if (currentJoy2X > 30) ioInputs &= ~BA_IO_P2_RIGHT;
   if (currentJoy2Y > 30) ioInputs &= ~BA_IO_P2_FWD;
   if (currentJoy2Y < -30) ioInputs &= ~BA_IO_P2_REV;

   if (currentButtonState & VEC_BUTTON_1_2) ioInputs &= ~BA_IO_P1_START;
   if (currentButtonState & VEC_BUTTON_2_2) ioInputs &= ~BA_IO_P2_START;

   if (currentButtonState & (VEC_BUTTON_1_3|VEC_BUTTON_2_3)) ioInputs &= ~BA_IO_SKILL_A; // MAYBE SKILL++ AND SKILL-- ? ONE BUTTON SHORT
   if (currentButtonState & (VEC_BUTTON_1_4|VEC_BUTTON_2_4)) ioInputs &= ~BA_IO_SKILL_C;
   prevButtonState = currentButtonState;
  
#ifdef NEVER
  /*
# Initialization file for Barrier
>
>*** Barrier ***
>
>Keyboard Mapping:
>
>   One Player  = F1
>   Two Players = F2
>   Coin        = F3
>   Reset Game  = F4
>   Exit        = <Esc>
>
>   Left    = Keypad '4'     Skill A = '1'
>   Right   = Keypad '6'     Skill B = '2'
>   Forward = Keypad '8'     Skill C = '3'
>   Reverse = Keypad '2'
>
>   Use 'Forward', and any skill keys, to enter high score.

 ; Switch definitions:
 ;
 ;   XXXXX--  Unused
 ;   -----S-  0=Audio in attract mode, 1=No audio (sound not supported)
 ;   ------I  0=5 innings per game, 1=3 innings per game 

 Switches=0000001

[Inputs]
 RstCPU  = 02000000,FFFFFFFF,00000000,FFFFFFFF	; Set bit indicating RESET
 Exit    = 01000000,FFFFFFFF,00000000,FFFFFFFF	; Set bit indicating Exit 
 Coin    = 00000000,FFFFFFFF,00000000,FF7FFFFF

 Player1 = 00000000,FFFFF7FF,00000800,FFFFFFFF
 Player2 = 00000000,FFFFFFEF,00000010,FFFFFFFF

 SkillA  = 00000000,FFFFFFFE,00000001,FFFFFFFF
 SkillB  = 00000000,FFFFFFFB,00000004,FFFFFFFF
 SkillC  = 00000000,FFFFFFBF,00000040,FFFFFFFF

 ; Use these definitions if you want seperate player 1 & 2 controls
 ; (You'll have to define the player 2 keys you want to use in [KeyMapping])

; Left1    = 00000000,FFFFBFFF,00004000,FFFFFFFF
; Right1   = 00000000,FFFFFDFF,00000200,FFFFFFFF
; Fwd1     = 00000000,FFFFEFFF,00001000,FFFFFFFF
; Rev1     = 00000000,FFFFFFF7,00000008,FFFFFFFF

; Left2    = 00000000,FFFFFEFF,00000100,FFFFFFFF
; Right2   = 00000000,FFFF7FFF,00008000,FFFFFFFF
; Fwd2     = 00000000,FFFFDFFF,00002000,FFFFFFFF
; Rev2     = 00000000,FFFFFBFF,00000400,FFFFFFFF

 ; Use these definitions to have Player 1 and 2 share the same keys

 Left1&2  = 00000000,FFFFBEFF,00004100,FFFFFFFF
 Right1&2 = 00000000,FFFF7DFF,00008200,FFFFFFFF
 Fwd1&2   = 00000000,FFFFCFFF,00003000,FFFFFFFF
 Rev1&2   = 00000000,FFFFFBF7,00000408,FFFFFFFF

   */
#endif
}

void startFrame_sundance(void) {
  // need to check P1/P2 against L/R
#define SD_IO_P1START 0x04
#define SD_IO_P2START 0x08
#define SD_IO_GRID 0x20
#define SD_IO_2SUNS 0x0800
#define SD_IO_3SUNS 0x10
#define SD_IO_4SUNS 0x40
#define SD_IO_P1FIRE 0x02
#define SD_IO_P2FIRE 0x80

#define SD_SW_COIN    0x080
  static int prevButtonState=0;	// for debouncing
  int Square, X, Y;

   frameCounter += 1;
   DEBUG_OUT("// Frame %d\n", frameCounter);

   v_WaitRecal ();
   // v_doSound();
   v_readButtons ();		// update currentButtonState
   v_readJoystick1Analog ();
   //v_readJoystick2Analog ();  // Apparently we are getting joystick 2 data anyway?????
   // v_playAllSFX();

  ioSwitches = initialSwitches | SD_SW_COIN;
  if ((currentButtonState & ~prevButtonState) & VEC_BUTTON_1_1) ioSwitches &= ~SD_SW_COIN;	// only on rising edge

#define P1XLEFT 1
#define P1XCENT 2
#define P1XRIGHT 4
#define P1YTOP 8
#define P1YCENT 16
#define P1YBOT 32

  ioInputs = initialInputs | 0x5201 | 0xA580;

  if (currentJoy1X > 30) X = P1XRIGHT; else if (currentJoy1X < -30) X = P1XLEFT; else X = P1XCENT;
  if (currentJoy1Y > 30) Y = P1YTOP; else if (currentJoy1Y < -30) Y = P1YBOT; else Y = P1YCENT;

  switch (X|Y) {
    /*
 Hatch1R = 00004000,FFFFEDFE,00005201,FFFFFFFF    1201
 Hatch2R = 00004201,FFFFEFFF,00005201,FFFFFFFF    1000
 Hatch3R = 00005200,FFFFFFFE,00005201,FFFFFFFF    0001
 Hatch4R = 00001201,FFFFBFFF,00005201,FFFFFFFF    4000
 Hatch5R = 00004200,FFFFEFFE,00005201,FFFFFFFF    1001
 Hatch6R = 00005001,FFFFFDFF,00005201,FFFFFFFF    0200
 Hatch7R = 00001200,FFFFBFFE,00005201,FFFFFFFF    4001
 Hatch8R = 00004001,FFFFEDFF,00005201,FFFFFFFF    1200
 Hatch9R = 00005000,FFFFFDFE,00005201,FFFFFFFF    0201
     */
  case P1XLEFT+P1YTOP: Square = 0x1201; break;
  case P1XCENT+P1YTOP: Square = 0x1000; break;
  case P1XRIGHT+P1YTOP: Square = 0x0001; break;

  case P1XLEFT+P1YCENT: Square = 0x4000; break;
  case P1XCENT+P1YCENT: Square = 0x1001; break;
  case P1XRIGHT+P1YCENT: Square = 0x0200; break;

  case P1XLEFT+P1YBOT: Square = 0x4001; break;
  case P1XCENT+P1YBOT: Square = 0x1200; break;
  case P1XRIGHT+P1YBOT: Square = 0x0201; break;
  }
  ioInputs &= ~Square;


#define P2XLEFT 1
#define P2XCENT 2
#define P2XRIGHT 4
#define P2YTOP 8
#define P2YCENT 16
#define P2YBOT 32


  if (currentJoy2X > 30) X = P2XRIGHT; else if (currentJoy2X < -30) X = P2XLEFT; else X = P2XCENT;
  if (currentJoy2Y > 30) Y = P2YTOP; else if (currentJoy2Y < -30) Y = P2YBOT; else Y = P2YCENT;

  switch (X|Y) {
    /*
 Hatch1L = 00008080,FFFFDAFF,0000A580,FFFFFFFF   2500
 Hatch2L = 00008580,FFFFDFFF,0000A580,FFFFFFFF   2000
 Hatch3L = 0000A180,FFFFFBFF,0000A580,FFFFFFFF   0400

 Hatch4L = 00002580,FFFF7FFF,0000A580,FFFFFFFF   8000
 Hatch5L = 00008180,FFFFDBFF,0000A580,FFFFFFFF   2400
 Hatch6L = 0000A480,FFFFFEFF,0000A580,FFFFFFFF   0100

 Hatch7L = 00002180,FFFF7BFF,0000A580,FFFFFFFF   9400  <-- possibly should be A400 or 8400 ???
 Hatch8L = 00008480,FFFFDEFF,0000A580,FFFFFFFF   2100
 Hatch9L = 0000A080,FFFFFAFF,0000A580,FFFFFFFF   0500
     */
  case P2XLEFT+P2YTOP: Square = 0x2500; break;
  case P2XCENT+P2YTOP: Square = 0x2000; break;
  case P2XRIGHT+P2YTOP: Square = 0x0400; break;

  case P2XLEFT+P2YCENT: Square = 0x8000; break;
  case P2XCENT+P2YCENT: Square = 0x2400; break;
  case P2XRIGHT+P2YCENT: Square = 0x0100; break;

  case P2XLEFT+P2YBOT: Square = 0x9400; break;
  case P2XCENT+P2YBOT: Square = 0x2100; break;
  case P2XRIGHT+P2YBOT: Square = 0x0500; break;
  }
  ioInputs &= ~Square;
  ioInputs |= SD_IO_P1START | SD_IO_P2START | SD_IO_GRID | SD_IO_2SUNS | SD_IO_3SUNS | SD_IO_4SUNS | SD_IO_P1FIRE | SD_IO_P2FIRE;

  if ((currentButtonState & ~prevButtonState) & (VEC_BUTTON_1_1|VEC_BUTTON_2_1)) ioSwitches &= ~SD_SW_COIN;	// only on rising edge
  if (currentButtonState & VEC_BUTTON_1_2) ioInputs &= ~SD_IO_P1START;
  if (currentButtonState & VEC_BUTTON_2_2) ioInputs &= ~SD_IO_P2START;
  if (currentButtonState & (VEC_BUTTON_1_3|VEC_BUTTON_2_3)) ioInputs &= ~SD_IO_GRID;
  if (currentButtonState & VEC_BUTTON_1_4) ioInputs &= ~SD_IO_P1FIRE;
  if (currentButtonState & VEC_BUTTON_2_4) ioInputs &= ~SD_IO_P2FIRE;
   prevButtonState = currentButtonState;

#ifdef NEVER
  /*
# Initialization file for Sundance
>
>*** Sundance ***
>
>Keyboard Mapping:
>
>   One Player  = F1      Grid Control = '1'
>   Two Players = F2      2 Suns       = '2'
>   Coin        = F3      3 Suns       = '3'
>   Reset Game  = F4      4 Suns       = '4'
>   Exit        = <Esc>
>   
>   Left Player:          Right Player: 
>    -----------           -----------
>   | R | T | Y |         | 7 | 8 | 9 |
>   |---|---|---|         |---|---|---|
>   | F | G | H |         | 4 | 5 | 6 |
>   |---|---|---|         |---|---|---|
>   | V | B | N |         | 1 | 2 | 3 |
>    -----------           -----------
>   Fire = <Left Shift>   Fire = <Right Shift>

 ; Switch definitions:
 ;
 ;   XXX----  Unused
 ;   ---P---  0=2 players needs 2 coins, 1=2 players need only 1 coin
 ;   ----E--  0=Japanese, 1=English
 ;
 ;   -----TT  11 = 0:45 minutes per coin
 ;            01 = 1:00 minutes per coin
 ;            10 = 1:30 minutes per coin
 ;            00 = 2:00 minutes per coin

 Switches=0000101

[Inputs]
 RstCPU  = 02000000,FFFFFFFF,00000000,FFFFFFFF	; Set bit indicating RESET
 Exit    = 01000000,FFFFFFFF,00000000,FFFFFFFF	; Set bit indicating Exit 
 Coin    = 00000000,FFFFFFFF,00000000,FF7FFFFF

 Player1 = 00000000,FFFFFFFB,00000004,FFFFFFFF
 Player2 = 00000000,FFFFFFF7,00000008,FFFFFFFF

 Grid    = 00000000,FFFFFFDF,00000020,FFFFFFFF
 2Suns   = 00000000,FFFFF7FF,00000800,FFFFFFFF
 3Suns   = 00000000,FFFFFFEF,00000010,FFFFFFFF
 4Suns   = 00000000,FFFFFFBF,00000040,FFFFFFFF
 FireR   = 00000000,FFFFFFFD,00000002,FFFFFFFF
 FireL   = 00000000,FFFFFF7F,00000080,FFFFFFFF 

 Hatch1R = 00004000,FFFFEDFE,00005201,FFFFFFFF
 Hatch2R = 00004201,FFFFEFFF,00005201,FFFFFFFF
 Hatch3R = 00005200,FFFFFFFE,00005201,FFFFFFFF
 Hatch4R = 00001201,FFFFBFFF,00005201,FFFFFFFF
 Hatch5R = 00004200,FFFFEFFE,00005201,FFFFFFFF
 Hatch6R = 00005001,FFFFFDFF,00005201,FFFFFFFF
 Hatch7R = 00001200,FFFFBFFE,00005201,FFFFFFFF
 Hatch8R = 00004001,FFFFEDFF,00005201,FFFFFFFF
 Hatch9R = 00005000,FFFFFDFE,00005201,FFFFFFFF

 Hatch1L = 00008080,FFFFDAFF,0000A580,FFFFFFFF 
 Hatch2L = 00008580,FFFFDFFF,0000A580,FFFFFFFF 
 Hatch3L = 0000A180,FFFFFBFF,0000A580,FFFFFFFF 
 Hatch4L = 00002580,FFFF7FFF,0000A580,FFFFFFFF 
 Hatch5L = 00008180,FFFFDBFF,0000A580,FFFFFFFF 
 Hatch6L = 0000A480,FFFFFEFF,0000A580,FFFFFFFF 
 Hatch7L = 00002180,FFFF7BFF,0000A580,FFFFFFFF 
 Hatch8L = 00008480,FFFFDEFF,0000A580,FFFFFFFF 
 Hatch9L = 0000A080,FFFFFAFF,0000A580,FFFFFFFF 
   */
#endif
}

void startFrame_qb3(void) {
   static int prevButtonState=0;	// for debouncing

   frameCounter += 1;
   DEBUG_OUT("v_WaitRecal(); v_setBrightness(64);v_readButtons();v_readJoystick1Analog(); // %d\n", frameCounter);

   v_WaitRecal ();
   // v_doSound();
   v_readButtons ();		// update currentButtonState
   v_readJoystick1Analog ();
   // v_playAllSFX();

#define QB_SW_COIN 0x80

   ioSwitches = initialSwitches | QB_SW_COIN;
   if ((currentButtonState & ~prevButtonState) & (VEC_BUTTON_1_1|VEC_BUTTON_2_1)) ioSwitches &= ~QB_SW_COIN;	// only on rising edge
   prevButtonState = currentButtonState;
   ioInputs = initialInputs;

#ifdef NEVER
  /*
# Initialization file for QB3 - under development
>
>*** QB3 ***
>
>Keyboard Mapping:
>
>   Start Game  = F1
>   Coin        = F3
>   Reset Game  = F4
>   Exit        = <Esc>
>


 Inputs=FFFF ; unknown for now # <input players="1" buttons="4" coins="1">
 Switches= 1001001000010   ; free play on
                      00   2 lives
                      01   4 lives
                      10   3 lives default
                      11   5 lives
                    1???   free play off  default
                    0???   free play on
                 1??????   service mode off  default
                 0??????   service mode on
              1?????????   debug off  default
              0?????????   debug on
           1????????????   infinite lives off  default
           0????????????   infinite lives on

[Inputs]
 RstCPU  = 02000000,FFFFFFFF,00000000,FFFFFFFF	; Set bit indicating RESET
 Exit    = 01000000,FFFFFFFF,00000000,FFFFFFFF	; Set bit indicating Exit 
 Coin    = 00000000,FFFFFFFF,00000000,FF7FFFFF

 Start   = 00000000,FFFFFF7F,00000080,FFFFFFFF	; Start game

#        	       	<rom name="qb3_le_t7.bin" size="8192" crc="adaaee4c" sha1="35c6bbb50646a3ddec12f115fcf3f2283e15b0a0" region="maincpu" offset="0"/>
#        	       	<rom name="qb3_lo_p7.bin" size="8192" crc="72f6199f" sha1="ae8f81f218940cfc3aef8f82dfe8cc14220770ce" region="maincpu" offset="1"/>
#        	       	<rom name="qb3_ue_u7.bin" size="8192" crc="050a996d" sha1="bf29236112746b5925b29fb231f152a4bde3f4f9" region="maincpu" offset="4000"/>
#        	       	<rom name="qb3_uo_r7.bin" size="8192" crc="33fa77a2" sha1="27a6853f8c2614a2abd7bfb9a62c357797312068" region="maincpu" offset="4001"/>
#        	       	<display tag="screen" type="vector" rotate="180" flipx="yes" refresh="38.000000" />
   */
#endif
}

void startFrame_tailgunner (void)
{
#define TG_IO_START   0x80	/* for ioInputs */
#define TG_IO_SHIELDS 0x40
#define TG_IO_FIRE    0x20
#define TG_IO_DOWN    0x10
#define TG_IO_UP      0x08
#define TG_IO_LEFT    0x04
#define TG_IO_RIGHT   0x02
  //#define TG_IO_COIN    0x01
#define TG_SW_ABORT   SW_ABORT	/* for ioSwitches */
#define TG_SW_COIN    0x080
   static int prevButtonState=0;	// for debouncing

   frameCounter += 1;
   DEBUG_OUT("v_WaitRecal(); v_setBrightness(64);v_readButtons();v_readJoystick1Analog(); // %d\n", frameCounter);

   v_WaitRecal ();
   // v_doSound();
   //v_readButtons ();		// update currentButtonState
   //v_readJoystick1Analog ();
   // v_playAllSFX();

   // default inactive:
   ioInputs = initialInputs | TG_IO_LEFT | TG_IO_RIGHT | TG_IO_UP | TG_IO_DOWN | TG_IO_START | TG_IO_SHIELDS | TG_IO_FIRE;
   ioSwitches = initialSwitches | TG_SW_COIN;
   if ((currentButtonState & ~prevButtonState) & VEC_BUTTON_1_1) ioSwitches &= ~TG_SW_COIN;	// only on rising edge
   prevButtonState = currentButtonState;

   // set x and y from joystick
   RCram[42] = JoyX = (currentJoy1X * 5 / 2) & 0xfff;	// crude but the best I've found
   RCram[43] = JoyY = (currentJoy1Y * 5 / 2) & 0xfff;   // WHY ARE THE JOYSTICKS NON-RESPONSIVE IN STANDALONE MODE???

   if (currentButtonState & VEC_BUTTON_1_2) ioInputs &= ~TG_IO_START;
   if (currentButtonState & VEC_BUTTON_1_3) ioInputs &= ~TG_IO_SHIELDS;
   if (currentButtonState & VEC_BUTTON_1_4) ioInputs &= ~TG_IO_FIRE;
}

void startFrame_demon (void)
{
#define DE_IO_P1START   0x01  // 1-player start
#define DE_IO_P1WALK    0x10
#define DE_IO_P1FIRE    0x20
#define DE_IO_P1LEFT    0x04
#define DE_IO_P1RIGHT   0x08
#define DE_IO_P1PANIC   0x0200

#define DE_IO_P2START   0x02  // 2-player start
#define DE_IO_P2WALK    0x2000
#define DE_IO_P2FIRE    0x4000
#define DE_IO_P2LEFT    0x0800
#define DE_IO_P2RIGHT   0x1000
#define DE_IO_P2PANIC   0x0400
  
#define DE_SW_ABORT   SW_ABORT	/* for ioSwitches */
#define DE_SW_COIN    0x080     // Not used in freeplay mode
   //static int prevButtonState=0;	// for debouncing
   frameCounter += 1;
   DEBUG_OUT("v_WaitRecal(); v_setBrightness(64);v_readButtons();v_readJoystick1Analog(); // %d\n", frameCounter);

   v_WaitRecal ();
   // v_doSound();
   v_readButtons ();		// update currentButtonState
   v_readJoystick1Analog ();
   //v_readJoystick2Analog ();  // NOT YET IMPLEMENTED.
   // v_playAllSFX();

   // Unfortunately, it's quite common to press LEFT and RIGHT simultaneously by accident with this
   // layout, and accidentally invoke the configuration screen.  Need to think about how we will
   // handle this...
   
   // default inactive:
   ioInputs = initialInputs | DE_IO_P1LEFT | DE_IO_P1RIGHT | DE_IO_P1START | DE_IO_P1WALK | DE_IO_P1FIRE | DE_IO_P1PANIC
                            | DE_IO_P2LEFT | DE_IO_P2RIGHT | DE_IO_P2START | DE_IO_P2WALK | DE_IO_P2FIRE | DE_IO_P2PANIC;

   // ioSwitches |= DE_SW_COIN;
   ioSwitches = initialSwitches | 0;


   // not used in freeplay mode
   // if ((currentButtonState & ~prevButtonState) & VEC_BUTTON_1_1) ioSwitches &= ~DE_SW_COIN;	// only on rising edge

   // digital joysticks...
   if (currentJoy1X < -30) ioInputs &= ~DE_IO_P1LEFT;
   if (currentJoy1X > 30) ioInputs &= ~DE_IO_P1RIGHT;
   if (currentJoy1Y > 30) ioInputs &= ~DE_IO_P1WALK;
   if (currentJoy1Y < -30) ioInputs &= ~DE_IO_P1PANIC;

   if (currentJoy2X < -30) ioInputs &= ~DE_IO_P2LEFT;
   if (currentJoy2X > 30) ioInputs &= ~DE_IO_P2RIGHT;
   if (currentJoy2Y > 30) ioInputs &= ~DE_IO_P2WALK;
   if (currentJoy2Y < -30) ioInputs &= ~DE_IO_P2PANIC;

   if (currentButtonState & VEC_BUTTON_1_1) ioInputs &= ~DE_IO_P1START;
   if (currentButtonState & VEC_BUTTON_1_2) ioInputs &= ~DE_IO_P2START;

   if (currentButtonState & VEC_BUTTON_1_1) ioInputs &= ~DE_IO_P1LEFT;
   if (currentButtonState & VEC_BUTTON_1_2) ioInputs &= ~DE_IO_P1RIGHT;
   if (currentButtonState & VEC_BUTTON_1_3) ioInputs &= ~DE_IO_P1WALK;
   if (currentButtonState & VEC_BUTTON_1_4) ioInputs &= ~DE_IO_P1FIRE;

   if (currentButtonState & VEC_BUTTON_2_1) ioInputs &= ~DE_IO_P2LEFT;
   if (currentButtonState & VEC_BUTTON_2_2) ioInputs &= ~DE_IO_P2RIGHT;
   if (currentButtonState & VEC_BUTTON_2_3) ioInputs &= ~DE_IO_P2WALK;
   if (currentButtonState & VEC_BUTTON_2_4) ioInputs &= ~DE_IO_P2FIRE;
   //prevButtonState = currentButtonState;
}

void startFrame_speedfreak (void)
{
   static int isInit = 0;
   static int coinKey = 0;
   static int startKey = 0;
   static int gasKey = 0;
   static int gear1Key = 0;
   //static int currentGear = -1;

   frameCounter += 1;
   DEBUG_OUT("v_WaitRecal(); v_setBrightness(64);v_readButtons();v_readJoystick1Analog(); // %d\n", frameCounter);
   v_WaitRecal ();
   // v_doSound();
   v_readButtons ();
   v_readJoystick1Analog ();
   // v_playAllSFX();

    if (isInit == 0)
    {
      ioSwitches = initialSwitches | 0;
      ioInputs = initialInputs | 0xFFFF;
      isInit = 1;
    }

   // coin is button 1 joyport 0
   if (currentButtonState & 1) {
      // Coin = 00000000,FFFFFFFF,00000000,FF7FFFFF
      if (!coinKey) {
	 coinKey = 1;
	 ioSwitches = ioSwitches | 0x0000;
	 ioInputs = ioInputs | 0x0000;

	 ioSwitches = ioSwitches & 0xffff;
	 ioInputs = ioInputs & 0xffff;
      }
   } else {
      if (coinKey) {
	 coinKey = 0;
	 ioSwitches = ioSwitches | 0x0000;
	 ioInputs = ioInputs | 0x0000;

	 ioSwitches = ioSwitches & 0xff7f;
	 ioInputs = ioInputs & 0xffff;
      }
   }

   // start is button 2 joyport 0
   if (currentButtonState & 2) {
      // Start = 00000000,FFFFFF7F,00000080,FFFFFFFF ; Start game
      if (!startKey) {
	 startKey = 1;
	 ioSwitches = ioSwitches | 0x0000;
	 ioInputs = ioInputs | 0x0000;

	 ioSwitches = ioSwitches & 0xffff;
	 ioInputs = ioInputs & 0xFF7F;
      }
   } else {
      if (startKey) {
	 startKey = 0;
	 ioSwitches = ioSwitches | 0x0000;
	 ioInputs = ioInputs | 0x0080;

	 ioSwitches = ioSwitches & 0xffff;
	 ioInputs = ioInputs & 0xffff;
      }
      //currentGear = -1;

   }

   // gas is button 4 joyport 0
   if (currentButtonState & 8) {
      // Gas = 00000000,FFFFFEFF,00000100,FFFFFFFF ; Gas
      if (!gasKey) {
	 gasKey = 1;
	 ioInputs = ioInputs & 0xFEFF;
      }
   } else {
      if (gasKey) {
	 gasKey = 0;
	 ioInputs = ioInputs | 0x0100;
      }
   }















   // gear 1 is button 3 joyport 0
   if (currentButtonState & 4) {
      // Gear1 = 000000E0,FFFFFFEF,00000000,FFFFFFFF ; First Gear
      if (!gear1Key) {
	 gear1Key = 1;
	 ioInputs = ioInputs | 0x00E0;
	 ioInputs = ioInputs & 0xFFEF;
      }
   } else {
      if (gear1Key) {
	 gear1Key = 0;
      }
   }

// bit 0 indicates 0 =  negative/ right
// bit 0 indicates 1 =  positive/ left
// bit 1-3 indicate speed in the direction
// so min speed = 001, max = 111 -> 1-7  

   if ((currentJoy1X > 0) && (currentJoy1X > 30)) {
      // range from 30-127 -> 0-97 / 16 -> 0-6 (+1)
      // left test
      ioInputs = ioInputs & 0xfff0;
      ioInputs = ioInputs | (((((currentJoy1X - 30) / 16) + 1) << 1) + 1);	/* between 1-7 */



      int j = ABS(currentJoy1X-30) / 12 +1; // 0 - 97
      ioInputs = ioInputs & 0xfff0;
      ioInputs = ioInputs | ((j<<1)+1);  /* between 1-7 */


   } else if ((currentJoy1X < 0) && (currentJoy1X < -30)) {
      // right test
      ioInputs = ioInputs & 0xfff0;
      ioInputs = ioInputs | (((((-currentJoy1X) - 30) / 16) + 1) << 1);	/* between 1-7 */

      int j = ABS(currentJoy1X-30) / 12 +1; // 0 - 97
      ioInputs = ioInputs & 0xfff0;
      ioInputs = ioInputs | (j<<1);  /* between 1-7 */


   } else {
      // release should not be necessary, shift is cleared each round!
      ioInputs = ioInputs & 0xfff0;
   }











}
