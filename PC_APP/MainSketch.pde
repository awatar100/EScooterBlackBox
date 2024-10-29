// Wygnerowany plik z ESP musi miec prawidlowa konsturkcje tj ostatania kolumna konczy sie ; 19 08 2024 todo - zrobione 
// zmiana EOL na CR LF - zgdonie ze standardem windows 19 08 2024 ToDo? - nie potrzebne LF wystarczy dziala 
// to do Dodac Kalman filter or low pass filter 
// Default value for register B in HMC5983 is 0x20 = +/- 1.3 gauss 0,92 miligauss per LSB conversion factor Xmag=Xmag*0.092 uT
import controlP5.*;
import java.io.BufferedReader;
import java.io.FileReader;
import java.io.IOException;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.PriorityQueue;
import processing.opengl.*;
import toxi.geom.*;
import toxi.processing.*;

ControlP5 cp5;
String[][] csvData;
int currentLine = 0;                      // readed form CSV
int currentLine2 = 0;                     // to update slider 
int interval = 0;
int delay = 100;                         // 100ms delay
int LineNumber = 0;                      // Variable to count the number of lines in file 
boolean isPlaying = false;              // play/pause butto
boolean clearObj = false;                //clear position of 3Dobj and calculation

float[] q = new float[4];
Quaternion quat = new Quaternion(1, 0, 0, 0);

float[] acceleration = new float[3];        // Acceleration variables     INPUT
float[] gyro = new float[3];                // gyro variables             INPUT
float temperature;                          // temp in 'C                 INPUT
float pitch, roll, yaw;                    // this need to be calculated  OUTPUT
float[] angularAcc= new float[3];          // Based only on Gyro angles   INPUT
float[] angular = new float[3];            // angular with acceleration   INPUT
int[] magnetc = new int[3];                // X Y Z magnetic compas values RAW from -2048 to 2047   INPUT
float[] magnetcNormalise = new float[3];   // this we will calculate o have uT so magnetcNormalise=magnetc*0.092 CALCULATED
int[] AdcVals = new int[4];                // ADS1015 values redout  RAW values  INPUT
float[] AccAng=new float[2];              //acceleration angle X and last Y  INPUT
// There are 4 inputs 2 arre in +/- 1.024 second is 2.048
// Resposnible for ADC to V calculation
float FSR1 = 2.048;                         // Full Scale Range in Volts no 1
float FSR2 = 4.096;                         // Full Scale Range in Volts no 2
int RESOLUTION = 4096;                       // 12-bit resolution of an ADC
float LSB_SIZE1 = FSR1 / RESOLUTION;        // Least Significant Bit size
float LSB_SIZE2 = FSR2 / RESOLUTION;       // Least Significant Bit size
float[] voltNormalise = new float[4];  

ToxiclibsSupport gfx;
UIWindow uiWindow;                   // Declare uiWindow variable
CopilotPitchYawRoll copilotPitchYawRoll; // Declare CopilotProposition variable

void setup() {
  size(300, 300, P3D);
  gfx = new ToxiclibsSupport(this);
  cp5 = new ControlP5(this);         // Initialize cp5 in MainSketch   
  uiWindow = new UIWindow(this); // Initialize uiWindow //new UIWindow(this);
  copilotPitchYawRoll = new CopilotPitchYawRoll(this);
  new DataWindow(this);
  surface.setTitle("3D visualisation"); // Name of window
}

void draw() {
  // rgb 
  background(130,130,130);
  lights();
  translate(width / 2, height / 2, 0);
  if (csvData != null && isPlaying && millis() - interval > delay) {
    if (currentLine < csvData.length) {
      processCSVLine(csvData[currentLine]);
      currentLine++;
      interval = millis();
    }
  }  
  // Draw the 3D object
  draw3DObject();
  // Display the rest of the data as graphical information
  displayData();
}
void fileSelected(File selection) {
  if (selection == null) {
    println("No file was selected.");
  } else {
    csvData = parseCSV(selection.getAbsolutePath());
    currentLine = 0; // Reset line counter
   // println("ZALADOWANO!!!");
    ((UIWindow) uiWindow).updateSliderRange(csvData.length); // Update the slider range in UIWindow
    findTopAccelerationEvents(); // Find top acceleration events after loading the file
  }
}

