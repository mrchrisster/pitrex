
#include <stdio.h>
#include <stdlib.h> // atoi
#include <string.h>

#include <baremetal/rpi-gpio.h>
#include <baremetal/rpi-aux.h>
#include <bcm2835_vc.h>
#include <ff.h> 

#include <pitrex/pitrexio-gpio.h>
#include <vectrex/vectrexInterface.h>
#include <vectrex/baremetalUtil.h>
#include <vectrex/osWrapper.h>
#include <vectrex/mathSupport.h>

#include <baremetal/vectors.h>

static FATFS fat_fs;		/* File system object */
GlobalMemSettings **settingsPointer;
GlobalMemSettings loaderSettings;

typedef struct MenuItemNew {
  int id;
  char *DISPLAYNAME;
  char *dir;
  char *img;
  char *param1; // max 127 chars
  char *param2; // max 127 chars
  const signed char *icon;
  const signed char *smallIcon; // used for parent display
  void *parent;
  void *child;
  void *left;
  void *right;
  char *scrolltext;
  char *text[];
} MenuItemNew;
MenuItemNew *currentMenuItem;



void cleanup_before_linux (void)
{
	/*
	 * this function is called just before we call linux
	 * it prepares the processor for linux
	 *
	 * we turn off caches etc ...
	 */
	mmu_disable(); //dcache_disable(); + icache_disable(); + clean_data_cache();
	cache_flush(); /* flush I/D-cache */
}

char *filesInDir[1000][40];
char *filesInDir2[1000][40];
int currentSelectedItem = 0;
int currentSelectedItem2 = 0;
int currentSelectedItem3 = 0;
#define MAX_LOAD (1024*1024*100) // 100 MB

// for dev only
void reloadLoader()
{
    v_removeIRQHandling();
    void *progSpace = (void *) 0x8000; 
    char *FILE_NAME = "pitrex.img";
    
    FRESULT rc_rd = FR_DISK_ERR;
    FIL file_object_rd;
    rc_rd = f_open(&file_object_rd, FILE_NAME, (unsigned char) FA_READ);
    
    v_noSound();
    
    printf("Loading: %s \r\n", FILE_NAME);
    unsigned int fsize = MAX_LOAD;

    rc_rd = f_read(&file_object_rd, progSpace, fsize, &fsize);
    if ( rc_rd!= FR_OK)
    {
      printf("loaderMain.c: loadAndStart(): File not loaded (%s) (size got = %i)\r\n", FILE_NAME, rc_rd);
      f_close(&file_object_rd);
    }
    else
    {
        f_close(&file_object_rd);

        printf("Starting loaded file... \r\n");
        isb();
        dsb();
        dmb();
        cleanup_before_linux();
    // correct start registers and jump to 8000
    __asm__ __volatile__(
        "mov r5, #0x0080   \n\t"
        "ldr r0, [r5]      \n\t"
        "mov r5, #0x0084   \n\t"
        "ldr r1, [r5]      \n\t"
        "mov r5, #0x0088   \n\t"
        "ldr r2, [r5]      \n\t"
        "ldr pc, = 0x8000  \n\t"
      );
    }
}
 
void loadAndStart(MenuItemNew *item, int button)
{
    v_removeIRQHandling();

    void *progSpace = (void *) 0x8000; 
    char *FILE_NAME = item->img;
    loaderSettings.lastSelection = item;
    
    // parameter 3 always contains button
    // that the selected item was started with!
    loaderSettings.parameter3[0] = button;
    loaderSettings.parameter3[1] = 0;
    
    FRESULT rc_rd = FR_DISK_ERR;
    FIL file_object_rd;
    rc_rd = f_open(&file_object_rd, FILE_NAME, (unsigned char) FA_READ);
    
    v_noSound();
    
    if (rc_rd != FR_OK)
    {
      printf("loaderMain.c: loadAndStart(): Could not open file %s (%i) \r\n", FILE_NAME, rc_rd);
    }
    else
    {
      /*			
	FIL* fp, 	/* Pointer to the file object 
	void* buff,	/* Pointer to data buffer 
	UINT btr,	/* Number of unsigned chars to read 
	UINT* br	/* Pointer to number of unsigned chars read 
      */
      printf("Loading: %s \r\n", FILE_NAME);
      unsigned int fsize = MAX_LOAD;

      rc_rd = f_read(&file_object_rd, progSpace, fsize, &fsize);
      if ( rc_rd!= FR_OK)
      {
        printf("loaderMain.c: loadAndStart(): File not loaded (%s) (size got = %i)\r\n", FILE_NAME, rc_rd);
        f_close(&file_object_rd);
      }
      else
      {
          f_close(&file_object_rd);
          int c=0;
          if ((item->param1 != 0) || (item->id == 9999) || (item->id == 66) || (item->id == 8888))
          {
            char *parameter = item->param1;

			// choose random game (only first 40 games in dir)
			if (item->id == 66)
            {
			srand(time(NULL)); 
			int randomgame = rand() % 40;
			parameter = (char *) &(filesInDir[randomgame][0]);
			
			}
			
            if (item->id == 9999)
            {
              parameter = (char *) &(filesInDir[currentSelectedItem][0]);
            }
			 if (item->id == 8888)
            {
			// Adding static demo path for now
			char str1[30] = "demos/"; 			
			char *str2 = (char *) &(filesInDir2[currentSelectedItem3][0]);;
			strncat(str1, str2, 25);
			char *result = str1;
			parameter = result;
			  
            }
            while (*parameter != (char) 0)
            {
              loaderSettings.parameter1[c++] =  (unsigned char) *parameter;
              parameter++;
              if (c==126) break;
            } 
          }
          loaderSettings.parameter1[c]= (unsigned char) 0;

          c=0;
          if (item->param2 != 0)
          {
            char *parameter = item->param2;
            while (*parameter != (char) 0)
            {
              loaderSettings.parameter2[c++] =  (unsigned char) *parameter;
              parameter++;
              if (c==126) break;
            } 
          }

          if (item->id == 6000)
          {
              loaderSettings.parameter1[0] = currentSelectedItem2;
          }
          

          
          
          
          loaderSettings.parameter2[c]= (unsigned char) 0;

		  
		  
		  
          printf("Starting loaded file... \r\n");
          isb();
          dsb();
          dmb();
          cleanup_before_linux();
	  // correct start registers and jump to 8000
	  __asm__ __volatile__(
	      "mov r5, #0x0080   \n\t"
	      "ldr r0, [r5]      \n\t"
	      "mov r5, #0x0084   \n\t"
	      "ldr r1, [r5]      \n\t"
	      "mov r5, #0x0088   \n\t"
	      "ldr r2, [r5]      \n\t"
	      "ldr pc, = 0x8000  \n\t"
		);
      }
    }
}



#include "ymStuff.i"


char sampleBuffer[200*1000]; // max 200k ym buffer
unsigned int sampleSize = 0;
int loadRAW(TCHAR *FILE_NAME)
{
    FRESULT rc_rd = FR_DISK_ERR;
    FIL file_object_rd;
    rc_rd = f_open(&file_object_rd, FILE_NAME, (unsigned char) FA_READ);

    if (rc_rd != FR_OK)
    {
      printf("Could not open file %s (%i) \r\n", FILE_NAME, rc_rd);
    }
    else
    {
    /*          
    FIL* fp,    /* Pointer to the file object 
    void* buff, /* Pointer to data buffer 
    UINT btr,   /* Number of unsigned chars to read 
    UINT* br    /* Pointer to number of unsigned chars read 
    */
      printf("Loading: %s \r\n", FILE_NAME);
      unsigned int fsize = 200*1000-1;
      rc_rd = f_read(&file_object_rd, sampleBuffer, fsize, &fsize);
      if ( rc_rd!= FR_OK)
      {
          printf("File not loaded (size got = %i)\r\n", fsize);
          f_close(&file_object_rd);
          return 0;
      }
      else
      {
      f_close(&file_object_rd);
      // file is loaded
      printf("File loaded successfully (%i)!\r\n",fsize);
      sampleSize = fsize;
      }
    }
    return 1;
}

/*int loadAndPlayRAW()
{
  loadRAW("pitrexSample.raw");
  v_playDirectSampleAll(sampleBuffer, sampleSize, 15000);     
  return 1;
}
/**/

extern int __bss_start__;
extern int __bss_end__;
double pitrexSize=0;
int selectionMade = 0;
void initMenu();
void displayMenu();

void initTestRoms();

int skipWave = 0;
// for now INI setting just stupidly overwrite other saved settings!
static int loaderIniHandler(void* user, const char* section, const char* name, const char* value)
{
  #define MATCH_NAME(n) strcmp(name, n) == 0
  if (MATCH_NAME("SKIP_WAV")) 
  {
    skipWave = atoi(value);
  }
  return 1;
}


extern int clipActive;
extern int clipminX;
extern int clipminY;
extern int clipmaxX;
extern int clipmaxY;
extern int clipMode;

int fall = 0;
int blow = 0;


void c_irq_handler (void) {
}

static void KeyPressedHandler (const char *pString)
{
  printf("<%s>", pString);
}
void doBitmap();

