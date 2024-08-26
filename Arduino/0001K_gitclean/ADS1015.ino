void readAllInputs() {
  adc0 = readADC(0);
  adc1 = readADC(1);
  adc2 = readADC(2);
  adc3 = readADC(3);
}

int16_t readADC(uint8_t channel) {
  uint16_t config = 0xC183; // Default config for AIN0
  switch (channel) {
    case 1:
      config = 0xD183; // Config for AIN1
      break;
    case 2:
      config = 0xE183; // Config for AIN2
      break;
    case 3:
      config = 0xF183; // Config for AIN3
      break;
  }

  // Write config to ADS1015
  Wire.beginTransmission(ADS1015_ADDRESS);
  Wire.write(0x01); // Point to the configuration register
  Wire.write(config >> 8); // MSB of the config register
  Wire.write(config & 0xFF); // LSB of the config register
  Wire.endTransmission();

  delay(10); // Wait for conversion to complete

  // Read conversion result
  Wire.beginTransmission(ADS1015_ADDRESS);
  Wire.write(0x00); // Point to the conversion register
  Wire.endTransmission();
  Wire.requestFrom(ADS1015_ADDRESS, 2);

  int16_t result = 0;
  if (Wire.available() >= 2) {
    result = (Wire.read() << 8) | Wire.read();
  }

  return result;
}