String[][] parseCSV(String filePath) {
  String[][] result = null;
  //int LineNumber = 0; // Variable to count the number of lines
  try {
    BufferedReader br = new BufferedReader(new FileReader(filePath));
    String line;
    ArrayList<String[]> rows = new ArrayList<>();
    while ((line = br.readLine()) != null) {
      String[] columns = line.split(";");
      rows.add(columns);
       LineNumber++;                           // Increment the line count for each line read
    }
    br.close();
    result = new String[rows.size()][];
    rows.toArray(result);
  } catch (IOException e) {
    e.printStackTrace();
  }
  return result;
}
// ###############3
// ## Parse line by line CSV file and provide data for calculation Pitch Yaw Roll
public void processCSVLine(String[] columns) {
    if (columns.length >= 24) {
        acceleration[0] = Float.parseFloat(columns[2]);  // this value is X axis acceleration in +/-2g - no need conversion
        acceleration[1] = Float.parseFloat(columns[3]);  // this value is Y axis acceleration in +/-2g - no need conversion
        acceleration[2] = Float.parseFloat(columns[4]);  // this value is Z axis acceleration in +/-2g - no need conversion
        gyro[0] = Float.parseFloat(columns[5]);           // this value is X axis for gyroscope in range +/- 1000 deg/s - no need conversion
        gyro[1] = Float.parseFloat(columns[6]);           // this value is Y axis for gyroscope in range +/- 1000 deg/s - no need conversion
        gyro[2] = Float.parseFloat(columns[7]);           // this value is Z axis for gyroscope in range +/- 1000 deg/s - no need conversion
        temperature = Float.parseFloat(columns[8]);      // vlue in 'C of an sensor
        angularAcc[0] = Float.parseFloat(columns[9]);    // this value is X axis in degrees from -180 to 180, 0 is when it start, this is based only on gyro readout - no need conversion
        angularAcc[1] = Float.parseFloat(columns[10]);
        angularAcc[2] = Float.parseFloat(columns[11]);
        angular[0] = Float.parseFloat(columns[12]);    // this value is X axis in deg. from -180 to 180, 0 is when it start, this take to considiration acceleration - no need conversion
        angular[1] = Float.parseFloat(columns[13]);      // this value is Y axis in deg. from -180 to 180, 0 is when it start,this take to considiration acceleration - no need conversion
        angular[2] = Float.parseFloat(columns[14]);  // this value is Z axis in deg. from -180 to 180, 0 is when it start, this take to considiration acceleration - no need conversion
        AccAng[0] = Float.parseFloat(columns[15]);    // Tilt angle around the X axis based on the acceleration input in X Y Z axes - output is in degrees - no need conversion
        AccAng[1] = Float.parseFloat(columns[16]);    // Tilt angle around the X axis based on the acceleration input in X Y Z axes - output is in degrees - no need conversion
        AdcVals[0] = Integer.parseInt(columns[17]);     // ADC0 IN value for ADS1015 RAW - need to conversion to Voltage
        AdcVals[1] = Integer.parseInt(columns[18]);       // ADC1 IN
        AdcVals[2] = Integer.parseInt(columns[19]);       // ADC2 IN
        AdcVals[3] = Integer.parseInt(columns[20]);       // ADC3 IN
        magnetc[0] = Integer.parseInt(columns[21]);    // Compas RAW value for X direction - need conversion
        magnetc[1] = Integer.parseInt(columns[22]);    // Compas RAW val for y direction - need conv
        magnetc[2] = Integer.parseInt(columns[23]);    // Compas RAW val for Z direction - need conv
      // Conversion to physical units
        magnetcNormalise[0] = magnetc[0] * 0.092f;
        magnetcNormalise[1] = magnetc[1] * 0.092f;
        magnetcNormalise[2] = magnetc[2] * 0.092f;
        // voltage  
        voltNormalise[0]=AdcVals[0]* LSB_SIZE1;
        voltNormalise[1]=AdcVals[1]* LSB_SIZE1;
        voltNormalise[2]=AdcVals[2]* LSB_SIZE2;
        voltNormalise[3]=AdcVals[3]* LSB_SIZE2;
        
     // Update the CopilotPitchYawRoll with filtered values
        copilotPitchYawRoll.update(acceleration, gyro, angular, magnetcNormalise, voltNormalise);
     // Retrieve the calculated values
        pitch = copilotPitchYawRoll.getPitch();
        roll = copilotPitchYawRoll.getRoll();
        yaw = copilotPitchYawRoll.getYaw();
        // Use the pitch, roll, and yaw values as needed
        // printed values 
        /*
        print(" Pitch: " + pitch);
        print(" Roll: " + roll);
        print(" Yaw: " + yaw);
        print(" Mag: X" +magnetcNormalise[0]);
        print(" MagY: " +magnetcNormalise[1]);  
        println("MagZ: " +magnetcNormalise[2]);  
        */
   }
}