/** Main function - we'll never return from here */
void loaderMain()
{
  resetImportantStuff();
  printf("Loader starting...\r\n");
  printf("BSS start: %X, end: %X\r\n", &__bss_start__, &__bss_end__);
  printf("SettingPointer: %08x, settings: %0x08\r\n", settingsPointer, &loaderSettings);
 
 
  settingsPointer = (GlobalMemSettings **)0x0000008c;
  *settingsPointer = &loaderSettings;
  
  tweakVectors();

  printf("Start mounting fs...\r\n");
  FRESULT result = f_mount(&fat_fs, (const TCHAR *) "0:", (unsigned char) 1);
  if (result != FR_OK) 
  {
    vectrexinit(1); // pitrex
    v_init(); // vectrex interface
    printf("loaderMain.c: loaderMain(): NO filesystem...!\r\n");
    printf("loaderMain.c: loaderMain(): f_mount failed! %d\r\n", (int) result);
    v_error("MOUNT FAILED");
  }
  else
  { 
      printf("FAT filesystem found!\r\n");
  }

  vectrexinit(1); // pitrex
  v_init(); // vectrex interface
  printf("Loader: init done!\r\n");
  
  int ymloaded;
  int s = 0;
  int bDir = 1;
  int b = 30;
  char *ss[] = {"PITREX"};
  
//  v_initKeyboard(); // can lead to "waits" after return to the loader, this must be investigated in USPI lib and the timer reset before init again
  
  if (loaderSettings.loader == loaderMain)
  {
    printf("Loader is reinitializing...\r\n");
    initMenu();
    currentMenuItem = (MenuItemNew *)loaderSettings.lastSelection;
    ymloaded = loadYM();
  }
  else
  {
    printf("Loader is initializing...\r\n");
    loaderSettings.loader = loaderMain;
    ini_parse("loader.ini", loaderIniHandler, 0);
    


// doBitmap();
    
    v_setupIRQHandling();  
    v_enableSoundOut(1);
    v_enableButtons(1);
    v_enableJoystickDigital(0,0,0,0);
    v_enableJoystickAnalog(0,0,0,0);
    
 
    v_removeIRQHandling();  
    setCustomClipping(0, -14000, -14000, 14000, 14000);
    clipActive = 0;
    initMenu();
    ymloaded = loadYM();
    if (ymloaded) v_playYM();      
  }


  v_enableJoystickAnalog(1,1,0,0);
  
  v_setupIRQHandling();  
  v_enableSoundOut(1);
  v_enableButtons(1);
  v_setRefresh(50);
  v_disableReturnToLoader();
//  loadRAW("notReverse.raw");
//  v_playIRQSample(sampleBuffer, sampleSize, 10000, PLAY_LOOP);     
  
  while(1)
  {
    v_WaitRecal();
    v_doSound(); // not needed with IRQ Mode
    v_readButtons(); // not needed with IRQ Mode
    v_readJoystick1Analog();// not needed with IRQ Mode
    
    b=b+bDir;
    if (b==70) bDir = -1;
    if (b==20) bDir = 1;
    v_printString(-100, 100, ss[0], 5, b);
    displayMenu();
    //if (ymloaded) v_playYM();      
  }
}

#include "icons.i"





void displayLargeList(const signed char list[])
{
  int count = *list++;

  while (count >0)  
  {
    int y0 = *list++;
    int x0 = *list++;
    int y1 = *list++;
    int x1 = *list++;
    v_directDraw32(x0<<7, y0<<7,x1<<7,y1<<7, 0x5f);
    count --;
  }
}
void displayLargeListUp(const signed char list[])
{
  int count = *list++;

  while (count >0)  
  {
    int y0 = *list++;
    int x0 = *list++;
    int y1 = *list++;
    int x1 = *list++;
    v_directDraw32(x0<<6, (y0<<6)+15000,x1<<6,(y1<<6)+15000, 0x3f);
    count --;
  }
}
MenuItemNew randomMenu;
MenuItemNew demoMenu;
MenuItemNew vectrexMenu;
MenuItemNew settingsMenu =
{
  0,    // ID
  "SETTINGS",    // no name
  0,    // no start directory
  0,    // no start image
  0,    // no parameter
  0,    // no parameter
  0, // icon
  0, // smallicon
  0,    // has no parent
  0,    // ! firstChild must be set
  &demoMenu,    // has no left
  0,    // ! right must be set
  0,    // scrolltext
  0,    // no text
};
MenuItemNew vectrexMenu =
{
  1,    // ID
  0,    // no name
  0,    // no start directory
  0,    // no start image
  0,    // no parameter
  0,    // no parameter
  vectrexIcon, // icon
  vectrexSmallIcon, // smallicon
  0,    // has no parent
  0,    // ! firstChild must be set
  &randomMenu,    // has no left
  0,    // ! right must be set
  0,    // scrolltext
  0,    // no text
};

MenuItemNew arcadeMenu =
{
  2,    // ID
  0,    // no name
  0,    // no start directory
  0,    // no start image
  0,    // no parameter
  0,    // no parameter
  arcadeIcon, // icon
  arcadeSmallIcon, // smallicon
  0,    // has no parent
  0,    // ! firstChild must be set
  0,    // ! left must be set
  &demoMenu,    // ! right must be set
  0,    // scrolltext
  0,    // no text
};
MenuItemNew randomMenu =
{
  66,    // ID
  0,    // no name
  0,    // no start directory
  "vectrexexact.img",    // no start image
  "",    // no parameter
  0,    // no parameter
  vecrandomList, // icon
  0, // smallicon
  0,    // has no parent
  0,    // ! firstChild must be set
  0,    // ! left must be set
  &vectrexMenu,    // ! right must be set
  0,    // scrolltext
  "","","","","", "PLAY A RANDOM","VECTREX GAME"  , 0      // no text
};
/*MenuItemNew videoMenu =
{
  3,    // ID
  0,    // no name
  0,    // no start directory
  0,    // no start image
  0,    // no parameter
  0,    // no parameter
  videoIcon, // icon
  videoSmallIcon, // small icon
  0,    // has no parent
  0,    // ! firstChild must be set
  0,    // ! left must be set
  0,    // ! right must be set
  0,    // scrolltext
  0,    // no text
};

MenuItemNew zBlastMenu;
MenuItemNew audioMenu =
{
  4,    // ID
  0,    // no name
  0,    // no start directory
  0,    // no start image
  0,    // no parameter
  0,    // no parameter
  audioIcon, // icon
  audioSmallIcon, // smallicon
  0,    // has no parent
  0,    // ! firstChild must be set
  0,    // ! left must be set
  &zBlastMenu,    // ! right must be set
  0,    // scrolltext
  0,    // no text
};
MenuItemNew hyperoidsMenu;
MenuItemNew zBlastMenu =
{
  5,    // ID
  "ZBLAST",    // no name
  0,    // no start directory
  "zblast.img",    // no start image
  0,    // no parameter
  0,    // no parameter
  zblastList, // icon
  0, // smallicon
  0,    // has no parent
  0,    // ! firstChild must be set
  &audioMenu,    // ! left must be set
  &hyperoidsMenu,    // ! right must be set
  0,    // scrolltext
  "","","","","A GAME BY MARK RUSSELS", "PITREX PORT KEVIN KOSTER","MUSIC BY ROALD STRAUSS"  , 0  // no text
};
MenuItemNew basicMenu;
MenuItemNew hyperoidsMenu =
{
  5,    // ID
  "HYPEROIDS",    // no name
  0,    // no start directory
  "vhyperoid.img",    // no start image
  0,    // no parameter
  0,    // no parameter
  hyperList, // icon
  0, // smallicon
  0,    // has no parent
  0,    // ! firstChild must be set
  &zBlastMenu,    // ! left must be set
  &basicMenu,    // ! right must be set
  0,    // scrolltext
  "","","","","A GAME BY EDWARD HUTCHINS","LINUX PORT MARK RUSSELS", "PITREX PORT KEVIN KOSTER", 0   // no text
};

MenuItemNew newKindMenu;
MenuItemNew basicMenu =
{
  6,    // ID
  "GS BASIC",    // no name
  0,    // no start directory
  "gsbasic.img",    // no start image
  0,    // no parameter
  0,    // no parameter
  0, // icon
  0, // smallicon
  0,    // has no parent
  0,    // ! firstChild must be set
  &hyperoidsMenu,    // ! left must be set
  &newKindMenu,    // ! right must be set
  0,    // scrolltext
  "","","","","GS BASIC", "BY BOB ALEXANDER",""  , 0  // no text
};

MenuItemNew newKindMenu =
{
  7,    // ID
  "ELITE (BETA)",    // no name
  0,    // no start directory
  "newkind.img",    // no start image
  0,    // no parameter
  0,    // no parameter
  eliteList, // icon
  0, // smallicon
  0,    // has no parent
  0,    // ! firstChild must be set
  &basicMenu,    // ! left must be set
  0,    // ! right must be set
  0,    // scrolltext
  "","","","","A GAME BY CHRISTIAN PINDER","OIGINAL BY", "DAVID BRABEN", "IAN BELL", 0   // no text
};
*/
MenuItemNew demopickMenu;
MenuItemNew demo1Menu;
MenuItemNew demo2Menu;
MenuItemNew demo3Menu;
MenuItemNew demo4Menu;
MenuItemNew exactMenu;
MenuItemNew exactPickOne;
MenuItemNew speedMenu;
MenuItemNew exactMenuRelease;
MenuItemNew starwarsMenu;
MenuItemNew vectorbladeMenu =
{
  100,    // ID
  "VECTORBLADE",    // no name
  0,    // directory
  "vectorblade.img",    // no start image
  0,    // no parameter
  0,    // no parameter
  vb2List, // icon
  0, // smallicon
  &vectrexMenu,    // has parent
  0,    // ! firstChild must be set
  &exactPickOne,    // ! left must be set
  &exactMenuRelease,    // ! right must be set
#define SCROLL_CHAR_START "                          "

  SCROLL_CHAR_START "VECTORBLADE IS MY NEWEST GAME FOR THE VECTREX. VECTORBLADE IS A CLASSIC BOTTOM UP SHOOTER HEAVILY INSPIRED BY WARBLADE FROM EDGAR M. VIGDAL. WARBLADE OR ITS PREDECESSOR DELUXE GALAGA WAS ORIGINALLY DEVELOPED FOR THE AMIGA COMPUTER, BUT WAS LATER ADAPATED TO WINDOWS, OS X AND EVEN IOS.",
  {"","","","","","","A GAME BY MALBAN", 0},    // no text
};
MenuItemNew webWarsMenu;


