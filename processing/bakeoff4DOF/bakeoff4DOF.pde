import java.util.ArrayList;
import java.util.Collections;

boolean draggingSquare = false;
// nextButton variables are redfined in setup()
float nextButtonX = 0;
float nextButtonY = 0;

int index = 0;

float maxZ = 216f;
float screenTransX = 0; // change in X
float screenTransY = 0; // change in Y
float screenRotation = 0; // change in rotation
//float targettingZStart = 50f; // starting size of targetting square
float targettingZStart = maxZ; // starting size of targetting square
float screenZ = 0; //change in size

int trialCount = 8; //this will be set higher for the bakeoff
float border = 0; //have some padding from the sides
int trialIndex = 0; //what trial are we on
int errorCount = 0;  //used to keep track of errors
float errorPenalty = 0.5f; //for every error, add this to mean time
int startTime = 0; // time starts when the first click is captured
int finishTime = 0; //records the time of the final click
boolean userDone = false;

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

  size(600,600);
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

  background(60); //background is dark grey
  fill(200);
  noStroke();
  
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
  rect(0, 0, t.z + screenZ, t.z + screenZ);

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

  scaffoldControlLogic(); //you are going to want to replace this!
  
  text("Trial " + (trialIndex+1) + " of " +trialCount, width/2, height - inchesToPixels(.5f));
  
  if(checkDistance()){
    fill(0, 255, 0);
  }else{
    fill(255, 0, 0);
  }
  text("X/Y Positioning: " + checkDistance() , width/2, inchesToPixels(.5f));
  
  
  if(checkRotation()){
    fill(0, 255, 0);
  }else{
    fill(255, 0, 0);
  }
  text("Rotation: " + checkRotation() , 150 + inchesToPixels(.2f), inchesToPixels(.4f));
  
  if(checkZ()){
    fill(0, 255, 0);
  }else{
    fill(255, 0, 0);
  }
  text("Size: " + checkZ() , 150 + inchesToPixels(.2f), inchesToPixels(1f));
  
  
}

//my example design
void scaffoldControlLogic()
{
  //upper left corner, rotate counterclockwise
  float CCWX = 10 + inchesToPixels(.2f);
  float CCWY = inchesToPixels(.4f);
  float CCWRegion = inchesToPixels(.25f); 
  fill(0, 0, 0);
  ellipse(CCWX, CCWY, CCWRegion*2, CCWRegion*2);
  fill(0, 255, 0);
  text("CCW", CCWX, CCWY);
  if (mousePressed && dist(CCWX, CCWY, mouseX, mouseY)<CCWRegion)
    screenRotation--;

  //upper right corner, rotate clockwise
  float CWX = 60 + inchesToPixels(.2f);
  float CWY = inchesToPixels(.4f);
  float CWRegion = inchesToPixels(.25f); 
  fill(0, 0, 0);
  ellipse(CWX, CWY, CWRegion*2, CWRegion*2);
  fill(0, 255, 0);
  text("CW", CWX, CWY);
  if (mousePressed && dist(CWX, CWY, mouseX, mouseY)<CWRegion)
    screenRotation++;

  //lower left corner, decrease Z
  float minusX = 10 + inchesToPixels(.2f);
  float minusY = inchesToPixels(1f);
  float minusRegion = inchesToPixels(.25f); 
  fill(0, 0, 0);
  ellipse(minusX, minusY, minusRegion*2, minusRegion*2);
  fill(0, 255, 0);
  text("-", minusX, minusY);
  if (mousePressed && dist(minusX, minusY, mouseX, mouseY)<minusRegion)
    screenZ-=inchesToPixels(.02f);

  //lower right corner, increase Z
  float plusX =  60 + inchesToPixels(.2f);
  float plusY = inchesToPixels(1f);
  float plusRegion = inchesToPixels(.25f); 
  fill(0, 0, 0);
  ellipse(plusX, plusY, plusRegion*2, plusRegion*2);
  fill(0, 255, 0);
  text("+", plusX, plusY);
  if (mousePressed && dist(plusX, plusY, mouseX, mouseY)<plusRegion)
    screenZ+=inchesToPixels(.02f);

  //left middle, move left
  float leftX = width-6*inchesToPixels(.2f);
  float leftY = inchesToPixels(0.75f);
  float leftRegion = inchesToPixels(.25f); 
  fill(0, 0, 0);
  ellipse(leftX, leftY, leftRegion*2, leftRegion*2);
  fill(0, 255, 0);
  text("left", leftX, leftY);
  if (mousePressed && dist(leftX, leftY, mouseX, mouseY)<leftRegion)
    screenTransX-=inchesToPixels(.02f);

  float rightX = width-inchesToPixels(.2f);
  float rightY = inchesToPixels(0.75f);
  float rightRegion = inchesToPixels(.25f); 
  fill(0, 0, 0);
  ellipse(rightX, rightY, rightRegion*2, rightRegion*2);
  fill(0, 255, 0);
  text("right", rightX, rightY);
  if (mousePressed && dist(rightX, rightY, mouseX, mouseY)<rightRegion)
    screenTransX+=inchesToPixels(.02f);
  
  float upX = width-3.5*inchesToPixels(.2f);
  float upY = inchesToPixels(.2f);
  float upRegion = inchesToPixels(.25f); 
  fill(0, 0, 0);
  ellipse(upX, upY, upRegion*2, upRegion*2);
  fill(0, 255, 0);
  text("up", upX, upY);
  if (mousePressed && dist(upX, upY, mouseX, mouseY)<upRegion)
    screenTransY-=inchesToPixels(.02f);
  
  float downX = width-3.5*inchesToPixels(.2f);
  float downY = inchesToPixels(1.2f);
  float downRegion = inchesToPixels(.25f); 
  fill(0, 0, 0);
  ellipse(downX,downY, downRegion*2, downRegion*2);
  fill(0, 255, 0);
  text("down", downX, downY);
  if (mousePressed && dist(downX, downY, mouseX, mouseY)<downRegion){
    screenTransY+=inchesToPixels(.02f);
  }
  
  text("Next", nextButtonX, nextButtonY);
  
}

void mouseDragged()
{
  
  Target t = targets.get(trialIndex);
  
  // if dragging square in motion, adjust target square to follow mouse #dragging
  if (draggingSquare){
    // screenTransX = mouseX - t.x - width/2;
    // screenTransY = mouseY - t.y - height/2;

    screenTransX = mouseX - t.x - width;
    screenTransY = mouseY - t.y - height;
  }
  
  
}

void mousePressed()
{
    if (startTime == 0) //start time on the instant of the first user click
    {
      startTime = millis();
      println("time started!");
    }
    
    println("MOUSE PRESSED!!!!! : ");
    
    Target t = targets.get(trialIndex);
    // check if mouse is near center of target square #dragging
    if (dist(width/2 + t.x + screenTransX, height/2 + t.y + screenTransY, mouseX, mouseY)<inchesToPixels(1f)){
      draggingSquare = true;
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
  
  //check to see if user clicked near Next Button (if so then advance to next random square)
  if (dist(nextButtonX, nextButtonY, mouseX, mouseY)<inchesToPixels(.5f))
  {
    if (userDone==false && !checkForSuccess())
      errorCount++;

    //and move on to next trial
    trialIndex++;

    screenTransX = 0;
    screenTransY = 0;

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
  boolean closeDist = dist(t.x,t.y,-screenTransX,-screenTransY)<inchesToPixels(.05f); //has to be within .1"
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