// ######### top 10 eventy
void findTopAccelerationEvents() {
  PriorityQueue<String[]> maxQueue = new PriorityQueue<>(10, new Comparator<String[]>() {
    public int compare(String[] a, String[] b) {
      float aMagnitude = calculateMagnitude(a);
      float bMagnitude = calculateMagnitude(b);
      return Float.compare(bMagnitude, aMagnitude);
    }
  });

  PriorityQueue<String[]> minQueue = new PriorityQueue<>(10, new Comparator<String[]>() {
    public int compare(String[] a, String[] b) {
      float aMagnitude = calculateMagnitude(a);
      float bMagnitude = calculateMagnitude(b);
      return Float.compare(aMagnitude, bMagnitude);
    }
  });

  for (String[] row : csvData) {
    if (row.length >= 15) {
      maxQueue.offer(row);
      minQueue.offer(row);
      if (maxQueue.size() > 10) {
        maxQueue.poll();
      }
      if (minQueue.size() > 10) {
        minQueue.poll();
      }
    }
  }
// update list in to UIWindow
StringBuilder maxEvents = new StringBuilder("Top 10 Maximum Acceleration Events:\n");
  while (!maxQueue.isEmpty()) {
    String[] row = maxQueue.poll();
    maxEvents.append("Line: ").append(row[1]).append(" Acceleration: ").append(row[2]).append(", ").append(row[3]).append(", ").append(row[4]).append("\n");
  }

  StringBuilder minEvents = new StringBuilder("Top 10 Minimum Acceleration Events:\n");
  while (!minQueue.isEmpty()) {
    String[] row = minQueue.poll();
    minEvents.append("Line: ").append(row[1]).append(" Acceleration: ").append(row[2]).append(", ").append(row[3]).append(", ").append(row[4]).append("\n");
  }

  uiWindow.updateAccelerationEvents(maxEvents.toString(), minEvents.toString());
}
  float calculateMagnitude(String[] columns) {
  float x = Float.parseFloat(columns[2]);
  float y = Float.parseFloat(columns[3]);
  float z = Float.parseFloat(columns[4]);
  return sqrt(x * x + y * y + z * z);
}
// #### end top 10 ###########
// #############################
// #### move block
void draw3DObject() {
  pushMatrix();
  // Apply pitch, roll, and yaw rotations
  rotateX(radians(pitch));
  rotateY(radians(yaw));
  rotateZ(radians(roll));
  // Draw a box with different colored sides
  beginShape(QUADS);

// Top face
  fill(255, 0, 0);
  beginShape();
  vertex(-50, -50, 50);
  vertex(50, -50, 50);
  vertex(50, 50, 50);
  vertex(-50, 50, 50);
  endShape(CLOSE);
  // Add "TOP" to the front wall
  fill(0);
  textSize(32);
  text("TOP", -30, 10, 51);
  
  // Green wall bottom
  fill(0, 255, 0);
  beginShape();
  vertex(50, -50, -50);
  vertex(-50, -50, -50);
  vertex(-50, 50, -50);
  vertex(50, 50, -50);
  endShape(CLOSE);
  
  // Left face ok  
  fill(0, 0, 255); // Blue
  beginShape();
  vertex(-50, -50, -50);
  vertex(-50, -50, 50);
  vertex(-50, 50, 50);
  vertex(-50, 50, -50);
  endShape(CLOSE);
  
  // Right face  ok
  fill(255, 255, 0); // Yellow
  beginShape();
  vertex(50, -50, -50);
  vertex(50, -50, 50);
  vertex(50, 50, 50);
  vertex(50, 50, -50);
  endShape(CLOSE);
  
  //  Front face  ok
  fill(0, 255, 255); // Cyan
    beginShape();
  vertex(-50, -50, -50);
  vertex(50, -50, -50);
  vertex(50, -50, 50);
  vertex(-50, -50, 50);
  endShape(CLOSE);
  
  // Back Face  ok
  fill(255, 0, 255); // Magenta
  beginShape();
  vertex(-50, 50, -50);
  vertex(50, 50, -50);
  vertex(50, 50, 50);
  vertex(-50, 50, 50);
  endShape();
 // ###############################################################
 /*
 // ########### drawing acceleration on 3D plane commeted for now
    // Shift the origin 100 pixels to the right
    translate(100, 100, 0); 
    // Draw arrows for acceleration
    // to make them more visible they are multiply 
    strokeWeight(5); // Make arrows thicker
    stroke(0, 255, 0); // Green for X-axis
    line(0, 0, 0, acceleration[0] * 250, 0, 0);    
    stroke(0, 0, 255); // Blue for Y-axis
    line(0, 0, 0, 0, acceleration[1] * 250, 0);
    stroke(255, 0, 0); // Red for Z-axis
    line(0, 0, 0, 0, 0, acceleration[2] * 250);  
   */
    popMatrix();
}

// ##########################################
// ##  Clear 3dobject position
public void resetOrientation() {
        pitch = 0;
        roll = 0;
        yaw = 0;
        clearObj=true;
   copilotPitchYawRoll.resetOrientation(); 
}

void displayData() {
  fill(0);
  textSize(18);
  text("Acceleration: " + acceleration[0] + ", " + acceleration[1] + ", " + acceleration[2], 10, height - 60);
  text("Gyro: " + gyro[0] + ", " + gyro[1] + ", " + gyro[2], 10, height - 45);
  text("Temperature: " + temperature, 10, height - 30);
  text("Pitch: " + pitch + ", Roll: " + roll + ", Yaw: " + yaw, 10, height - 15);
  text("Angular: " + angular[0] + ", " + angular[1] + ", " + angular[2], 10, height);
}
