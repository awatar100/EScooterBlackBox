// ################################### SD card functions #############################################
// ##
void readFile(fs::FS &fs, const char *path) {
  Serial.printf("Reading file: %s\n", path);
  File file = fs.open(path);
  if (!file) {
    Serial.println("Failed to open file for reading");
    return;
  }
// ############
// read config and dived it 
while (file.available()) {
  char c = file.read();
  if (c == ';') {
    switch (index2) {
      case 1:
        ekomode = data.toInt();                   // asign ecomod
        break;
      case 2:
        ilosc_petli = data.toInt();
        break;
      case 3:
        intVar3 = data.toInt();
        break;
      case 4:
        intVar4 = data.toInt();
        break;
      case 5:
        charVar1 = data.charAt(0);
        break;
      case 6:
        charVar2 = data.charAt(0);
        break;
      case 7:
        floatVar = data.toFloat();
        break;
      case 8:
        gSetup = data.toInt();
        break;
      case 9:
        gyroSetup = data.toFloat();
        break;
      case 10:
        calSetup = data.toFloat();                  
        break;
      case 11:
        intVar11= data.toInt();                  
        break;
       case 12:
        intVar12 = data.toInt();                  
        break;   
      case 13:
        intVar13 = data.toInt();                  
        break;    
      case 14:
        intVar14 = data.toInt();                  
        break;  
    
    }
    data = ""; // Reset the data string for the next value
    index2++;
  } else {
    data += c; // Append character to data string
  }
}
file.close();
// Print the variables to verify

Serial.print("ekomode: "); Serial.println(ekomode);
Serial.print("ilosc_petli co ile zaposujemy na karte SD: "); Serial.println(ilosc_petli);
Serial.print("intVar3 clear eeprom couter: "); Serial.println(intVar3);
Serial.print("intVar4 how often in ms we wake up: "); Serial.println(intVar4);
Serial.print("calSetup how many cal cycles: "); Serial.println(calSetup);
Serial.print("charVar1: "); Serial.println(charVar1);
Serial.print("charVar2: "); Serial.println(charVar2);
Serial.print("floatVar: "); Serial.println(floatVar);
Serial.print("Control int not used now"); Serial.println(intVar14);
}

void appendFile(fs::FS &fs, const char *path, const char *message) {
  //Serial.printf("Appending to file: %s\n", path);                 // not needed
  File file = fs.open(path, FILE_APPEND);
  if (!file) {
    Serial.println("Failed to open file for appending");
    return;
  }
  if (file.print(message)) {
    //Serial.println("Message appended");                           // niepotrzebne printy 
  } else {
    Serial.println("Append failed");
  }
}

void renameFile(fs::FS &fs, const char *path1, const char *path2) {
  Serial.printf("Renaming file %s to %s\n", path1, path2);
  if (fs.rename(path1, path2)) {
    Serial.println("File renamed");
  } else {
    Serial.println("Rename failed");
  }
}

void deleteFile(fs::FS &fs, const char *path) {
  Serial.printf("Deleting file: %s\n", path);
  if (fs.remove(path)) {
    Serial.println("File deleted");
  } else {
    Serial.println("Delete failed");
  }
}

void testFileIO(fs::FS &fs, const char *path) {
  File file = fs.open(path);
  static uint8_t buf[512];
  size_t len = 0;
  uint32_t start = millis();
  uint32_t end = start;
  if (file) {
    len = file.size();
    size_t flen = len;
    start = millis();
    while (len) {
      size_t toRead = len;
      if (toRead > 512) {
        toRead = 512;
      }
      file.read(buf, toRead);
      len -= toRead;
    }
    end = millis() - start;
    Serial.printf("%u bytes read for %lu ms\n", flen, end);
    file.close();
  } else {
    Serial.println("Failed to open file for reading");
  }

  file = fs.open(path, FILE_WRITE);
  if (!file) {
    Serial.println("Failed to open file for writing");
    return;
  }

  size_t i;
  start = millis();
  for (i = 0; i < 2048; i++) {
    file.write(buf, 512);
  }
  end = millis() - start;
  Serial.printf("%u bytes written for %lu ms\n", 2048 * 512, end);
  file.close();
}