import java.util.ArrayList;
import java.util.Collections;

boolean draggingSquare = false;
boolean draggingSlider = false; 

// nextButton variables are redfined in setup()
float nextButtonX = 0;
float nextButtonY = 0;

int index = 0;

float maxZ = 216f;
float screenTransX = 0; // change in X
float screenTransY = 0; // change in Y

float screenTransX2 = 0;
float screenTransY2 = 0;

float screenRotation = 0; // change in rotation
//float targettingZStart = 50f; // starting size of targetting square
float targettingZStart = maxZ; // starting size of targetting square
float screenZ = 0; //change in size

//int trialCount = 8; //this will be set higher for the bakeoff
int trialCount = 50; //this will be set higher for the bakeoff
float border = 0; //have some padding from the sides
int trialIndex = 0; //what trial are we on
int errorCount = 0;  //used to keep track of errors
float errorPenalty = 0.5f; //for every error, add this to mean time
int startTime = 0; // time starts when the first click is captured
int finishTime = 0; //records the time of the final click
boolean userDone = false;

float ball_x = 0;
float ball_y = 0;
float ball_size = 18;

float final_ball_x = 0;
float final_ball_y = 0; 
int final_size = 18;
float start_grid_y;
float start_grid_x;
float grid_height;
float grid_width;

final int screenPPI = 72; //what is the DPI of the screen you are using 

private class Target
{
  float x = 0;
  float y = 0;
  float rotation = 0;
  float z = 0;
}

ArrayList<Target> targets = new ArrayList<Target>();

float inchesToPixels(float inch)
{
  return inch*screenPPI;
}

void setup() {
  size(700, 700);
  noStroke();
  
  start_grid_y = height - 50;
  start_grid_x = 50;
  grid_height = maxZ;
  grid_width = 90;

  //starting coords of target slider 
  //ball_x = 430; 
  ball_x = start_grid_x;
  //ball_y = 160;
  ball_y = start_grid_y;
  
  nextButtonX = 3*width/4;
  nextButtonY = height-inchesToPixels(.2f);

  rectMode(CENTER);
  textFont(createFont("Arial", inchesToPixels(.2f))); //sets the font to Arial that is .3" tall
  textAlign(CENTER);
  ellipseMode(CENTER);

  //don't change this! 
  border = inchesToPixels(.2f); //padding of 0.2 inches

  for (int i=0; i<trialCount; i++) //don't change this! 
  {
    Target t = new Target();
    t.x = random(-width/2+border, width/2-border); //set a random x with some padding
    t.y = random(-height/2+border, height/2-border); //set a random y with some padding
    t.rotation = random(0, 360); //random rotation between 0 and 360
    int j = (int)random(20);
    t.z = ((j%20)+1)*inchesToPixels(.15f); //increasing size from .15 up to 3.0" 
    targets.add(t);
    println("created target with " + t.x + "," + t.y + "," + t.rotation + "," + t.z);
  }

  Collections.shuffle(targets); // randomize the order of the button; don't change this.
}

