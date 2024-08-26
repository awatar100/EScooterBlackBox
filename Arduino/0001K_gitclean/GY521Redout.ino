void gy521read(){
  mpu6050.update();
  //sensor.read();
  ax    = mpu6050.getAccX();
  ay    = mpu6050.getAccY();
  az    = mpu6050.getAccZ();
  gx    = mpu6050.getGyroX();
  gy    = mpu6050.getGyroY();
  gz    = mpu6050.getGyroZ();
  t     = mpu6050.getTemp();
  pitch = mpu6050.getGyroAngleX();  
  roll  = mpu6050.getGyroAngleY();  
  yaw   = mpu6050.getGyroAngleZ();  
  x     = mpu6050.getAngleX();
  y     = mpu6050.getAngleY();
  z     = mpu6050.getAngleZ();
  acAngX = mpu6050.getAccAngleX();
  acAngY = mpu6050.getAccAngleY();
                                    
rdata +=(";");
rdata +=String(indeks);
rdata +=(";");
rdata +=String(ax,3);
rdata +=(";");
rdata +=String(ay,3);
rdata +=(";");
rdata +=String(az,3);
rdata +=(";");
rdata +=String(gx,3);
rdata +=(";");
rdata +=String(gy,3);
rdata +=(";");
rdata +=String(gz,3);
rdata +=(";");
rdata +=String(t,1);
rdata +=(";");
rdata +=String(pitch,3);
rdata +=(";");
rdata +=String(roll,3);
rdata +=(";");
rdata +=String(yaw,3);
rdata +=(";");
rdata +=String(x,3);
rdata +=(";");
rdata +=String(y,3);
rdata +=(";");
rdata +=String(z,3);
rdata +=(";");      //this will stay constant for now
rdata +=String(acAngX,3);
rdata +=(";");
rdata +=String(acAngY,3);
rdata +=(";");  
rdata +=String(adc0);       // if
rdata +=(";");
rdata +=String(adc1);
rdata +=(";");
rdata +=String(adc2);
rdata +=(";");
rdata +=String(adc3);
rdata +=(";");
rdata +=String(mx);
rdata +=(";");
rdata +=String(my);
rdata +=(";");
rdata +=String(mz);
rdata +=("\n");
}