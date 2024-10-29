// Gauges
import controlP5.*;

class DataWindow extends PApplet {
  ControlP5 cp5;
  PApplet parent;
  
  DataWindow(PApplet parent) {
    this.parent = parent;
    PApplet.runSketch(new String[]{this.getClass().getSimpleName()}, this);
  }
  
  public void settings() {
    size(500, 600);
  }
  
  public void setup() {
    cp5 = new ControlP5(this);
     surface.setTitle("Gauges"); // Name of window

    // Create gauges for displaying data
    cp5.addKnob("accelX")
       .setPosition(50, 10)
       .setRange(-2, 2)
       .setValue(0)
       .setLabel("Accel X")
       .setRadius(50); // Set the radius to 50 (adjust as needed)
    
    cp5.addKnob("accelY")
       .setPosition(150, 10)
       .setRange(-2, 2)
       .setValue(0)
       .setLabel("Accel Y")
       .setRadius(50); // Set the radius to 50 (adjust as needed)
    
    cp5.addKnob("accelZ")
       .setPosition(250, 10)
       .setRange(-2, 2)
       .setValue(0)
       .setLabel("Accel Z")
       .setRadius(50); // Set the radius to 50 (adjust as needed)
    
    cp5.addKnob("gyroX")
       .setPosition(50, 250)
       .setRange(-250, 250)
       .setValue(0)
       .setLabel("Gyro X")
       .setRadius(50); // Set the radius to 50 (adjust as needed)
    
    cp5.addKnob("gyroY")
       .setPosition(150, 250)
       .setRange(-250, 250)
       .setValue(0)
       .setLabel("Gyro Y")
       .setRadius(50); // Set the radius to 50 (adjust as needed)
    
    cp5.addKnob("gyroZ")
       .setPosition(250, 250)
       .setRange(-250, 250)
       .setValue(0)
       .setLabel("Gyro Z")
       .setRadius(50); // Set the radius to 50 (adjust as needed)
    
    cp5.addKnob("temperature")
       .setPosition(50, 485)  // 
       .setRange(-5, 45)        // values were decresed from -40 ,85 for better read  -5 and +45 are OK for LiON
       .setValue(0)
       .setLabel("Temp")
       .setRadius(50); // Set the radius to 50 (adjust as needed)
   
   cp5.addKnob("uTfieldX")
       .setPosition(50, 370)   
       .setRange(-200, 200)      
       .setValue(0)
       .setLabel("uT field X")
       .setRadius(50); // Set the radius to 50 (adjust as needed)    
 
  cp5.addKnob("uTfieldY")
       .setPosition(150, 370)   
       .setRange(-200, 200)      
       .setValue(0)
       .setLabel("uT field Y")
       .setRadius(50); // Set the radius to 50 (adjust as needed)   

  cp5.addKnob("uTfieldZ")
       .setPosition(250, 370)   
       .setRange(-200, 200)      
       .setValue(0)
       .setLabel("uT field Z")
       .setRadius(50); // Set the radius to 50 (adjust as needed) 
       
   cp5.addKnob("Volt0")
       .setPosition(350, 10)   
       .setRange(-10, 10)      
       .setValue(0)
       .setLabel("V in 0")
       .setRadius(50); // Set the radius to 50 (adjust as needed)  
       
    cp5.addKnob("Volt1")
       .setPosition(350, 130)   
       .setRange(-10, 10)      
       .setValue(0)
       .setLabel("V in 1")
       .setRadius(50); // Set the radius to 50 (adjust as needed)  
    
     cp5.addKnob("Volt2")
       .setPosition(350, 250)   
       .setRange(-10, 10)      
       .setValue(0)
       .setLabel("V in 2")
       .setRadius(50); // Set the radius to 50 (adjust as needed)  
       
    cp5.addKnob("Volt3")
       .setPosition(350, 370)   
       .setRange(-10, 10)      
       .setValue(0)
       .setLabel("V in 3")
       .setRadius(50); // Set the radius to 50 (adjust as needed)
    
    cp5.addKnob("AcAngX")
       .setPosition(150, 485)   
       .setRange(-10, 10)      
       .setValue(0)
       .setLabel("Acc.Ang. X")
       .setRadius(50); // Set the radius to 50 (adjust as needed)  
   cp5.addKnob("AcAngY")
       .setPosition(250, 485)   
       .setRange(-10, 10)      
       .setValue(0)
       .setLabel("Acc.Ang. Y")
       .setRadius(50); // Set the radius to 50 (adjust as needed)  
       
  // this is redundant information with angulat so we remove it
  /*  
    cp5.addKnob("pitch")
       .setPosition(150, 200)   
       .setRange(-180, 180)      // from -180 to 180 change from 0 to 360
       .setValue(0)
       .setLabel("Pitch")
       .setRadius(50); // Set the radius to 50 (adjust as needed)
    
    cp5.addKnob("roll")
       .setPosition(250, 200)
       .setRange(-180, 180)    // from -180/180 to 0/360
       .setValue(0)
       .setLabel("Roll")
       .setRadius(50); // Set the radius to 50 (adjust as needed)
    
    cp5.addKnob("yaw")
       .setPosition(350, 200)
       .setRange(-180, 180)
       .setValue(0)
       .setLabel("Yaw")
       .setRadius(50); // Set the radius to 50 (adjust as needed)
   */ 
    cp5.addKnob("angularX")
       .setPosition(50, 130)   //50 200
       .setRange(-250, 250)
       .setValue(0)
       .setLabel("Angular X")
       .setRadius(50); // Set the radius to 50 (adjust as needed)
    
    cp5.addKnob("angularY")
       .setPosition(150, 130)   //150 200
       .setRange(-250, 250)
       .setValue(0)
       .setLabel("Angular Y")
       .setRadius(50); // Set the radius to 50 (adjust as needed)
    
    cp5.addKnob("angularZ")
       .setPosition(250, 130)  // 350 200
       .setRange(-250, 250)
       .setValue(0)
       .setLabel("Angular Z")
       .setRadius(50); // Set the radius to 50 (adjust as needed)
  }
  