MenuItemNew webWarsSpeedMenu;
MenuItemNew speedMenu =
{
  102,    // ID
  "",
  0,    // directory 
  "",    // no start image
  "",    // no parameter
  0,    // no parameter
  vecxSpeedList, // icon
  vecxSpeedList, // smallicon
  &vectrexMenu,    // has parent
  &webWarsSpeedMenu,    // ! firstChild must be set
  &vectorbladeMenu,    // ! left must be set
  &exactMenu,    // ! right must be set
  0,    // scrolltext
  {"","","","","  SPEEDY VECTREX", 0},    // no text
};


MenuItemNew berzerkSpeedMenu;
MenuItemNew webWarsSpeedMenu =
{
  1020,    // ID
  " WEB WARS",    // no name
  0,    // directory
  "vectrexspeedy.img",    // no start image
  "original/WEBWARS.BIN",    // no parameter
  0,    // no parameter
  webWarsList, // icon
  0, // smallicon
  &speedMenu,    // has parent
  0,    // ! firstChild must be set
  0,    // ! left must be set
  &berzerkSpeedMenu,    // ! right must be set
  0,    // scrolltext
  {"","","","GCE WILLIAM HAWKINS", "DUNCAN MUIRHEAD", 0},    // no text
};
//MenuItemNew speedMenu;
MenuItemNew mine2SpeedMenu;
MenuItemNew darkTowerSpeedMenu;
MenuItemNew starCastleSpeedMenu;
MenuItemNew narzodSpeedMenu;
MenuItemNew scrambleSpeedMenu;
MenuItemNew solarSpeedMenu;


MenuItemNew berzerkSpeedMenu =
{
  1021,    // ID
  " BERZERK",    // no name
  0,    // directory
  "vectrexspeedy.img",    // no start image
  "original/BERZERK.BIN",    // no parameter
  0,    // no parameter
  berzerkList, // icon
  0, // smallicon
  &speedMenu,    // has parent
  0,    // ! firstChild must be set
  &webWarsSpeedMenu,    // ! left must be set
  &mine2SpeedMenu,    // ! right must be set
  0,    // scrolltext
  {"","","","","GCE CHRIS KING", 0},    // no text
};

MenuItemNew mine2SpeedMenu =
{
  1022,    // ID
  "MINESTORM 2",    // no name
  0,    // directory
  "vectrexspeedy.img",    // no start image
  "original/MSTORM2.BIN",    // no parameter
  0,    // no parameter
  mineStormList, // icon
  0, // smallicon
  &speedMenu,    // has parent
  0,    // ! firstChild must be set
  &berzerkSpeedMenu,    // ! left must be set
  &darkTowerSpeedMenu,    // ! right must be set
  0,    // scrolltext
  {"","","","","GCE JOHN HALL", 0},    // no text
};
MenuItemNew darkTowerSpeedMenu =
{
  1023,    // ID
  "DARK TOWER",    // no name
  0,    // directory
  "vectrexspeedy.img",    // no start image
  "original/DKTOWER.BIN",    // no parameter
  0,    // no parameter
  darkTowerList, // icon
  0, // smallicon
  &speedMenu,    // has parent
  0,    // ! firstChild must be set
  &mine2SpeedMenu,    // ! left must be set
  &starCastleSpeedMenu,    // ! right must be set
  0,    // scrolltext
  {"","","","","GCE JOHN HALL", 0},    // no text
};
MenuItemNew starCastleSpeedMenu =
{
  1024,    // ID
  "STAR CASTLE",    // no name
  0,    // directory
  "vectrexspeedy.img",    // no start image
  "original/CASTLE.BIN",    // no parameter
  0,    // no parameter
  starCastleList, // icon
  0, // smallicon
  &speedMenu,    // has parent
  0,    // ! firstChild must be set
  &darkTowerSpeedMenu,    // ! left must be set
  &narzodSpeedMenu,    // ! right must be set
  0,    // scrolltext
  {"","","","","GCE WILLIAM HAWKINS", 0},    // no text
};
MenuItemNew narzodSpeedMenu =
{
  1025,    // ID
  "FORTRESS OF NARZOD",    // no name
  0,    // directory
  "vectrexspeedy.img",    // no start image
  "original/NARZOD.BIN",    // no parameter
  0,    // no parameter
  narzodList, // icon
  0, // smallicon
  &speedMenu,    // has parent
  0,    // ! firstChild must be set
  &starCastleSpeedMenu,    // ! left must be set
  &scrambleSpeedMenu,    // ! right must be set
  0,    // scrolltext
  {"","","","","GCE JOHN HALL", 0},    // no text
};

MenuItemNew scrambleSpeedMenu =
{
  1026,    // ID
  "SCRAMBLE",    // no name
  0,    // directory
  "vectrexspeedy.img",    // no start image
  "original/SCRAMBLE.BIN",    // no parameter
  0,    // no parameter
  scrambleList, // icon
  0, // smallicon
  &speedMenu,    // has parent
  0,    // ! firstChild must be set
  &narzodSpeedMenu,    // ! left must be set
  &solarSpeedMenu,    // ! right must be set
  0,    // scrolltext
  {"","","","","GCE PAUL ALLEN NEWELL", 0},    // no text
};
MenuItemNew solarSpeedMenu =
{
  1027,    // ID
  "SOLAR QUEST",    // no name
  0,    // directory
  "vectrexspeedy.img",    // no start image
  "original/SOLAR.BIN",    // no parameter
  0,    // no parameter
  solarList, // icon
  0, // smallicon
  &speedMenu,    // has parent
  0,    // ! firstChild must be set
  &scrambleSpeedMenu,    // ! left must be set
  0,    // ! right must be set
  0,    // scrolltext
  {"","","","","GCE SCOTT BODEN", 0},    // no text
};





MenuItemNew exactkarlQuappeMenu;

MenuItemNew exactMenu =
{
  107,    // ID
  "",    // no name
  0,    // directory
  "",    // no start image
  "",    // no parameter
  0,    // no parameter
  vecxExactList, // icon
  vecxExactList, // smallicon
  &vectrexMenu,    // has parent
  &vectorbladeMenu,    // ! firstChild must be set
  &speedMenu,    // ! left must be set
  &demoMenu,    // ! right must be set
  0,    // scrolltext
  {"","","","","  EXACT VECTREX", 0},    // no text
};

MenuItemNew exactkarlQuappeMenu =
{
  1070,    // ID
  "KARL QUAPPE",    // no name
  0,    // directory
  "vectrexexact.img",    // no start image
  "KARL_QUAPPE.BIN",    // no parameter
  0,    // no parameter
  froggerList, // icon
  0, // smallicon
  &vectrexMenu,    // has parent
  0,    // ! firstChild must be set
  &exactMenuRelease,    // ! left must be set
  0,    // ! right must be set
  0,    // scrolltext
  {"","","","","A GAME BY MALBAN","NO PERSISTENCY YET !", 0},    // no text
};
MenuItemNew exactmrBoston;

MenuItemNew exactMenuRelease =
{
  1071,    // ID
  "RELEASE",    // no name
  0,    // directory
  "vectrexexact.img",    // no start image
  "RELEASE.BIN",    // no parameter
  0,    // no parameter
  releaseList, // icon
  0, // smallicon
  &vectrexMenu,    // has parent
  0,    // ! firstChild must be set
  &vectorbladeMenu,    // ! left must be set
  &exactkarlQuappeMenu,    // ! right must be set
//  0,    // scrolltext
  SCROLL_CHAR_START "RELEASE ! THE GAME IS A PORT OF A GAME ORIGINALLY DEVELOPED FOR IOS AND ANDROID BY GIMOGAMES. THE PORT TO VECTREX WAS DONE BY PERMISSION OF THE ORIGINAL AUTHORS.  THANK YOU FOR ALLOWING ME TO PORT THE GAME!",   

  {"","","","","GAME BY MALBAN!","ORIGINAL BY GIMOGAMES", 0},    // no text
};


