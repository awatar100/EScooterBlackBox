// User interface window called UIWindow
import controlP5.*;

class UIWindow extends PApplet {
  ControlP5 cp5;
  boolean showPopup = false;
  PApplet parent;
  Textarea maxAccelTextarea;
  Textarea minAccelTextarea;
   Textarea helpTextArea;
  
  UIWindow(PApplet parent) {
    this.parent = parent;
    PApplet.runSketch(new String[]{this.getClass().getSimpleName()}, this);
  }
  
  public void settings() {
    size(600, 400);
  }
  
  public void setup() {
    cp5 = new ControlP5(this);
    surface.setTitle("Control"); // Name of window
    // Create a button to open the file chooser
    cp5.addButton("chooseFile")
       .setPosition(10, 10)
       .setSize(100, 40)
       .setLabel("Choose Data File")
       .onClick(new CallbackListener() {
         public void controlEvent(CallbackEvent event) {
           parent.selectInput("Select a TXT file:", "fileSelected");
         }
       });
    // Create play/pause buttons
    cp5.addButton("play")
       .setPosition(120, 10)
       .setSize(50, 40)
       .setLabel("Play")
       .onClick(new CallbackListener() {
         public void controlEvent(CallbackEvent event) {
           ((MainSketch) parent).isPlaying = true;
         }
       });
    cp5.addButton("pause")
       .setPosition(180, 10)
       .setSize(50, 40)
       .setLabel("Pause")
       .onClick(new CallbackListener() {
         public void controlEvent(CallbackEvent event) {
           ((MainSketch) parent).isPlaying = false;
         }
       });
       
     // Create a_clear_button
    cp5.addButton("whipe")
       .setPosition(240, 10)
       .setSize(50, 40)
       .setLabel("Whipe")
       .onClick(new CallbackListener() {
         public void controlEvent(CallbackEvent event) {
           ((MainSketch) parent).resetOrientation();            // clea_r_position in 3dspace object
         }
       });   
       // Create a button to show the popup window
        cp5.addButton("helpButton")
           .setPosition(10, 310)
           .setSize(50, 40)
           .setLabel("Help")
           .onClick(new CallbackListener() {
               public void controlEvent(CallbackEvent event) {
                   showPopup = true;
               }
           });
             
// Create a slider to navigate through the CSV file
cp5.addSlider("lineSlider")
   .setPosition(300, 10)
   .setSize(200, 40)
   .setRange(0, 100)  // This will be updated once the CSV is loaded
   .setValue(0)
   .onChange(new CallbackListener() {
     public void controlEvent(CallbackEvent event) {
       if (!((MainSketch) parent).isPlaying) {
         ((MainSketch) parent).currentLine = (int) event.getController().getValue();
       }
     }
   });
    // Create text areas for displaying top 10 acceleration events
    maxAccelTextarea = cp5.addTextarea("maxAccel")
                          .setPosition(10, 60)
                          .setSize(280, 180)
                          .setFont(createFont("arial", 12))
                          .setLineHeight(14)
                          .setColor(color(255))
                          .setColorBackground(color(0, 100))
                          .setColorForeground(color(255, 100));
    
    minAccelTextarea = cp5.addTextarea("minAccel")
                          .setPosition(310, 60)
                          .setSize(280, 180)
                          .setFont(createFont("arial", 12))
                          .setLineHeight(14)
                          .setColor(color(255))
                          .setColorBackground(color(0, 100))
                          .setColorForeground(color(255, 100));
 }
public void draw() {
    // RGB values - let this be dark gray
    background(50,50,50);
     if (showPopup) {
            // Draw the popup window
            fill(0, 0, 0, 150);
            rect(70, 250, 480, 100);

            // Draw the close button
            fill(255, 0, 0);
            rect(530, 250, 20, 20);
            fill(255);
            textAlign(CENTER, CENTER);
            text("X", 540, 258);

            // Draw the help text
            fill(255);
            textAlign(LEFT, TOP);
            text("Writen by awatar100.\nIts visualise data from CSV file from Black Box.\n More info at: https://spec-electronic.pl", 75, 260);
        }  
    cp5.getController("lineSlider").setValue(round(((MainSketch) parent).currentLine));  
}
  // Method to update the slider range
  public void updateSliderRange(int maxLines) {
    Slider lineSlider = (Slider) cp5.getController("lineSlider");
    lineSlider.setRange(0, maxLines - 1);
  }
  // Method to update the text areas with top 10 acceleration events
  public void updateAccelerationEvents(String maxEvents, String minEvents) {
    maxAccelTextarea.setText(maxEvents);
    minAccelTextarea.setText(minEvents);
  }

    public void mousePressed() {
        // Check if the close button is clicked
        if (showPopup && mouseX > 530 && mouseX < 545 && mouseY > 248 && mouseY < 269) {
            showPopup = false;
        }
    }
    
}