  public void draw() {
    // bacgroudn colored in RGB
    background(1,1,1);
    
    // Update the gauges with the latest data
    cp5.getController("accelX").setValue(((MainSketch) parent).acceleration[0]);
    cp5.getController("accelY").setValue(((MainSketch) parent).acceleration[1]);
    cp5.getController("accelZ").setValue(((MainSketch) parent).acceleration[2]);
    cp5.getController("gyroX").setValue(((MainSketch) parent).gyro[0]);
    cp5.getController("gyroY").setValue(((MainSketch) parent).gyro[1]);
    cp5.getController("gyroZ").setValue(((MainSketch) parent).gyro[2]);
    cp5.getController("temperature").setValue(((MainSketch) parent).temperature);
    cp5.getController("uTfieldX").setValue(((MainSketch) parent).magnetcNormalise[0]);      // send values in uTesla units
    cp5.getController("uTfieldY").setValue(((MainSketch) parent).magnetcNormalise[1]);
    cp5.getController("uTfieldZ").setValue(((MainSketch) parent).magnetcNormalise[2]);
    cp5.getController("Volt0").setValue(((MainSketch) parent).voltNormalise[0]);
    cp5.getController("Volt1").setValue(((MainSketch) parent).voltNormalise[1]);  
    cp5.getController("Volt2").setValue(((MainSketch) parent).voltNormalise[2]);
    cp5.getController("Volt3").setValue(((MainSketch) parent).voltNormalise[3]);  
    cp5.getController("AcAngX").setValue(((MainSketch) parent).AccAng[0]);
    cp5.getController("AcAngY").setValue(((MainSketch) parent).AccAng[1]);
    /*
    cp5.getController("pitch").setValue(((MainSketch) parent).pitch);
    cp5.getController("roll").setValue(((MainSketch) parent).roll);
    cp5.getController("yaw").setValue(((MainSketch) parent).yaw);
    */
    cp5.getController("angularX").setValue(((MainSketch) parent).angular[0]/2);
    cp5.getController("angularY").setValue(((MainSketch) parent).angular[1]/2);
    cp5.getController("angularZ").setValue(((MainSketch) parent).angular[2]/2);
  }
}