MenuItemNew exactmrBoston =
{
  1072,    // ID
  "MR BOSTON",    // no name
  0,    // directory
  "vectrexexact.img",    // no start image
  "original/MR_BOSTON.BIN",    // no parameter
  0,    // no parameter
  bostenList, // icon
  0, // smallicon
  &exactMenu,    // has parent
  0,    // ! firstChild must be set
  &exactMenuRelease,    // ! left must be set
  &exactPickOne,    // ! right must be set
//  0,    // scrolltext
 "",
  
  {"","","","","GCE RICHARD MOSZKOWSKI", 0},    // no text
};
MenuItemNew exactPickOne =
{
  9999,    // ID
  "PICK A GAME",    // no name
  0,    // directory
  "vectrexexact.img",    // no start image
  0,    // no parameter
  0,    // no parameter
  0, // icon
  0, // smallicon
  0,    // has parent
  0,    // ! firstChild must be set
  0,   // ! left must be set
  &vectorbladeMenu,    // ! right must be set
//  0,    // scrolltext
  "",
  
  {"", 0},    // no text
};

MenuItemNew demoMenu =
{
  108,    // ID
  "  DEMOS",    // no name
  0,    // directory
  0,    // no start image
  "",    // no parameter
  0,    // no parameter
  demosList, // icon
  demosList, // smallicon
  0,    // has parent
  &demopickMenu,    // ! firstChild must be set
  &arcadeMenu,    // ! left must be set
  &settingsMenu,    // ! right must be set
  0,    // scrolltext
  {"","","","","VECTREX SCENE DEMOS!", 0},    // no text
};

MenuItemNew demopickMenu =
{
  8888,    // ID
  "PICK A DEMO",    // no name
  0,    // directory
  "vectrexexact.img",    // no start image
  0,    // no parameter
  0,    // no parameter
  0, // icon
  0, // smallicon
  0,    // has parent
  0,    // ! firstChild must be set
  0,    // ! left must be set
  &demo1Menu,    // ! right must be set
 // 0,    // scrolltext
  "",    // no text
};





MenuItemNew demo1Menu =
{
  1080,    // ID
  "RAIDING PARTY",    // no name
  0,    // directory
  "vectrexexact.img",    // no start image
  "demos/RaidingParty.bin",    // no parameter
  0,    // no parameter
  0, // icon
  0, // smallicon
  &demoMenu,    // has parent
  0,    // ! firstChild must be set
  0,    // ! left must be set
  &demo2Menu,    // ! right must be set
  0,    // scrolltext
  {"BY FELL AND BEX", 0},    // no text
};

MenuItemNew demo2Menu =
{
  1081,    // ID
  "BRESENHAM",    // no name
  0,    // directory
  "vectrexexact.img",    // no start image
  "demos/bresenham.bin",    // no parameter
  0,    // no parameter
  0, // icon
  0, // smallicon
  &demoMenu,    // has parent
  0,    // ! firstChild must be set
  &demo1Menu,    // ! left must be set
  &demo3Menu,    // ! right must be set
  0,    // scrolltext
  {"NUANCE AND METALVOTZE", 0},    // no text
};

MenuItemNew demo3Menu =
{
  1082,    // ID
  "EPIC REALTIME",    // no name
  0,    // directory
  "vectrexexact.img",    // no start image
  "demos/epic.bin",    // no parameter
  0,    // no parameter
  0, // icon
  0, // smallicon
  &demoMenu,    // has parent
  0,    // ! firstChild must be set
  &demo2Menu,    // ! left must be set
  &demo4Menu,    // ! right must be set
  0,    // scrolltext
  {"NUANCE AND METALVOTZE", 0},    // no text
};
MenuItemNew demo4Menu =
{
  1082,    // ID
  "WHATPG",    // no name
  0,    // directory
  "vectrexexact.img",    // no start image
  "demos/whatpg.bin",    // no parameter
  0,    // no parameter
  0, // icon
  0, // smallicon
  &demoMenu,    // has parent
  0,    // ! firstChild must be set
  &demo3Menu,    // ! left must be set
  0,    // ! right must be set
  0,    // scrolltext
  {"WHERE HAVE ALL", "THE PIXELS GONE", "CMCC", 0},    // no text
};

MenuItemNew speedfreakMenu;
MenuItemNew tailgunnerMenu;



MenuItemNew asteroidsMenu;
MenuItemNew tailgunnerMenu =
{
  2000,    // ID
  "TAILGUNNER",    // no name
  0,    // directory
  "tailgunner.img",    // no start image
  0,    // no parameter
  0,    // no parameter
  tailgunnerList, // icon
  0, // icon
  &arcadeMenu,    // has no parent
  0,    // ! firstChild must be set
  0,    // ! left must be set
  &asteroidsMenu,    // ! right must be set
  0,    // scrolltext
  {"","","","","","VERTICAL VERSION", 0},    // no text
};
MenuItemNew allCinematronicsMenu;
MenuItemNew starwarsMenu =
{
  6001,    // ID
  "STAR WARS",    // no name
  0,    // directory
  "aae.img",    // no start image
  "49",    // no parameter
  0,    // no parameter
  starwarsList, // icon
  0, // icon
  &arcadeMenu,    // has no parent
  0,    // ! firstChild must be set
  &asteroidsMenu,    // ! left must be set
  &allCinematronicsMenu,    // ! right must be set
  0,    // scrolltext
  {"","","","","", 0},    // no text
};

MenuItemNew asteroidsMenu =
{
  2001,    // ID
  "ASTEROIDS",    // no name
  0,    // directory
  "asteroids_sbt.img",    // no start image
  0,    // no parameter
  0,    // no parameter
  asteroidList, // icon
  0, // icon
  &arcadeMenu,    // has no parent
  0,    // ! firstChild must be set
  &tailgunnerMenu,    // ! left must be set
  &starwarsMenu,    // ! right must be set
  0,    // scrolltext
  {"","","","","","VERTICAL VERSION", 0},    // no text
};

MenuItemNew simMenu;
MenuItemNew allCinematronicsMenu =
{
  5000,    // ID
  "CINEMATRONICS",    // no name
  0,    // directory
  0,    // no start image
  0,    // no parameter
  0,    // no parameter
  0, // icon
  0, // icon
  &arcadeMenu,    // has no parent
  &speedfreakMenu,    // ! firstChild must be set
  &asteroidsMenu,    // ! left must be set
  &simMenu,    // ! right must be set
  0,    // scrolltext
  {"A MULTI EMULATOR","VERY MUCH WORK IN","PROGRESS","","GRAHAMS PASSION!", 0},    // no text
};

MenuItemNew battleZoneMenu;
MenuItemNew aaeMenu;
MenuItemNew simMenu =
{
  5000,    // ID
  "ATARI",    // no name
  0,    // directory
  0,    // no start image
  0,    // no parameter
  0,    // no parameter
  0, // icon
  0, // icon
  &arcadeMenu,    // has no parent
  &battleZoneMenu,    // ! firstChild must be set
  &allCinematronicsMenu,    // ! left must be set
  &aaeMenu,    // ! right must be set
  0,    // scrolltext
  {"A MULTI EMULATOR","","","","", 0},    // no text
};


MenuItemNew aaeMenu =
{
  6000,    // ID
  "AAE",    // no name
  0,    // directory
  "aae.img",    // no start image
  0,    // no parameter
  0,    // no parameter
  0, // icon
  0, // icon
  0,    // has no parent
  0,    // ! firstChild must be set
  &simMenu,    // ! left must be set
  0,    // ! right must be set
  0,    // scrolltext
  {"","","","","", 0},    // no text
};



MenuItemNew blackWidowMenu;
MenuItemNew battleZoneMenu =
{
  2002,    // ID
  "BATTLE ZONE",    // no name
  0,    // directory
  "battlezone.img",    // no start image
  0,    // no parameter
  0,    // no parameter
  bzList, // icon
  0, // icon
  &simMenu,    // has no parent
  0,    // ! firstChild must be setvecxExactList
  0,    // ! left must be set
  &blackWidowMenu,    // ! right must be set
  0,    // scrolltext
  {"","","","","","WORK IN PROGRESS!!","FLICKER, NO SOUND!",  0},    // no text
};
MenuItemNew redBaronMenu;
MenuItemNew blackWidowMenu =
{
  2003,    // ID
  "BLACK WIDOW",    // no name
  0,    // directory
  "blackwidow.img",    // no start image
  0,    // no parameter
  0,    // no parameter
  teklaList, // icon
  0, // icon
  &simMenu,    // has no parent
  0,    // ! firstChild must be set
  &battleZoneMenu,    // ! left must be set
  &redBaronMenu,    // ! right must be set
  0,    // scrolltext
  {"","","","","WORK IN PROGRESS!!","FLICKER, NO SOUND!",  0},    // no text
};
MenuItemNew lunarMenu;
MenuItemNew redBaronMenu =
{
  2004,    // ID
  "RED BARON",    // no name
  0,    // directory
  "redbaron.img",    // no start image
  0,    // no parameter
  0,    // no parameter
  baronlist, // icon
  0, // icon
  &simMenu,    // has no parent
  0,    // ! firstChild must be set
  &blackWidowMenu,    // ! left must be set
  &lunarMenu,    // ! right must be set
  0,    // scrolltext
  {"","","","","WORK IN PROGRESS!!","FLICKER, NO SOUND!",  0},    // no text
};

