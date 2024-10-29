import controlP5.*;
import toxi.geom.*;
import toxi.processing.*;
import java.util.ArrayList;

class CopilotPitchYawRoll extends PApplet {
    ControlP5 cp5;
    PApplet parent;
    float pitch, roll, yaw;
    float[] acceleration = new float[3];
    float[] gyro = new float[3];
    float[] angular = new float[3];
    float[] magnet = new float[3];
    float alpha = 0.98; // Complementary filter constant
    ToxiclibsSupport gfx;
    ArrayList<Float> accelXHistory = new ArrayList<>();
    ArrayList<Float> accelYHistory = new ArrayList<>();
    ArrayList<Float> accelZHistory = new ArrayList<>();
    // other roling chart
    ArrayList<Float> v0History = new ArrayList<>();
    ArrayList<Float> v1History = new ArrayList<>();
    ArrayList<Float> v2History = new ArrayList<>();
    ArrayList<Float> v3History = new ArrayList<>();
       //magnetic
    ArrayList<Float> mXHistory = new ArrayList<>();
    ArrayList<Float> mYHistory = new ArrayList<>();
    ArrayList<Float> mZHistory = new ArrayList<>();
    
    int historySize = 100; // Number of points to display in the rolling chart
    KalmanFilter kalmanFilterX;
    KalmanFilter kalmanFilterY;
    KalmanFilter kalmanFilterZ;
   // ###############################################
   // #### treshold related values   ################
    ArrayList<Float> pitchHistory = new ArrayList<>();
    ArrayList<Float> rollHistory = new ArrayList<>();
    ArrayList<Float> yawHistory = new ArrayList<>();  
    boolean waitForCalibration = true;
    int calibrationCount = 0;
    float[] magnetOffset = new float[3];
    int typeCalc=2;                         //this will be switch for changincg caluclation algortihm Algorithm 0 harmonic mean and Algorithm 1 treshold
  //  boolean useHarmonicMean = false;       // Switch between Algorithm 1 and Algorithm 2
    float accelThreshold = 0.04f;          // nosie factor for acclerometer  bylo 0.04
    float gyroThreshold = 0.5f;            // gyro treshold bylo 0.5
    float mgt1=2.0f;
    float mgt2=2.0f;
    float mgt3=2.0f;
    
    
// ####################################
CopilotPitchYawRoll(PApplet parent) {

        this.parent = parent;
       PApplet.runSketch(new String[]{this.getClass().getSimpleName()}, this);
         //PApplet.runSketch(new String[]{"Custom Window Name"}, this);
        kalmanFilterX = new KalmanFilter(0.1, 0.1, 0.1);
        kalmanFilterY = new KalmanFilter(0.1, 0.1, 0.1);
        kalmanFilterZ = new KalmanFilter(0.1, 0.1, 0.1);
}

public void settings() {
        size(800, 400, P3D);
}

public void setup() {
        cp5 = new ControlP5(this);
        gfx = new ToxiclibsSupport(this);
        surface.setTitle("Rolling chart plotter"); // Name of window
}

public void draw() {
        background(50, 50, 50);
        lights();
        translate(width / 2, height / 2, 0);
        draw3DObject();
        drawAccelerationChart();
        drawVoltageChart();
        drawMagneticChart();
        fill(255);
        // Add text label "Voltage" at specific coordinates
        fill(255); // Set text color to white
        textSize(16); // Set text size
        textAlign(CENTER, CENTER); // Center the text
        text("Voltage [V]", -width / 2 + 60, height / 2 - 385); // 
        
        // Add text label "Acceleration" at specific coordinates
        fill(255); // Set text color to white
        textSize(16); // Set text size
        textAlign(CENTER, CENTER); // Center the text
        text("Acceleration [G]", -width / 2 + 80, height / 2 - 263); // 
        
        // Add text label "Magnetic" at specific coordinates
        fill(255); // Set text color to white
        textSize(16); // Set text size
        textAlign(CENTER, CENTER); // Center the text
        text("Magnetic [uT]", -width / 2 + 80, height / 2 - 143); // 
}
// ########################################################################3
 public void update(float[] acceleration, float[] gyro, float[] angular,float[] magnet, float[] voltNormalise) {
        if (waitForCalibration) {
            calibrateSensors(acceleration, gyro);
            return;
        }

        if ( typeCalc ==0 /*useHarmonicMean*/) {
            updateWithHarmonicMean(acceleration, gyro);
        }
        if ( typeCalc ==1 /*useHarmonicMean*/) {
            updateWithThreshold(acceleration, gyro, magnet);
          //updateWithThreshold(acceleration, gyro);
        }
        if(typeCalc ==2){
        updateWithEuler(angular);
        }

        // Update acceleration history for the rolling chart
        if (accelXHistory.size() >= historySize) {
            accelXHistory.remove(0);
            accelYHistory.remove(0);
            accelZHistory.remove(0);
            
            v0History.remove(0);
            v1History.remove(0);
            v2History.remove(0);
            v3History.remove(0);
            // magnetic history gone
            mXHistory.remove(0);
            mYHistory.remove(0);
            mZHistory.remove(0);
            
        }
        
        accelXHistory.add(acceleration[0]);
        accelYHistory.add(acceleration[1]);
        accelZHistory.add(acceleration[2]);
       // voltage 
        v0History.add(voltNormalise[0]);
        v1History.add(voltNormalise[1]);
        v2History.add(voltNormalise[2]);
        v3History.add(voltNormalise[3]);
        // magnetic
        mXHistory.add(magnet[0]);
        mYHistory.add(magnet[1]);
        mZHistory.add(magnet[2]);
    }

