import java.util.ArrayList;
import java.util.Collections;

int value = 0; // test variable
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
  size(800,800);
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
  
  //testing dragging
  fill(value);
  rect(25, 25, 50, 50);
  // end test
  
  
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
  
  fill(0, 0, 255);
  ellipse(0, 0, 20, 20);
  //line(0, 0, width/2, height/2);
  fill(0, 255, 0);
  ellipse(t.x + screenTransX, t.y + screenTransY, 10, 10);
  popMatrix();

  scaffoldControlLogic(); //you are going to want to replace this!
  
  text("Trial " + (trialIndex+1) + " of " +trialCount, width/2, inchesToPixels(.5f));
}

//my example design
void scaffoldControlLogic()
{
  //upper left corner, rotate counterclockwise
  text("CCW", inchesToPixels(.2f), inchesToPixels(.2f));
  if (mousePressed && dist(0, 0, mouseX, mouseY)<inchesToPixels(.5f))
    screenRotation--;

  //upper right corner, rotate clockwise
  text("CW", width-inchesToPixels(.2f), inchesToPixels(.2f));
  if (mousePressed && dist(width, 0, mouseX, mouseY)<inchesToPixels(.5f))
    screenRotation++;

  //lower left corner, decrease Z
  text("-", inchesToPixels(.2f), height-inchesToPixels(.2f));
  if (mousePressed && dist(0, height, mouseX, mouseY)<inchesToPixels(.5f))
    screenZ-=inchesToPixels(.02f);

  //lower right corner, increase Z
  text("+", width-inchesToPixels(.2f), height-inchesToPixels(.2f));
  if (mousePressed && dist(width, height, mouseX, mouseY)<inchesToPixels(.5f))
    screenZ+=inchesToPixels(.02f);

  //left middle, move left
  text("left", inchesToPixels(.2f), height/2);
  if (mousePressed && dist(0, height/2, mouseX, mouseY)<inchesToPixels(.5f))
    screenTransX-=inchesToPixels(.02f);

  text("right", width-inchesToPixels(.2f), height/2);
  if (mousePressed && dist(width, height/2, mouseX, mouseY)<inchesToPixels(.5f))
    screenTransX+=inchesToPixels(.02f);
  
  text("up", width/2, inchesToPixels(.2f));
  if (mousePressed && dist(width/2, 0, mouseX, mouseY)<inchesToPixels(.5f))
    screenTransY-=inchesToPixels(.02f);
  
  text("down", width/2, height-inchesToPixels(.2f));
  if (mousePressed && dist(width/2, height, mouseX, mouseY)<inchesToPixels(.5f)){
    screenTransY+=inchesToPixels(.02f);
  }
  
  text("Next", nextButtonX, nextButtonY);
  //text("Next", 3*width/4, height-inchesToPixels(.2f));
  println("3*width/4 : " + 3*width/4 + " height-inchesToPixels(.2f): " + Float.toString(height-inchesToPixels(.2f)));
  println("nextButtonX : " + nextButtonX + " nextButtonY: " + nextButtonY);
  
    
  
}

void mouseDragged()
{
  value = value + 5;
  if (value > 255) {
    value = 0;
  }
  
  Target t = targets.get(trialIndex);
  fill(0, 255, 0);
  if (dist(width/2 + t.x + screenTransX, height/2 + t.y + screenTransY, mouseX, mouseY)<inchesToPixels(.5f)){
    ellipse(width/2, height/2, 20,20);
    // adjust change in X and Y to drag red target square
    //screenTransX = mouseX - t.x - width/2;
    //screenTransY = mouseY - t.y - height/2;
    println("MouseX : " + mouseX + " MouseY: " + mouseY);
    println("Width/2 : " + width/2 + " height/2: " + height/2);
    
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
    if (dist(width/2 + t.x + screenTransX, height/2 + t.y + screenTransY, mouseX, mouseY)<inchesToPixels(.5f)){
      draggingSquare = true;
  } 
    
    
}


void mouseReleased()
{
  
  if (draggingSquare){
    draggingSquare = false;
    Target t = targets.get(trialIndex);
    screenTransX = mouseX - t.x - width/2;
    screenTransY = mouseY - t.y - height/2;
  }
  //check to see if user clicked middle of screen
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


public boolean checkForSuccess()
{
	Target t = targets.get(trialIndex);	
	boolean closeDist = dist(t.x,t.y,-screenTransX,-screenTransY)<inchesToPixels(.05f); //has to be within .1"
  boolean closeRotation = calculateDifferenceBetweenAngles(t.rotation,screenRotation)<=5;
	boolean closeZ = abs(t.z - screenZ)<inchesToPixels(.05f); //has to be within .1"	
	
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