MenuItemNew gravitarMenu;
MenuItemNew lunarMenu =
{
  2005,    // ID
  "LUNAR LANDER",    // no name
  0,    // directory
  "lunar.img",    // no start image
  0,    // no parameter
  0,    // no parameter
  landerList, // icon
  0, // icon
  &simMenu,    // has no parent
  0,    // ! firstChild must be set
  &redBaronMenu,    // ! left must be set
  &gravitarMenu,    // ! right must be set
  0,    // scrolltext
  {"","","","","WORK IN PROGRESS!","NO SOUND!",  0},    // no text
};
MenuItemNew spaceDuelMenu;
MenuItemNew gravitarMenu =
{
  2006,    // ID
  "GRAVITAR",    // no name
  0,    // directory
  "gravitar.img",    // no start image
  0,    // no parameter
  0,    // no parameter
  gravitarList, // icon
  0, // icon
  &simMenu,    // has no parent
  0,    // ! firstChild must be set
  &lunarMenu,    // ! left must be set
  &spaceDuelMenu,    // ! right must be set
  0,    // scrolltext
  {"","","","","WORK IN PROGRESS!","NO SOUND!",  0},    // no text
};
MenuItemNew tempestMenu;
MenuItemNew spaceDuelMenu =
{
  2007,    // ID
  "SPACE DUEL",    // no name
  0,    // directory
  "spaceduel.img",    // no start image
  0,    // no parameter
  0,    // no parameter
  duelList, // icon
  0, // icon
  &simMenu,    // has no parent
  0,    // ! firstChild must be set
  &gravitarMenu,    // ! left must be set
  &tempestMenu,    // ! right must be set
  0,    // scrolltext
  {"","","","","WORK IN PROGRESS!!","FLICKER, NO SOUND!",  0},    // no text
};
MenuItemNew asteroids2Menu;
MenuItemNew tempestMenu =
{
  2008,    // ID
  "TEMPEST",    // no name
  0,    // directory
  "tempest.img",    // no start image
  0,    // no parameter
  0,    // no parameter
  tempestList, // icon
  0, // icon
  &simMenu,    // has no parent
  0,    // ! firstChild must be set
  &spaceDuelMenu,    // ! left must be set
  &asteroids2Menu,    // ! right must be set
  0,    // scrolltext
  {"","","","","WORK IN PROGRESS!!","FLICKER, NO SOUND!",  0},    // no text
};
MenuItemNew asteroidsDeluxeMenu;
MenuItemNew asteroids2Menu =
{
  2009,    // ID
  "ASTEROIDS (NO SBT)",    // no name
  0,    // directory
  "asteroids.img",    // no start image
  0,    // no parameter
  0,    // no parameter
  0, // icon
  0, // icon
  &simMenu,    // has no parent
  0,    // ! firstChild must be set
  &tempestMenu,    // ! left must be set
  &asteroidsDeluxeMenu,    // ! right must be set
  0,    // scrolltext
  {"","","","","WORK IN PROGRESS!!","FLICKER, NO SOUND!","","EVEN CRASHES!",  0},    // no text
};

MenuItemNew speedfreakMenu;
MenuItemNew asteroidsDeluxeMenu =
{
  2010,    // ID
  "ASTEROIDS DELUXE",    // no name
  0,    // directory
  "deluxe.img",    // no start image
  0,    // no parameter
  0,    // no parameter
  0, // icon
  0, // icon
  &simMenu,    // has no parent
  0,    // ! firstChild must be set
  &asteroids2Menu,    // ! left must be set
  0,    // ! right must be set
  0,    // scrolltext
  {"WORK IN PROGRESS!!","FLICKER, NO SOUND!","","DISTORTED ASTEROIDS!",  0},    // no text
};

MenuItemNew armorAttackMenu;
MenuItemNew speedfreakMenu =
{
  5001,    // ID
  "SPEEDFREAK",    // no name
  0,    // directory
  "cine.img",    // no start image
  "speedfreak",    // no parameter
  0,    // no parameter
  speedfrkList, // icon
  0, // icon
  &allCinematronicsMenu,    // has no parent
  0,    // ! firstChild must be set
  0,    // ! left must be set
  &armorAttackMenu,    // ! right must be set
  0,    // scrolltext
  {"","","CINEMATRONICS EMU","","WORK IN PROGRESS!!","NO UPPER GEARS",  0},    // no text
};

MenuItemNew boxingbugsMenu;
MenuItemNew armorAttackMenu =
{
  5002,    // ID
  "ARMOR ATTACK",    // no name
  0,    // directory
  "cine.img",    // no start image
  "armorattack",    // no parameter
  0,    // no parameter
  armoraList, // icon
  0, // icon
  &allCinematronicsMenu,    // has no parent
  0,    // ! firstChild must be set
  &speedfreakMenu,    // ! left must be set
  &boxingbugsMenu,    // ! right must be set
  0,    // scrolltext
  {"","","","","CINEMATRONICS EMU","","WORK IN PROGRESS!!","WITHOUT OVERLAY...",  0},    // no text
};

MenuItemNew demonMenu;
MenuItemNew boxingbugsMenu =
{
  5003,    // ID
  "BOXING BUGS",    // no name
  0,    // directory
  "cine.img",    // no start image
  "boxingbugs",    // no parameter
  0,    // no parameter
  bbList, // icon
  0, // icon
  &allCinematronicsMenu,    // has no parent
  0,    // ! firstChild must be set
  &armorAttackMenu,    // ! left must be set
  &demonMenu,    // ! right must be set
  0,    // scrolltext
  {"","","","","CINEMATRONICS EMU","","NOT WORKING YET","INPUTS MISSING",  0},    // no text
};
MenuItemNew ripoffMenu;
MenuItemNew demonMenu =
{
  5004,    // ID
  "DEMON",    // no name
  0,    // directory
  "cine.img",    // no start image
  "demon",    // no parameter
  0,    // no parameter
  demonList, // icon
  0, // icon
  &allCinematronicsMenu,    // has no parent
  0,    // ! firstChild must be set
  &boxingbugsMenu,    // ! left must be set
  &ripoffMenu,    // ! right must be set
  0,    // scrolltext
  {"","","","","CINEMATRONICS EMU","","SORT OF...",  0},    // no text
};
MenuItemNew spaceWarsMenu;
MenuItemNew ripoffMenu =
{
  5005,    // ID
  "RIPOFF",    // no name
  0,    // directory
  "cine.img",    // no start image
  "ripoff",    // no parameter
  0,    // no parameter
  ripoffList, // icon
  0, // icon
  &allCinematronicsMenu,    // has no parent
  0,    // ! firstChild must be set
  &boxingbugsMenu,    // ! left must be set
  &spaceWarsMenu,    // ! right must be set
  0,    // scrolltext
  {"","","","","CINEMATRONICS EMU","","WORK IN PROGRESS",  0},    // no text
};
MenuItemNew starcastleMenu;
MenuItemNew spaceWarsMenu =
{
  5006,    // ID
  "SPACE WARS",    // no name
  0,    // directory
  "cine.img",    // no start image
  "spacewars",    // no parameter
  0,    // no parameter
  0, // icon
  0, // icon
  &allCinematronicsMenu,    // has no parent
  0,    // ! firstChild must be set
  &ripoffMenu,    // ! left must be set
  &starcastleMenu,    // ! right must be set
  0,    // scrolltext
  {"","","","","CINEMATRONICS EMU","","INPUT NOT WORKING",  0},    // no text
};
MenuItemNew sundanceMenu;
MenuItemNew starcastleMenu =
{
  5007,    // ID
  "STAR CASTLE",    // no name
  0,    // directory
  "cine.img",    // no start image
  "starcastle",    // no parameter
  0,    // no parameter
  0, // icon
  0, // icon
  &allCinematronicsMenu,    // has no parent
  0,    // ! firstChild must be set
  &spaceWarsMenu,    // ! left must be set
  &sundanceMenu,    // ! right must be set
  0,    // scrolltext
  {"","","","","CINEMATRONICS EMU","","NOT WORKING YET",  0},    // no text
};
MenuItemNew waroftheworldsMenu;
MenuItemNew sundanceMenu =
{
  5008,    // ID
  "SUNDANCE",    // no name
  0,    // directory
  "cine.img",    // no start image
  "sundance",    // no parameter
  0,    // no parameter
  sundanceList, // icon
  0, // icon
  &allCinematronicsMenu,    // has no parent
  0,    // ! firstChild must be set
  &starcastleMenu,    // ! left must be set
  &waroftheworldsMenu,    // ! right must be set
  0,    // scrolltext
  {"","","","","CINEMATRONICS EMU","","NOT FINISHED",  0},    // no text
};
MenuItemNew barrierMenu;
MenuItemNew waroftheworldsMenu =
{
  5009,    // ID
  "WAR OF THE WORLDS",    // no name
  0,    // directory
  "cine.img",    // no start image
  "waroftheworlds",    // no parameter
  0,    // no parameter
  0, // icon
  0, // icon
  &allCinematronicsMenu,    // has no parent
  0,    // ! firstChild must be set
  &sundanceMenu,    // ! left must be set
  &barrierMenu,    // ! right must be set
  0,    // scrolltext
  {"","","","","CINEMATRONICS EMU","","NOT WORKING",  0},    // no text
};
MenuItemNew qb3Menu;
MenuItemNew cosmicchasmMenu;
MenuItemNew solarquestMenu;
MenuItemNew barrierMenu =
{
  5010,    // ID
  "BARRIER",    // no name
  0,    // directory
  "cine.img",    // no start image
  "barrier",    // no parameter
  0,    // no parameter
  barrierList, // icon
  0, // icon
  &allCinematronicsMenu,    // has no parent
  0,    // ! firstChild must be set
  &waroftheworldsMenu,    // ! left must be set
  &solarquestMenu,    // ! right must be set
  0,    // scrolltext
  {"","","","","CINEMATRONICS EMU","","STRANGE GAME",  0},    // no text
};