void draw() {
  
  background(128);
  
  // y-axis 
  stroke(255);
  line(start_grid_x, start_grid_y, start_grid_x, start_grid_y - grid_height);

  // x-axis 
  stroke(255);
  line(start_grid_x, start_grid_y, start_grid_x + grid_width, start_grid_y);

  noStroke();

  fill(0,255,0);
  ellipse(ball_x,ball_y,ball_size,ball_size);




if (userDone)
  {
    text("User completed " + trialCount + " trials", width/2, inchesToPixels(.2f));
    text("User had " + errorCount + " error(s)", width/2, inchesToPixels(.2f)*2);
    text("User took " + (finishTime-startTime)/1000f/trialCount + " sec per target", width/2, inchesToPixels(.2f)*3);
    text("User took " + ((finishTime-startTime)/1000f/trialCount+(errorCount*errorPenalty)) + " sec per target inc. penalty", width/2, inchesToPixels(.2f)*4);
    return;
  }

  //===========DRAW TARGET SQUARE (red)=================
  pushMatrix();
  translate(width/2, height/2); //center the drawing coordinates to the center of the screen

  Target t = targets.get(trialIndex);
  
  translate(t.x, t.y); //center the drawing coordinates to the center of the screen
  translate(screenTransX, screenTransY); //center the drawing coordinates to the center of the screen

  // rotation for target square
  rotate(radians(t.rotation));
  rotate(radians(screenRotation));

  fill(255, 0, 0); //set color to semi translucent
  float sizeMode = (t.z + screenZ) % maxZ;
  rect(0, 0, sizeMode, sizeMode);

  popMatrix();

  //===========DRAW TARGETTING SQUARE (gray) =================
  pushMatrix();
  translate(width/2, height/2); //center the drawing coordinates to the center of the screen
  rotate(radians(0)); // targetting square has 0 degree rotation and cannot change
  //custom shifts:
  //translate(screenTransX,screenTransY); //center the drawing coordinates to the center of the screen
  fill(255, 128); //set color to semi translucent
  rect(0, 0, targettingZStart, targettingZStart); //set size of targetting square (doesn't change)
  
  // draw blue ellipse for targetting square
  fill(0, 0, 255);
  ellipse(0, 0, 20, 20);
  // draw green ellipse for target square
  fill(0, 255, 0);
  ellipse(t.x + screenTransX, t.y + screenTransY, inchesToPixels(.05f)*2, inchesToPixels(.05f)*2);
  popMatrix();


  // target ellipse slider 


  // $$$ - commented out below
  //screenZ = ((160 - ball_y)*(1.44)) % maxZ;

  // 430 is starting x spot of 
  // final_ball_x = 430 + (90 - (t.rotation % 90) * (1.6666666666666667));
  //final_ball_x = 430 + ((360 - t.rotation)  * (.4166666666666667));
  float needed_rotation =  (90 - t.rotation % 90)
  final_ball_x = start_grid_x + needed_rotation;

  //final_ball_y = 160 - int(posValue);
  float needed_z = targettingZStart - t.z;
  final_ball_y = start_grid_y - (needed_z);

  fill(150, 255, 255);
  ellipse(final_ball_x, final_ball_y, final_size, final_size);


  stroke(255);
  line(430,final_ball_y,580,final_ball_y);


  stroke(255);
  line(final_ball_x,10,final_ball_x,160);

  noStroke();

  // finish target ellipse slider 

  scaffoldControlLogic(); //you are going to want to replace this!
  
  text("Trial " + (trialIndex+1) + " of " +trialCount, width/2, height - inchesToPixels(.5f));
  
  if(checkDistance()){
    fill(0, 255, 0);
  }else{
    fill(255, 0, 0);
  }
  text("X/Y Positioning: " + checkDistance() , 150, inchesToPixels(7.75f));
  
  
  if(checkRotation()){
    fill(0, 255, 0);
  }else{
    fill(255, 0, 0);
  }

  text("Rotation: " + checkRotation() , 150 + inchesToPixels(.2f), inchesToPixels(7.5f));
  
  if(checkZ()){
    fill(0, 255, 0);
  }else{
    fill(255, 0, 0);
  }
  text("Size: " + checkZ() , 150 + inchesToPixels(.2f), inchesToPixels(8f));
  
  
}

//my example design
void scaffoldControlLogic()
{

  text("Next", nextButtonX, nextButtonY);
  
}

void mouseDragged()
{
  
  Target t = targets.get(trialIndex);
  
  // if dragging square in motion, adjust target square to follow mouse #dragging
  if (draggingSquare){
    screenTransX = mouseX - t.x - width/2;
    screenTransY = mouseY - t.y - height/2;
  }

  if (draggingSlider){
    ball_x = mouseX;
    ball_y = mouseY;

    //rotates the target square accoringly
    // $$$
    screenRotation = (start_grid_x - ball_x);
    
    
    //adjusts the size accordingly
    // $$$
    screenZ = ((start_grid_y - ball_y));
    
    println("********************* " + screenZ);

  
  }
  
  
}

