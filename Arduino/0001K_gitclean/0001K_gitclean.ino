#include "FS.h"                // SD Card ESP32
#include "SD_MMC.h"            // SD Card ESP32
#include "soc/soc.h"           // Disable brownour problems
#include "soc/rtc_cntl_reg.h"  // Disable brownour problems
#include "driver/rtc_io.h"
#include <esp_sleep.h>          
#include <EEPROM.h>            
// ############# A
#include<Wire.h>
#include <MPU6050_tockn.h>      
MPU6050 mpu6050(Wire);
#define SDA 0
#define SCL 16
// ## for MPU6050
float ax,ay,az;
float gx,gy,gz;
float t;
float pitch,roll,yaw;
float x,y,z;
float acAngX,acAngY;            // acceleration angle spped 
// ### other setups
unsigned long indeks =0;        // odliczanie zapisywania do pliku
unsigned int zrzucamcos=0;      // odliczanie zrzucania
String data = "";                           // 1 string read from conf    ;ekomode;ilosc_petli;intVar3;intVar4;;
  // 4 int val read from conf.txt file  example strucutre - only one line ;1;10;0;90;M;V;100.02;0;0;450;0;0;0;0;
  int ekomode =1;                          // ekomode 1=on 0=off 
  int ilosc_petli=10;                      // how often we write agregaded values to SD output file shoudl be 1 each read - fast SD wereout to 50 - RAM is limited but SD is slowed reduced
  int intVar3=0;                             // clear eeprom - data file wil 
  int intVar4=90;                            // Sleep time - in ms default = 90ms    
  int gSetup=2500;                              // How logn we wait to stabilize in ms after powerup                        update() method calculate angle by accelerometer and gyroscope using complementary filter.
  float gyroSetup=0.98;                      // gyro setup                      If you want to set 0.1 to accelerometer coefficient and 0.9 to gyroscope coefficient, your code is
  float calSetup=0.02;                       //                                   calibration setup  filtered_angle = (0.02 * accel) + (0.98 * gyro)  MPU6050 mpu6050(Wire, 0.1, 0.9);
  int intVar11=0;                             // for future use 11 position in csv file
  int intVar12=0;                             //  12 positon
  int intVar13=0;
  int intVar14=0;
char charVar1, charVar2;                    // 2x charater
float floatVar;                             // 1x float
int index2 = 0;                              //  index variable  for conf.txt
#define ADS1015_ADDRESS 0x48                  // Default I2C address for ADS1015
int16_t adc0, adc1, adc2, adc3;
#define HMC5983_ADDRESS 0x1E // I2C address for HMC5983
int16_t mx, my, mz;
//#define ekomode 1               // aktywacja 
//#define ilosc_petli 10          // jezeli petla bedzie co np 100ms to 10x100= zrzut na SD co 1 sekunde
String path2="UNKNOWNVALUE";
// ############### ogarnianie nazwy pliku - licznik 
#define EEPROM_SIZE 1
int dataNumber = 0;