// I don't know how to load cosmic chasm...
MenuItemNew cosmicchasmMenu =
{
  5011,    // ID
  "COSMIC CHASM",    // no name
  0,    // directory
  "cine.img",    // no start image
  "cosmicchasm",    // no parameter
  0,    // no parameter
  0, // icon
  0, // icon
  &allCinematronicsMenu,    // has no parent
  0,    // ! firstChild must be set
  &barrierMenu,    // ! left must be set
  &qb3Menu,    // ! right must be set
  0,    // scrolltext
  {"","","","","CINEMATRONICS EMU","","NOT WORKING NEEDS 68000","",  0},    // no text
};
// Not qorking and crashing....
MenuItemNew qb3Menu =
{
  5012,    // ID
  "QB3",    // no name
  0,    // directory
  "cine.img",    // no start image
  "qb3",    // no parameter
  0,    // no parameter
  0, // icon
  0, // icon
  &allCinematronicsMenu,    // has no parent
  0,    // ! firstChild must be set
  &barrierMenu,    // ! left must be set
  &solarquestMenu,    // ! right must be set
  0,    // scrolltext
  {"","","","","CINEMATRONICS EMU","","CRASHING",  0},    // no text
};
MenuItemNew starhawkMenu;
MenuItemNew solarquestMenu =
{
  5013,    // ID
  "SOLAR QUEST",    // no name
  0,    // directory
  "cine.img",    // no start image
  "solarquest",    // no parameter
  0,    // no parameter
  0, // icon
  0, // icon
  &allCinematronicsMenu,    // has no parent
  0,    // ! firstChild must be set
  &barrierMenu,    // ! left must be set
  &starhawkMenu,    // ! right must be set
  0,    // scrolltext
  {"","","","","CINEMATRONICS EMU","","INPUT NOT WORKING",  0},    // no text
};
MenuItemNew warriorMenu;
MenuItemNew starhawkMenu =
{
  5014,    // ID
  "STAR HAWK",    // no name
  0,    // directory
  "cine.img",    // no start image
  "starhawk",    // no parameter
  0,    // no parameter
  shawkList, // icon
  0, // icon
  &allCinematronicsMenu,    // has no parent
  0,    // ! firstChild must be set
  &solarquestMenu,    // ! left must be set
  &warriorMenu,    // ! right must be set
  0,    // scrolltext
  {"","","","","CINEMATRONICS EMU","","WORKING",  0},    // no text
};
MenuItemNew tailgunner2Menu;
MenuItemNew warriorMenu =
{
  5015,    // ID
  "WARRIOR",    // no name
  0,    // directory
  "cine.img",    // no start image
  "warrior",    // no parameter
  0,    // no parameter
  warriorList, // icon
  0, // icon
  &allCinematronicsMenu,    // has no parent
  0,    // ! firstChild must be set
  &starhawkMenu,    // ! left must be set
  &tailgunner2Menu,    // ! right must be set
  0,    // scrolltext
  {"","","","","CINEMATRONICS EMU","WORKING", "DIFFICULT WITHOUT","OVERLAY",  0},    // no text
};
MenuItemNew tailgunner2Menu =
{
  5016,    // ID
  "TAILGUNNER",    // no name
  0,    // directory
  "cine.img",    // no start image
  "tailgunner",    // no parameter
  0,    // no parameter
  tailgunnerList, // icon
  0, // icon
  &allCinematronicsMenu,    // has no parent
  0,    // ! firstChild must be set
  &warriorMenu,    // ! left must be set
  0,    // ! right must be set
  0,    // scrolltext
  {"","","","","CINEMATRONICS EMU","","INPUT NOT WORKING",  0},    // no text
};


/*

MenuItemNew blablaMenu;
MenuItemNew badAppleMenu =
{
  300,    // ID
  "BAD APPLE",    // no name
  0,    // directory
  "vectrexvideo.img",    // no start image
  "vectrex/movies",    // no parameter
  "BadApple.bin",    // no parameter
  badAppleList, // icon
  0, // icon
  &videoMenu,    // has no parent 
  0,    // ! firstChild must be set
  0,    // ! left must be set
  &blablaMenu,    // ! right must be set
  0,    // scrolltext
  {"", "", "","THE CLIP EVERY!", "MACHINE MUST SHOW!", 0},    // no text
}; 
MenuItemNew laLineaMenu;
MenuItemNew blablaMenu =
{
  301,    // ID
  "BLA BLA",    // no name
  0,    // directory
  "vectrexvideo.img",    // no start image
  "vectrex/movies",    // no parameter
  "BlaBla.bin",    // no parameter
  blablaList, // icon
  0, // icon
  &videoMenu,    // has no parent
  0,    // ! firstChild must be set
  &badAppleMenu,    // ! left must be set
  &laLineaMenu,    // ! right must be set
  0,    // scrolltext
  {"","","","VERY RYTHMIC,", "LA LINEA STYLE", 0},    // no text
};
MenuItemNew badAppleDeMenu;
MenuItemNew laLineaMenu =
{
  302,    // ID
  "LA LINEA",    // no name
  0,    // directory
  "vectrexvideo.img",    // no start image 
  "vectrex/movies",    // no parameter
  "LaLinea.bin",    // no parameter
  lineaList, // icon
  0, // icon
  &videoMenu,    // has no parent
  0,    // ! firstChild must be set
  &blablaMenu,    // ! left must be set
  &badAppleDeMenu,    // ! right must be set
  0,    // scrolltext
  {"","","","", "ITALIEN LA LINEA", 0},    // no text
};
MenuItemNew badAppleDeMenu =
{
  303,    // ID
  "BAD APPLE DE",    // no name
  0,    // directory
  "vectrexvideo.img",    // no start image
  "vectrex/movies",    // no parameter
  "BadAppleDE.bin",    // no parameter
  badAppleList, // icon
  0, // icon
  &videoMenu,    // has no parent
  0,    // ! firstChild must be set
  &laLineaMenu,    // ! left must be set
  0,    // ! right must be set
  0,    // scrolltext
  {"","","","A GERAMN VERSION", "OF THE WELL KNOWN CLIP", 0},    // no text
};

MenuItemNew purpleMenu;
MenuItemNew bohemianMenu =
{
  400,    // ID
  "QUEEN",    // no name
  0,    // directory
  "vectrexaudio.img",    // no start image
  "vectrex/waves",    // no parameter
  "Bohemian.bin",    // no parameter
  0, // icon
  0, // icon
  &audioMenu,    // has no parent
  0,    // ! firstChild must be set
  0,    // ! left must be set
  &purpleMenu,    // ! right must be set
  0,    // scrolltext
  {"DIGITIZED MUSIC", "SAMPLED WITH 12KHZ", 0},    // no text
};
MenuItemNew purpleMenu =
{
  401,    // ID

  "PRINCE",    // no name
  0,    // directory
  "vectrexaudio.img",    // no start image
  "vectrex/waves",    // no parameter
  "PurpleRain.bin",    // no parameter
  0, // icon
  0, // icon
  &audioMenu,    // has no parent
  0,    // ! firstChild must be set
  &bohemianMenu,    // ! left must be set
  0,    // ! right must be set
  0,    // scrolltext
  {"DIGITIZED MUSIC", "SAMPLED WITH 12KHZ", 0},    // no text
};
*/
int scrollReset = 1;

int loadFileNames();
int loadFileNamesDemo();

void initMenu()
{
  currentMenuItem = &vectrexMenu;

  vectrexMenu.right = &arcadeMenu;
  vectrexMenu.child = &exactPickOne;

  arcadeMenu.left = &vectrexMenu;
  //arcadeMenu.right = &videoMenu;
  arcadeMenu.child = &tailgunnerMenu;
  
  /*videoMenu.left = &arcadeMenu;
  videoMenu.right = &audioMenu;
  videoMenu.child = &badAppleMenu;

  audioMenu.left = &videoMenu;
  audioMenu.child = &bohemianMenu;*/
  selectionMade = 0;
  currentMenuItem = &vectrexMenu;
  initTestRoms();

  scrollReset = 1;
}