    private void calibrateSensors(float[] acceleration, float[] gyro) {
        if (calibrationCount < 10) {
            calibrationCount++;
        } else {
            waitForCalibration = false;
        }   
        
    }
// ######################################3
//  Algo no 1 update only when treshold are over some values
private void updateWithThreshold(float[] acceleration, float[] gyro, float[] magnet) {
    if (Math.abs(acceleration[0]) > accelThreshold && Math.abs(acceleration[1]) > accelThreshold && Math.abs(acceleration[2]) > accelThreshold &&
        Math.abs(gyro[0]) > gyroThreshold && Math.abs(gyro[1]) > gyroThreshold && Math.abs(gyro[2]) > gyroThreshold &&
        Math.abs(magnet[0]) > mgt1 && Math.abs(magnet[1]) > mgt2 && Math.abs(magnet[2]) > mgt3) {
        
        float dt = 0.1f; // Assuming 10Hz update rate
        float accelPitch = (float) Math.atan2(acceleration[1], Math.sqrt(acceleration[0] * acceleration[0] + acceleration[2] * acceleration[2])) * 180 / PI;
        float accelRoll = (float) Math.atan2(-acceleration[0], acceleration[2]) * 180 / PI;

        this.pitch = alpha * (this.pitch + gyro[0] * dt) + (1 - alpha) * accelPitch;
        this.roll = alpha * (this.roll + gyro[1] * dt) + (1 - alpha) * accelRoll;
        this.yaw += gyro[2] * dt; // Gyro integration for yaw

        // Bound yaw to -180 to 180 degrees
        if (this.yaw > 180) {
            this.yaw -= 360;
        } else if (this.yaw < -180) {
            this.yaw += 360;
        }
    }  
}
// ##############################################################
// Algo no 2 based on eurler and only on agn inputs
private void updateWithEuler(float[] angular) {
        this.yaw = (angular[0]/2);
        this.pitch = (angular[1]/2);
        this.roll = (angular[2]/2);
}
// ###############################################
// ### hsitory reset
public void resetOrientation() {
    pitch = 0;
    roll = 0;
    yaw = 0;
    // Reinitialize the history arrays
    pitchHistory = new ArrayList<>();
    rollHistory = new ArrayList<>();
    yawHistory = new ArrayList<>();
   
    accelXHistory = new ArrayList<>();
    accelYHistory = new ArrayList<>();
    accelZHistory = new ArrayList<>();
    
    v0History = new ArrayList<>();
    v1History = new ArrayList<>();
    v2History = new ArrayList<>();
    v3History = new ArrayList<>();
    
    mXHistory = new ArrayList<>();
    mYHistory = new ArrayList<>();
    mZHistory = new ArrayList<>();
    
    
    calibrationCount = 0;
    waitForCalibration = true;
    // flag in main window reset
    clearObj=false;
}
    private void updateWithHarmonicMean(float[] acceleration, float[] gyro) {
        if (Math.abs(acceleration[0]) > accelThreshold && Math.abs(acceleration[1]) > accelThreshold && Math.abs(acceleration[2]) > accelThreshold &&
            Math.abs(gyro[0]) > gyroThreshold && Math.abs(gyro[1]) > gyroThreshold && Math.abs(gyro[2]) > gyroThreshold) {
            
            float dt = 0.1f; // Assuming 10Hz update rate
            float accelPitch = (float) Math.atan2(acceleration[1], Math.sqrt(acceleration[0] * acceleration[0] + acceleration[2] * acceleration[2])) * 180 / PI;
            float accelRoll = (float) Math.atan2(-acceleration[0], acceleration[2]) * 180 / PI;

            pitchHistory.add(alpha * (this.pitch + gyro[0] * dt) + (1 - alpha) * accelPitch);
            rollHistory.add(alpha * (this.roll + gyro[1] * dt) + (1 - alpha) * accelRoll);
            yawHistory.add(this.yaw + gyro[2] * dt); // Gyro integration for yaw

            if (pitchHistory.size() > 7) pitchHistory.remove(0);
            if (rollHistory.size() > 7) rollHistory.remove(0);
            if (yawHistory.size() > 7) yawHistory.remove(0);

            this.pitch = harmonicMean(pitchHistory);
            this.roll = harmonicMean(rollHistory);
            this.yaw = harmonicMean(yawHistory);

            // Bound yaw to -180 to 180 degrees
            if (this.yaw > 180) {
                this.yaw -= 360;
            } else if (this.yaw < -180) {
                this.yaw += 360;
            }
        }
    }

