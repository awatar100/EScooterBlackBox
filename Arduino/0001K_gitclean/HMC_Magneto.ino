void readXYZ() {
  Wire.beginTransmission(HMC5983_ADDRESS);
  Wire.write(0x03); // Point to the data output X MSB register
  Wire.endTransmission();
  Wire.requestFrom(HMC5983_ADDRESS, 6); // Request 6 bytes of data
  if (Wire.available() == 6) {
    mx = (Wire.read() << 8) | Wire.read(); // X-axis data
    mz = (Wire.read() << 8) | Wire.read(); // Z-axis data
    my = (Wire.read() << 8) | Wire.read(); // Y-axis data
  }
}