int testOneRomId(int id)
{
  char *testPath;
  switch (id)
  {
    case 1071: // release
    {
      testPath = "vectrex/RELEASE.BIN";
      break;
    }
    case 2000: // tailgunner
    {
      testPath = "roms/tailg.zip";
      break;
    }
    case 2001: // asteroids
    {
      testPath = "roms/asteroid2.zip";
      break;
    }
    case 2002: // battleZone
    {
      testPath = "roms/bzone.zip";
      break;
    }
    case 2003: // blackWidow
    {
      testPath = "roms/bwidow.zip";
      break;
    }
    case 2004: // red baron
    {
      testPath = "roms/redbaron.zip";
      break;
    }
    case 2005: // "LUNAR LANDER"
    {
      testPath = "roms/llander.zip";
      break;
    }
    case 2006: // GRAVITAR
    {
      testPath = "roms/gravitar.zip";
      break;
    }
    case 2007: // SPACE DUEL
    {
      testPath = "roms/spacduel.zip";
      break;
    }
    case 2008: // TEMPEST
    {
      testPath = "roms/tempest.zip";
      break;
    }
    case 2009: // Asteroid non sbt
    {
      testPath = "roms/asteroid2.zip";
      break;
    }
    case 2010: // Asteroid deluce
    {
      testPath = "roms/astdelux.zip";
      break;
    }
    
    default:
      return 1; // ok
      break;
  }
  FRESULT rc_rd = FR_DISK_ERR;
  FIL file_object_rd;
  rc_rd = f_open(&file_object_rd, testPath, (unsigned char) FA_READ);
  
  if (rc_rd != FR_OK)
  {
//    printf("File not found!\r\n");
    return 0;
  }
  f_close(&file_object_rd);
  return 1;
}
    int yPos = 0;

int allRomOks[10000]; // lokup table... yes - slightly oversized :-)
void initTestRoms()
{
  for (int i=0; i<10000;i++)
  {
    allRomOks[i] = testOneRomId(i);
  }
}


int testRom(MenuItemNew *m)
{
  return allRomOks[m->id];
}

char *scrollpointer=0;
int scroll_y;
int scroll_x;
int scroll_x_offset;
int scrollDelay;

void displayMenuItem(MenuItemNew *m)
{
  if (m->icon != 0)
  {
    displayLargeList(m->icon);
  }
  if (m->parent != 0)
  {
    MenuItemNew *p = m->parent;
    if (p->smallIcon != 0)
    {
      displayLargeListUp(p->smallIcon);
    }
    else if (p->DISPLAYNAME != 0)
    {
      v_printString(-20, 100, p->DISPLAYNAME, 3, 0x57);
    }
    else 
    {
      const signed char *list = upIcon;
      int count = *list++;

      while (count >0)  
      {
        int y0 = *list++;
        int x0 = *list++;
        int y1 = *list++;
        int x1 = *list++;
        v_directDraw32( (x0<<6), (y0<<6) +(110<<7),(x1<<6) ,(y1<<6)+(110<<7), 0x5f);
        count --;
      }
    }
  }
  if (m->left != 0)
  {
    const signed char *list = leftIcon;
    int count = *list++;

    while (count >0)  
    {
      int y0 = *list++;
      int x0 = *list++;
      int y1 = *list++;
      int x1 = *list++;
      v_directDraw32((x0<<6) -((110)<<7), y0<<6,(x1<<6) -((110)<<7),y1<<6, 0x5f);
      count --;
    }
  }

  if (m->right != 0)
  {
    const signed char *list = rightIcon;
    int count = *list++;

    while (count >0)   
    {
      int y0 = *list++;
      int x0 = *list++;
      int y1 = *list++;
      int x1 = *list++;
      v_directDraw32((x0<<6) +((110)<<7), y0<<6,(x1<<6) +((110)<<7),y1<<6, 0x5f);
      count --;
    }
  }
  if (m->child != 0)
  {
    const signed char *list = downIcon;
    int count = *list++;

    while (count >0)  
    {
      int y0 = *list++;
      int x0 = *list++;
      int y1 = *list++;
      int x1 = *list++;
      v_directDraw32( (x0<<6), (y0<<6) -(110<<7),(x1<<6) ,(y1<<6)-(110<<7), 0x5f);
      count --;
    }
  }

  if (m->DISPLAYNAME != 0) 
  {
    int l = strlen(m->DISPLAYNAME)*5;
    v_printString(-l, 50, m->DISPLAYNAME, 10, 0x57);

    if (!testRom(m))
    {
      v_printString(-60, -125, "ROM NOT FOUND!", 10, 0x57);
    }
  }

  if (m->text != 0)
  {
    int yPos = 0;
    int count = 0;
    while (m->text[count] != 0)
    {
      v_printString(-40, yPos, m->text[count++], 5, 0x48);
      yPos -= 18;
    }
  }
  if (scrollReset)
  {
    scrollpointer = m->scrolltext;
    scroll_y= -125;
    scroll_x= -80;
    scroll_x_offset= 0;
    scrollReset = 0;
    scrollDelay = 40;
    
  }
  if (m->scrolltext != 0)
  {
     v_printStringMax(-38-(2-(scrollDelay/3) ), scroll_y, scrollpointer, 4, 0x2f, 20);

    scrollDelay--;
    if (scrollDelay <= 0)
    {
      scrollDelay = 6;
      scrollpointer++;
    }

     if (*scrollpointer == 0)scrollReset=1;
  }
}


// return 1 on true
int isNameOk(char *n)
{
  int len = strlen(n);
  if (*n=='.') return 0; // exclude all files starting with a .
  
  if (strcasecmp(".bin", n+len-4) == 0) return 1;
  return 0;
  
}
int isNameOk2(char *n)
{
  int len2 = strlen(n);
  if (*n=='.') return 0; // exclude all files starting with a .
  
  if (strcasecmp(".bin", n+len2-4) == 0) return 1;
  return 0;
  
}
// return 0 on ok
int loadFileNamesDemo()
{
    char *vectrexdemoDir = "vectrex/demos";
	char buf[256];
	DIR *dp;
    dp = opendir ("vectrex/demos");
    // if (chdir(vectrexdemoDir)<0)
    // {
        // printf("loaderMain.c: loadFileNames(): NO vectrex directory found...!\r\n");
        // return -1;
    // }
  
    
    // if (getcwd (buf,256)==0)
    // {
      // printf("loaderMain.c: loadFileNames(): f_getcwd failed (%i) \r\n", errno);
      // chdir("..");
      // return -1;
    // }


    // if (dp == 0)
    // {
      // printf("loaderMain.c: loadFileNames(): opendir failed (%i) \r\n", errno);
      // chdir("..");
      // return -2;
    // }
    dirent *finfo2;
    int i = 0;
    do
    {
      finfo2 =  readdir(dp);
      if (finfo2 != 0)
      {
        if (isNameOk2(finfo2->d_name))
        {
          char *nameToFill2=(char *) &(filesInDir2[i][0]);
          int c=0;
          for (; c<39; c++)
          {
            nameToFill2[c]=finfo2->d_name[c];
            if (nameToFill2[c]==0) break;
          }
          nameToFill2[c]=0;
          i++;
        }
      }
    } while (finfo2 != 0);
    closedir (dp);
    chdir("..");
/*    
    for(int i=0; i<1000; i++)
    {
      if (filesInDir[i][0] != 0)
      {
        printf("%s\n\r",filesInDir[i]);
      }
    }
*/    
    return 0;
}


int loadFileNames()
{
    char *vectrexDir = "vectrex";
    if (chdir(vectrexDir)<0)
    {
        printf("loaderMain.c: loadFileNames(): NO vectrex directory found...!\r\n");
        return -1;
    }
  
    char buf[256];
    if (getcwd (buf,256)==0)
    {
      printf("loaderMain.c: loadFileNames(): f_getcwd failed (%i) \r\n", errno);
      chdir("..");
      return -1;
    }

    DIR *dp;
    dp = opendir (buf);
    if (dp == 0)
    {
      printf("loaderMain.c: loadFileNames(): opendir failed (%i) \r\n", errno);
      chdir("..");
      return -2;
    }
    dirent *finfo;
    int i = 0;
    do
    {
      finfo =  readdir(dp);
      if (finfo != 0)
      {
        if (isNameOk(finfo->d_name))
        {
          char *nameToFill=(char *) &(filesInDir[i][0]);
          int c=0;
          for (; c<39; c++)
          {
            nameToFill[c]=finfo->d_name[c];
            if (nameToFill[c]==0) break;
          }
          nameToFill[c]=0;
          i++;
        }
      }
    } while (finfo != 0);
    closedir (dp);
    chdir("..");
/*    
    for(int i=0; i<1000; i++)
    {
      if (filesInDir[i][0] != 0)
      {
        printf("%s\n\r",filesInDir[i]);
      }
    }
*/    
    return 0;
}