// #####################################################################################################
// ## lines that are append to txt file each write cycle to SD
String rdata;
// ######################################################################################
// ## Setup
// ###################
void setup() {
  // ####################################################################################
  // ## lest wait for 1s after power up
  delay(1000);                // delay after power UP - to stablize all 
  btStop();
 //  WRITE_PERI_REG(RTC_CNTL_BROWN_OUT_REG, 0); //disable brownout detector
 pinMode(33, OUTPUT);         // wbudowany LED tylni aly 
  Serial.begin(115200);
      // File counter to name
          // in conf.txt variable 3 i set to 1 so we start from 0
          if(intVar3==1){
            EEPROM.begin(EEPROM_SIZE);
            EEPROM.write(0,0);                    // write 0 to eeprom cell
            EEPROM.commit();                      // write
          }
        EEPROM.begin(EEPROM_SIZE);                // normal startup
        dataNumber = EEPROM.read(0) + 1;
        // Path where new data will be saved in SD Card
        String path = "/data" + String(dataNumber) +".txt";
        path2 = String(path);
        Serial.printf("file name: %s\n", path2.c_str());
        EEPROM.write(0, dataNumber);                    // count all
        EEPROM.commit();                                // write

  if (!SD_MMC.begin("/sdcard", true)) {                 // turn of white LED on PCB its connected to sd sens signal
    Serial.println("Card Mount Failed");
    return;
  }
  uint8_t cardType = SD_MMC.cardType();
  if (cardType == CARD_NONE) {
    Serial.println("No SD_MMC card attached");
    return;
  }
  Serial.print("SD_MMC Card Type: ");
  if (cardType == CARD_MMC) {
    Serial.println("MMC");
  } else if (cardType == CARD_SD) {
    Serial.println("SDSC");
  } else if (cardType == CARD_SDHC) {
    Serial.println("SDHC");
  } else {
    Serial.println("UNKNOWN");
  }
uint64_t cardSize = SD_MMC.cardSize() / (1024 * 1024);

// ####################################################################################################
// Read from SD_MMC file conf.txt    - then we setup rest                   
  readFile(SD_MMC, "/conf.txt");  
  Serial.printf("Used space: %lluMB\n", SD_MMC.usedBytes() / (1024 * 1024));
// #####################################################
// ## GY521
// ####################################################
Wire.begin(SDA, SCL);
delay(100);
mpu6050.begin();
mpu6050.calcGyroOffsets(true,50,gSetup);            // 50ms after call this and gSetup
Serial.println("MPU6050 Start");

  Serial.println("V0001K");
   mpu6050.update();   // sensor.read();
  delay(100);
    mpu6050.update(); //sensor.read();
  delay(100);
// ########################### conf ADS1015 if enabled
if(charVar2=='V'){
Wire.begin(); // Initialize I2C communication
  // Configure ADS1015 for AIN0 and AIN1 with 1.024V
  Wire.beginTransmission(ADS1015_ADDRESS);
  Wire.write(0x01); // Point to the configuration register
  Wire.write(0xC2); // MSB of the config register (single-ended, AIN0, 1.024V, 1600SPS)
  Wire.write(0x83); // LSB of the config register (continuous conversion mode)
  Wire.endTransmission();
  // Configure ADS1015 for AIN2 and AIN3 with 2.048V
  Wire.beginTransmission(ADS1015_ADDRESS);
  Wire.write(0x01); // Point to the configuration register
  Wire.write(0xE2); // MSB of the config register (single-ended, AIN2, 2.048V, 1600SPS)
  Wire.write(0x83); // LSB of the config register (continuous conversion mode)
  Wire.endTransmission();
  Serial.println("ADS1015 setup complete");
}
// ###############################################################
// ## HMC mangetoemetr setup inf enabled
if(charVar1=='M'){
Wire.begin(); // Initialize I2C communication
Wire.beginTransmission(HMC5983_ADDRESS);
  Wire.write(0x00); // Point to Configuration Register A
  Wire.write(0x78); // 0111 1000: 8 samples averaged, 15Hz data output rate, normal measurement mode
  Wire.endTransmission();
  // Configuration Register B
  Wire.beginTransmission(HMC5983_ADDRESS);
  Wire.write(0x01); // Point to Configuration Register B
  Wire.write(0x20); // Gain configuration (default)
  Wire.endTransmission();
  // Mode Register
  Wire.beginTransmission(HMC5983_ADDRESS);
  Wire.write(0x02); // Point to Mode Register
  Wire.write(0x00); // Continuous measurement mode
  Wire.endTransmission();
  Serial.println("HMC5983 setup complete");
}
// debug delay
//delay(10000);
 
 // ###################################################################################################
 // ##   ENABLE wakeup timer for each loop if ekomode is active
   if(ekomode==1 ){
      esp_sleep_enable_timer_wakeup(intVar4*10000); // 90ms * 10000 in microseconds  (100000); // 100ms in microseconds
   }
// #####################################################################################################
// ############### END OF SETUP ########################################################################   
}

// ########## *************************************************************##############
void loop() {
  indeks++;       // numer eventu od powercycle
  zrzucamcos++;   // dodatkowy licznik
  gy521read();
  // if Voltage readout was enable then :
  if(charVar2=='V'){
    readAllInputs();
  }
  // if magneto enabled than
  if(charVar1=='M'){
    readXYZ();
  }
  if(zrzucamcos==ilosc_petli && ekomode==1 ){
    digitalWrite(33, LOW);                          //led ON 
    const char* cstr = rdata.c_str();           // zamieniamy zebrany string na cstring
    appendFile(SD_MMC, path2.c_str(), cstr);    // nadpisanie
    rdata.clear();//                            //czyszczenie stringu
    zrzucamcos=0;                               //czyszcenie miennej
    digitalWrite(33, HIGH);                         // led off
    esp_light_sleep_start(); 
  }
  // esp_light_sleep_start();                      
  if(zrzucamcos==ilosc_petli && ekomode==0 ){                                  //if ekomode is set to 0 then we read with delay intVar4
    digitalWrite(33, LOW);                          //led ON 
    const char* cstr = rdata.c_str();           // zamieniamy zebrany string na cstring
    appendFile(SD_MMC, path2.c_str(), cstr);    // nadpisanie
    rdata.clear();//                            //czyszczenie stringu
    zrzucamcos=0;                               //czyszcenie miennej
    digitalWrite(33, HIGH);                         // led off
    delay(intVar4);                                 // each value 
  }
}