void mousePressed()
{
    if (startTime == 0) //start time on the instant of the first user click
    {
      startTime = millis();
      println("time started!");
    }
    
    
    Target t = targets.get(trialIndex);
    // check if mouse is near center of target square #dragging
    if (dist(width/2 + t.x + screenTransX, height/2 + t.y + screenTransY, mouseX, mouseY)<inchesToPixels(1f)){
      draggingSquare = true;
    } 

    

    print("rotation ,");
    print(t.rotation);
    println("");

    println("mod 2");
    println((90 - (t.rotation % 90)));
    println("final ball val");
    // println(430 + (90 - (t.rotation % 90) * (.4166666666666667));

    if (mouseX >= ball_x - ball_size / 2 && mouseX <= ball_x + ball_size / 2 && (mouseY >= ball_y - ball_size / 2 && mouseY <= ball_y + ball_size / 2))
    {
      draggingSlider = true;
      print(90 - (t.rotation % 90));
    }
}


void mouseReleased()
{
  // move square once done dragging #dragging
  if (draggingSquare){
    draggingSquare = false;
    Target t = targets.get(trialIndex);
    screenTransX = mouseX - t.x - width/2;
    screenTransY = mouseY - t.y - height/2;
  }

  if (draggingSlider){
    draggingSlider = false;
    ball_x = mouseX;
    ball_y = mouseY;
    
  }
  
  //check to see if user clicked near Next Button (if so then advance to next random square)
  if (dist(nextButtonX, nextButtonY, mouseX, mouseY)<inchesToPixels(.5f))
  {
    if (userDone==false && !checkForSuccess())
      errorCount++;

    //and move on to next trial
    trialIndex++;
    ball_x = start_grid_x;
    ball_y = start_grid_y;


    // hs1.reset();
    // hs2.reset();


    if (trialIndex==trialCount && userDone==false)
    {
      userDone = true;
      finishTime = millis();
    }
  }
  
  
}

public boolean checkDistance()
{
  Target t = targets.get(trialIndex);  
  boolean closeDist = dist(t.x,t.y,-screenTransX,-screenTransY)<inchesToPixels(.1f); //has to be within .1"
  return closeDist;
}

public boolean checkRotation()
{
  Target t = targets.get(trialIndex);  
  //boolean closeRotation = calculateDifferenceBetweenAngles(t.rotation,screenRotation)<=5;
  // TODO: check if it is alright to slightly change this code to check angle (bcz of screenRotation use for red instead of gray rect)
  boolean closeRotation = calculateDifferenceBetweenAngles(t.rotation + screenRotation, 0)<=5;
  return closeRotation;
}

public boolean checkZ()
{
  Target t = targets.get(trialIndex);  
  //boolean closeZ = abs(t.z - screenZ)<inchesToPixels(.05f);
  boolean closeZ = abs((t.z + screenZ) - targettingZStart)<inchesToPixels(.05f);
  return closeZ;
}

public boolean checkForSuccess()
{
  Target t = targets.get(trialIndex);  
  //boolean closeDist = dist(t.x,t.y,-screenTransX,-screenTransY)<inchesToPixels(.05f); //has to be within .1"
  //boolean closeRotation = calculateDifferenceBetweenAngles(t.rotation,screenRotation)<=5;
  //boolean closeZ = abs(t.z - screenZ)<inchesToPixels(.05f); //has to be within .1"  

  boolean closeDist = checkDistance();
  boolean closeRotation = checkRotation();
  boolean closeZ = checkZ();
  
  println("Close Enough Distance: " + closeDist);
  println("Close Enough Rotation: " + closeRotation + "(dist="+calculateDifferenceBetweenAngles(t.rotation,screenRotation)+")");
  println("Close Enough Z: " + closeZ);
  
  return closeDist && closeRotation && closeZ;  
}


double calculateDifferenceBetweenAngles(float a1, float a2)
  {
     double diff=abs(a1-a2);
      diff%=90;
      if (diff>45)
        return 90-diff;
      else
        return diff;
 }
 
 