    private float harmonicMean(ArrayList<Float> values) {
        float sum = 0;
        for (float value : values) {
            sum += 1.0 / value;
        }
        return values.size() / sum;
    }
// Getter methods for pitch, roll, and yaw
    public float getPitch() {
        return pitch;
    }

    public float getRoll() {
        return roll;
    }

    public float getYaw() {
        return yaw;
    }

    void draw3DObject() {
    }

void drawAccelerationChart() {
         pushMatrix();
          translate(-width / 2 + 50, height / 2 - 250);
          noFill();
          stroke(255);
          rect(0, 0, 700, 100); 
          strokeWeight(2);
          stroke(0, 255, 0); // Green for X-axis
          beginShape();
    for (int i = 0; i < accelXHistory.size(); i++) {
      vertex(i * 7, map(accelXHistory.get(i), -2, 2, 100, 0));      // scale from -2 to 2
    }
    endShape();
    
    stroke(0, 0, 255); // Blue for Y-axis
    beginShape();
    for (int i = 0; i < accelYHistory.size(); i++) {
      vertex(i * 7, map(accelYHistory.get(i), -2, 2, 100, 0));
    }
    endShape();
    
    stroke(255, 0, 0); // Red for Z-axis
    beginShape();
    for (int i = 0; i < accelZHistory.size(); i++) {
      vertex(i * 7, map(accelZHistory.get(i), -2, 2, 100, 0));
    }
    endShape();
    
    popMatrix();
    }
// voltage chart
void drawVoltageChart() {
         pushMatrix();
          translate(-width / 2 + 50, height / 2 - 370);
          noFill();
          stroke(255);
          rect(0, 0, 700, 100);   
          strokeWeight(2);
          stroke(0, 255, 0); // Green for 0
          beginShape();
    for (int i = 0; i < v0History.size(); i++) {
      vertex(i * 7, map(v0History.get(i), -10, 10, 100, 0));      //
    }
    endShape();
    
    stroke(0, 0, 255); // Blue for 1
    beginShape();
    for (int i = 0; i < v1History.size(); i++) {
      vertex(i * 7, map(v1History.get(i), -10, 10, 100, 0));        //
    }
    endShape();
    
        stroke(255, 0, 0); // Red for 2
    beginShape();
    for (int i = 0; i < v2History.size(); i++) {
      vertex(i * 7, map(v2History.get(i), -10, 10, 100, 0));        //
    }
    endShape();
    
    stroke(255, 255, 0); // Yello for 3
    beginShape();
    for (int i = 0; i < v3History.size(); i++) {
      vertex(i * 7, map(v3History.get(i), -10, 10, 100, 0));        //
    }
    endShape();   
    popMatrix();
}
// magnetic chart
// voltage chart
void drawMagneticChart() {
         pushMatrix();
          translate(-width / 2 + 50, height / 2 - 130);
          noFill();
          stroke(255);
          rect(0, 0, 700, 100);   
          strokeWeight(2);
          stroke(0, 255, 0); // Green for 0
          beginShape();
    for (int i = 0; i < mXHistory.size(); i++) {
      vertex(i * 7, map(mXHistory.get(i), -100, 100, 100, 0));      //
    }
    endShape();
    
    stroke(0, 0, 255); // Blue for 1
    beginShape();
    for (int i = 0; i < mYHistory.size(); i++) {
      vertex(i * 7, map(mYHistory.get(i), -100, 100, 100, 0));        //
    }
    endShape();
    
        stroke(255, 0, 0); // Red for 2
    beginShape();
    for (int i = 0; i <mZHistory.size(); i++) {
      vertex(i * 7, map(mZHistory.get(i), -100, 100, 100, 0));        //
    }
    endShape();
 
    popMatrix();
}
  // not active 
    private class KalmanFilter {
        private double q; // Process noise covariance
        private double r; // Measurement noise covariance
        private double x; // Value
        private double p; // Estimation error covariance
        private double k; // Kalman gain

        public KalmanFilter(double q, double r, double p) {
            this.q = q;
            this.r = r;
            this.p = p;
            this.x = 0; // Initial value
        }

        public double update(double measurement) {
            // Prediction update
            p = p + q;

            // Measurement update
            k = p / (p + r);
            x = x + k * (measurement - x);
            p = (1 - k) * p;

            return x;
        }
    }
}