void displayMenu()
{
  displayMenuItem(currentMenuItem);
  if (currentMenuItem->id == 9999)
  {
	loadFileNames();
    int yPos = 0;
    int itemDisplayStart = currentSelectedItem-2;

    if ((itemDisplayStart>=0) && (filesInDir[itemDisplayStart+0][0] != 0))
      v_printString(-40, yPos -0*18, (char *) &(filesInDir[itemDisplayStart][0]), 5, 0x18);

    if ((itemDisplayStart+1>=0) && (filesInDir[itemDisplayStart+1][0] != 0))
      v_printString(-40, yPos-1*18, (char *) &(filesInDir[itemDisplayStart+1][0]), 5, 0x28);

    if (filesInDir[itemDisplayStart+2][0] != 0)
      v_printString(-40, yPos-2*18, (char *) &(filesInDir[itemDisplayStart+2][0]), 5, 0x4f);
    
    if (filesInDir[itemDisplayStart+3][0] != 0)
      v_printString(-40, yPos-3*18, (char *) &(filesInDir[itemDisplayStart+3][0]), 5, 0x28);
    
    if (filesInDir[itemDisplayStart+4][0] != 0)
      v_printString(-40, yPos-4*18, (char *) &(filesInDir[itemDisplayStart+4][0]), 5, 0x18);
  }
  if (currentMenuItem->id == 8888)
  {
	loadFileNamesDemo();
    int yPos = 0;
    int itemDisplayStart = currentSelectedItem3-2;

    if ((itemDisplayStart>=0) && (filesInDir2[itemDisplayStart+0][0] != 0))
      v_printString(-40, yPos -0*18, (char *) &(filesInDir2[itemDisplayStart][0]), 5, 0x18);

    if ((itemDisplayStart+1>=0) && (filesInDir2[itemDisplayStart+1][0] != 0))
      v_printString(-40, yPos-1*18, (char *) &(filesInDir2[itemDisplayStart+1][0]), 5, 0x28);

    if (filesInDir2[itemDisplayStart+2][0] != 0)
      v_printString(-40, yPos-2*18, (char *) &(filesInDir2[itemDisplayStart+2][0]), 5, 0x4f);
    
    if (filesInDir2[itemDisplayStart+3][0] != 0)
      v_printString(-40, yPos-3*18, (char *) &(filesInDir2[itemDisplayStart+3][0]), 5, 0x28);
    
    if (filesInDir2[itemDisplayStart+4][0] != 0)
      v_printString(-40, yPos-4*18, (char *) &(filesInDir2[itemDisplayStart+4][0]), 5, 0x18);
  }

  
  
  
  static char *aaeList[]=
  {
//Lunar Lander Hardware
 "LLANDER1",  
 "LLANDER",   
//Asteroids Hardware
 "METEORTS",  
 "ASTEROCK",  
 "ASTEROIB",  
 "ASTEROI1",  
 "ASTEROID",  
 "ASTDELU1",  
 "ASTDELU2",  
 "ASTDELUX",  
//Midway Omega Race Hardware
 "OMEGRACE",  
 "DELTRACE",  
//BattleZone Hardware
 "BZONE",     
 "BZONE2",    
 "BZONEC",    
 "BZONEP",    
 "REDBARON",  
 "BRADLEY (NOT)",   
//Spacduel Hardware
 "SPACDUEL",  
 "BWIDOW",    
 "GRAVITAR",  
 "GRAVITR2", 
 "GRAVP",     
 "LUNARBAT",  
 "LUNARBA1",  
//Tempest Hardware
 "TEMPESTM",  
 "TEMPEST",   
 "TEMPEST3",  
 "TEMPEST2", 
 "TEMPEST1",  
 "TEMPTUBE",  
 "ALIENST",   
 "VBREAK",    
 "VORTEX",    
//Sega G80 Vector Hardware
 "ZEKTOR",    
 "TACSCAN",   
 "STARTREK",  
 "SPACFURY", 
 "SPACFURA",  
 "SPACFURB",  
 "ELIM2",     
 "ELIM2A",    
 "ELIM2C",    
 "ELIM4",     
 "ELIM4P",    
//Major Havoc Hardware
 "MHAVOC",    
 "MHAVOC2",   
 "MHAVOCRV",  
 "MHAVOCP",   
 "ALPHAONE",  
 "ALPHAONA",  
//Star Wars Hardware
 "STARWARS",  
 "STARWAR1",  
//Quantum Hardware
 "QUANTUM1 (NOT)",  
 "QUANTUM",  
 "QUANTUMP (NOT)",  
//Cinematronics Hardware
 "SOLARQ",    
 "STARCAS",   
 "ARMORA",    
 "BARRIER (NOT)",   
 "SUNDANCE",  
 "WARRIOR",   
 "RIPOFF",    
 "TAILG",     
 "STARHAWK",  
 "SPACEWAR (NOT)",  
 "SPEEDFRK",  
 "DEMON (NOT)",     
 "BOXINGB",   
 "WOTW", 



    0,
    0,
    0,
    0,
    0,
  };

  // aae


  if (currentMenuItem->id == 6000)

  {
    int yPos = 0;
    int itemDisplayStart = currentSelectedItem2-2;

    if ((itemDisplayStart>=0) && (aaeList[itemDisplayStart+0] != 0))
      v_printString(-40, yPos -0*18, (char *) (aaeList[itemDisplayStart]), 5, 0x18);

    if ((itemDisplayStart+1>=0) && (aaeList[itemDisplayStart+1] != 0))
      v_printString(-40, yPos-1*18, (char *) (aaeList[itemDisplayStart+1]), 5, 0x28);

    if (aaeList[itemDisplayStart+2] != 0)
      v_printString(-40, yPos-2*18, (char *) (aaeList[itemDisplayStart+2]), 5, 0x4f);
    
    if (aaeList[itemDisplayStart+3] != 0)
      v_printString(-40, yPos-3*18, (char *) (aaeList[itemDisplayStart+3]), 5, 0x28);
    
    if (aaeList[itemDisplayStart+4] != 0)
      v_printString(-40, yPos-4*18, (char *) (aaeList[itemDisplayStart+4]), 5, 0x18);
  }
  
  
  // navigate
  // navigate with joystick
  // select/start with a button
  

  if ((currentJoy1X>50) && (selectionMade==0))
  {
    if (currentMenuItem->right != 0)
    {
      currentMenuItem = currentMenuItem->right;
      scrollReset = 1;
    }
    selectionMade = 1;
  }
  
  if ((currentJoy1X<-50) && (selectionMade==0))
  {
    if (currentMenuItem->left != 0)
    {
      currentMenuItem = currentMenuItem->left;
      scrollReset = 1;
    }
    selectionMade = 1;
  }
  if ((currentJoy1Y<-50) && (selectionMade==0))
  {
    if (currentMenuItem->child != 0)
    {
      currentMenuItem = currentMenuItem->child;
      scrollReset = 1;
    }

    if (currentMenuItem->id == 9999)
    {
      if (filesInDir[currentSelectedItem+1][0] != 0)
        currentSelectedItem++;
    }    
    if (currentMenuItem->id == 6000)
    {
      if (aaeList[currentSelectedItem2+1] != 0)
        currentSelectedItem2++;
    }      
	if (currentMenuItem->id == 8888)
    {
      if (filesInDir2[currentSelectedItem3+1][0] != 0)
        currentSelectedItem3++;
    }  
    selectionMade = 1;
  }
  if ((currentJoy1Y>50) && (selectionMade==0))
  {
    if (currentMenuItem->parent != 0)
    {
      currentMenuItem = currentMenuItem->parent;
      scrollReset = 1;
    }
    if (currentMenuItem->id == 9999)
    {
      if (currentSelectedItem > 0)
        currentSelectedItem--;
    }    
    if (currentMenuItem->id == 6000)
    {
      if (currentSelectedItem2 > 0)
        currentSelectedItem2--;
    }     
    if (currentMenuItem->id == 8888)
    {
      if (currentSelectedItem3 > 0)
        currentSelectedItem3--;
    }  	
    selectionMade = 1;
  }

  if ((ABS(currentJoy1Y)<20) && (ABS(currentJoy1X)<20)) selectionMade =0;

  if ((currentButtonState&0x0f) == (0x08)) // exactly button 4
  {
    if (currentMenuItem->img != 0) 
    {
	 if (currentMenuItem->id == 66)
	 {
		 int x = 0;
		loadFileNames();

		loadAndStart(currentMenuItem, 4);
	    
		// reloadLoader();
	 }
	 else
	 {
      loadAndStart(currentMenuItem, 4);
     }
	}
    if (currentMenuItem->id == 0)
    {
      v_SettingsGUI(1);
      v_saveIni("vectrexInterface.ini");
    }

  }  
  if ((currentButtonState&0x0f) == (0x01)) // exactly button 1
  {
    if (currentMenuItem->img != 0)
    {
      loadAndStart(currentMenuItem, 1);
    }
  }  
  if ((currentButtonState&0xff) == (0x10)) // exactly button 1 pad 2
  {
    reloadLoader();
  }  
}

