import java.util.Arrays;
import java.util.Collections;
import android.view.inputmethod.InputMethodManager;
import android.content.Context;
import android.view.MotionEvent;

String[] phrases; //contains all of the phrases
int totalTrialNum = 4; //the total number of phrases to be tested - set this low for testing. Might be ~10 for the real bakeoff!
int currTrialNum = 0; // the current trial number (indexes into trials array above)
float startTime = 0; // time starts when the first letter is entered
float finishTime = 0; // records the time of when the final trial ends
float lastTime = 0; //the timestamp of when the last trial was completed
float lettersEnteredTotal = 0; //a running total of the number of letters the user has entered (need this for final WPM computation)
float lettersExpectedTotal = 0; //a running total of the number of letters expected (correct phrases)
float errorsTotal = 0; //a running total of the number of errors (when hitting next)
String currentPhrase = ""; //the current target phrase
String currentTyped = ""; //what the user has typed so far
//final int DPIofYourDeviceScreen = 441; //you will need to look up the DPI or PPI of your device to make sure you get the right scale!!
//http://en.wikipedia.org/wiki/List_of_displays_by_pixel_density
final int DPIofYourDeviceScreen = 320;       //Nexus 4 android  (resolution is 1280 x 768)      
final float sizeOfInputArea = DPIofYourDeviceScreen*1; //aka, 1.0 inches square!

//Variables for my silly implementation. You can delete this:
char currentLetter = 'a';

//Group 16 variables
/*
String[] alphabet = {"a", "b", "c", "d", "e", "f", "g", "h", "i", "j", 
  "k", "l", "m", "n", "o", "p", "q", "r", "s", "t", 
  "u", "v", "w", "x", "y", "z"};
*/
String[] alphabet = {"q", "w", "e","r","a","s","d","f","z","x","c","v","t","y","u","i","g","h","j","k","b","n","m","o","p","l"};
int [] isPressed = new int[28]; //[26]:space, [27]:delete
String[] vowel = {"e", "i", "o", "u"};
float keyWidth = sizeOfInputArea/4; //keys are square, so key width = key height
float keyHeight = keyWidth;

int startRectPosX = 225;   // input rect start  X coordinate 
int startRectPosY = 600;   // input rect start  Y coordinate
Gestures g;
int startIdx = 0;
String[] vowel = {"e", "i", "o", "u"};
//You can modify anything in here. This is just a basic implementation.
void setup()
{

  phrases = loadStrings("phrases2.txt"); //load the phrase set into memory
  Collections.shuffle(Arrays.asList(phrases)); //randomize the order of the phrases

  orientation(PORTRAIT); //can also be LANDSCAPE -- sets orientation on android device
  fullScreen();
  //size(1280, 768); //Nexus 4 android  (resolution is 1280 x 768) 
  background(0xFF9900);
  smooth();
  noStroke();
  fill(255);
  //rectMode(CENTER);
  //size(1000, 1000); //Sets the size of the app. You may want to modify this to your device. Many phones today are 1080 wide by 1920 tall.
  textFont(createFont("Arial", 20)); //set the font to arial 24
  //noStroke(); //my code doesn't use any strokes.
  g=new Gestures(50, 70, this);    // iniate the gesture object first value is minimum swipe length in pixel and second is the diagonal offset allowed
  g.setSwipeUp("swipeUp");    // attach the function called swipeUp to the gesture of swiping upwards
  g.setSwipeDown("swipeDown");    // attach the function called swipeDown to the gesture of swiping downwards
  g.setSwipeLeft("swipeLeft");  // attach the function called swipeLeft to the gesture of swiping left
  g.setSwipeRight("swipeRight");  // attach the function called swipeRight to the gesture of swiping right
}
// android touch event.

public boolean surfaceTouchEvent(MotionEvent event) {
  // check what that was  triggered  
  switch(event.getAction()) {
  case MotionEvent.ACTION_DOWN:    // ACTION_DOWN means we put our finger down on the screen 
    g.setStartPos(new PVector(event.getX(), event.getY()));    // set our start position
    break;
  case MotionEvent.ACTION_UP:    // ACTION_UP means we pulled our finger away from the screen  
    g.setEndPos(new PVector(event.getX(), event.getY()));    // set our end position of the gesture and calculate if it was a valid one
    break;
  }
  return super.surfaceTouchEvent(event);
}

int swipeRight = 0;
void swipeUp() {
if (currentTyped.length()!=0)
      currentTyped=removeLastChar(currentTyped);
    isPressed[27] = 1;
 currentTyped+=" "; // debug 
    isPressed[26] = 1;
}
void swipeDown() {
if (currentTyped.length()!=0)
      currentTyped=removeLastChar(currentTyped);
    isPressed[27] = 1;
 if (currentTyped.length()!=0)
      currentTyped=removeLastChar(currentTyped);
    isPressed[27] = 1;
}
void swipeLeft() {

  if(startIdx>0){
    if (currentTyped.length()!=0)
      currentTyped=removeLastChar(currentTyped);
    isPressed[27] = 1;
  startIdx -=11 ;
  }
}

void swipeRight() {

  if (startIdx <23){
    if (currentTyped.length()!=0)
      currentTyped=removeLastChar(currentTyped);
    isPressed[27] = 1;
   startIdx +=11;
  }
}


//You can modify anything in here. This is just a basic implementation.
void draw()
{
  background(0);  //clear background

  //  fill(0);
  rect(startRectPosX, startRectPosY, sizeOfInputArea, sizeOfInputArea); //input area should be 2" by 2"

  if (finishTime!=0)
  {
    fill(255);
    textAlign(CENTER);
    text("Finished", 280, 150);
    return;
  }

  if (startTime==0 & !mousePressed)
  {
    fill(255);
    textAlign(CENTER);
    text("Click to start time!", 280, 150); //display this messsage until the user clicks!
  }

  if (startTime==0 & mousePressed)
  {
    nextTrial(); //start the trials!
  }

  if (startTime!=0)
  {
    //you will need something like the next 10 lines in your code. Output does not have to be within the 2 inch area!
    textAlign(LEFT); //align the text left
    fill(128);
    text("Phrase " + (currTrialNum+1) + " of " + totalTrialNum, 70, 50); //draw the trial count
    fill(255);
    text("Target:   " + currentPhrase, 70, 100); //draw the target string
    text("Entered:  " + currentTyped, 70, 140); //draw what the user has entered thus far 
    fill(255, 0, 0);
    
    rect(450, 400, 200, 200); //drag next button
    fill(255);
    text("NEXT > ", 450, 250); //draw next label
 
    
    //my draw code
    //textAlign(CENTER);
    //text("" + currentLetter, 200+sizeOfInputArea/2, 200+sizeOfInputArea/3); //draw current letter
    //fill(255, 0, 0);
    //rect(200, 200+sizeOfInputArea/2, sizeOfInputArea/2, sizeOfInputArea/2); //draw left red button
    //fill(0, 255, 0);
    //rect(200+sizeOfInputArea/2, 200+sizeOfInputArea/2, sizeOfInputArea/2, sizeOfInputArea/2); //draw right green button
    if(swipeRight==0){
      drawKeyboard();
    }
    
     
  }
}

boolean didMouseClick(float x, float y, float w, float h) //simple function to do hit testing
{
  return (mouseX > x && mouseX<x+w && mouseY>y && mouseY<y+h); //check to see if it is in button bounds
}

/* Draws the keyboard */


void drawKeyboard()
{
  text(startIdx, 200,300);
  float textRefX = startRectPosX + keyWidth/2;
  float textRefY = startRectPosY + keyHeight/2;
  //Note: the 1-by-1 input area starts at (200, 200)
  //for (int i = 0; i < alphabet.length; i++) {
  for (int i =startIdx; i<alphabet.length; i++) {
    int row = (i-startIdx)/4; //which row the key is: 0, 1, 2....
    int col = (i-startIdx)%4; //which column the key is: 0, 1, 2, 3
<<<<<<< HEAD
   // float textRefX = startRectPosX + keyWidth/2;
    //float textRefY = startRectPosY + keyHeight/2;

=======
    
>>>>>>> 698e93cac2f231b43c8564de6ef376f20418e840
    //draw key
    if (isPressed[i] == 1) {
      fill(0, 255, 0);
      isPressed[i] = 0;
    } else {
      fill(255); //white button
    }
    stroke(180); //gray border for button
    rect(startRectPosX + col*keyWidth, startRectPosY + row*keyHeight, keyWidth, keyHeight);

    //draw key letter
    textSize(30);
    fill(0, 0, 0); //text color
    textAlign(CENTER);
    //text("" + alphabet[i], 200 + col*keyWidth + keyWidth/2, 200 + row*keyHeight + keyHeight/2); //draw key letter
    text(alphabet[i], textRefX+col*keyWidth, textRefY+row*keyHeight);

    if (i>11+startIdx){
      break;
    }
  }

<<<<<<< HEAD
  //vowel keys
  for (int i=0; i<4; i++) {
    fill(255);
    stroke(180); //gray border for button
    rect(startRectPosX + i*keyWidth, startRectPosY + 3*keyHeight, keyWidth, keyHeight);
    textSize(30);
    fill(60, 200, 100); //text color
    textAlign(CENTER);
    text(vowel[i], textRefX + i*keyWidth, startRectPosY + 3.6*keyHeight);
  }
  
  

  //space key
=======
  ////space key
>>>>>>> 698e93cac2f231b43c8564de6ef376f20418e840
  //if (isPressed[26] == 1) {
  //  fill(0, 255, 0);
  //  isPressed[26] = 0;
  //} else {
  //  fill(255); //white button
  //}
  //stroke(180); //gray border for button
  //rect(startRectPosX, startRectPosY + 3*keyHeight, keyWidth*2, keyHeight);
<<<<<<< HEAD
  if (isPressed[26] == 1) {
    fill(0, 255, 0);
    isPressed[26] = 0;
  } else {
    fill(255); //white button
  }
  stroke(180); //gray border for button
  rect(startRectPosX, startRectPosY + 3*keyHeight, keyWidth*2, keyHeight);
=======
>>>>>>> 698e93cac2f231b43c8564de6ef376f20418e840

  //textSize(30);
  //fill(0, 0, 0); //text color
  //textAlign(CENTER);
  //text("space", startRectPosX + keyWidth, startRectPosY + 3.6*keyHeight);
<<<<<<< HEAD
  textSize(30);
  fill(0, 0, 0); //text color
  textAlign(CENTER);
  text("space", startRectPosX + keyWidth, startRectPosY + 3.6*keyHeight);

  //delete key
=======

  ////delete key
>>>>>>> 698e93cac2f231b43c8564de6ef376f20418e840
  //if (isPressed[27] == 1) {
  //  fill(0, 255, 0);
  //  isPressed[27] = 0;
  //} else {
  //  fill(180); //gray button
  //}
  //stroke(180); //gray border for button
  //rect(startRectPosX + 2*keyWidth, startRectPosY + 3*keyHeight, keyWidth*2, keyHeight);
<<<<<<< HEAD
  if (isPressed[27] == 1) {
    fill(0, 255, 0);
    isPressed[27] = 0;
  } else {
    fill(180); //gray button
  }
  stroke(180); //gray border for button
  rect(startRectPosX + 2*keyWidth, startRectPosY + 3*keyHeight, keyWidth*2, keyHeight);

  //textSize(30);
  //fill(0, 0, 0); //text color
  //textAlign(CENTER);
  //text("del", startRectPosX + keyWidth*3, startRectPosY + 3.6*keyHeight);
  textSize(30);
  fill(0, 0, 0); //text color
  textAlign(CENTER);
  text("del", startRectPosX + keyWidth*3, startRectPosY + 3.6*keyHeight);  
=======

  //textSize(30);
  //fill(0, 0, 0); //text color
  //textAlign(CENTER);
  //text("del", startRectPosX + keyWidth*3, startRectPosY + 3.6*keyHeight);
  //vowel keys
  for (int i=0; i<4; i++) {
    fill(255);
    stroke(180); //gray border for button
    rect(startRectPosX + i*keyWidth, startRectPosY + 3*keyHeight, keyWidth, keyHeight);
    textSize(30);
    fill(60, 200, 100); //text color
    textAlign(CENTER);
    text(vowel[i], textRefX + i*keyWidth, startRectPosY + 3.6*keyHeight);
  }
>>>>>>> 698e93cac2f231b43c8564de6ef376f20418e840
}

/* Helper function to find which key was pressed. Returns the letter. */
String whichKey()
{
  for (int col = 0; col < 4; col++) {
    for (int row = 0; row < 3; row++) {
      if (didMouseClick(startRectPosX + col*keyWidth, startRectPosY + row*keyHeight, keyWidth, keyHeight)) {
       //System.out.println("Key found");
        isPressed[row*4+col] = 1;
        if((row*4+col)+startIdx<26){
          return alphabet[(row*4+col)+startIdx];
        }//todo - need to return in lowercase!!
      }
    }
  }

  System.out.println("No key found");
  return "-";
}

/* Helper function for delete */
String removeLastChar(String str) {
  //if (str.length()!=0)
  return str.substring(0, str.length()-1);
  //else
  //return "";
}


void mousePressed()
{
  //if (didMouseClick(200, 200+sizeOfInputArea/2, sizeOfInputArea/2, sizeOfInputArea/2)) //check if click in left button
  //{
  //  currentLetter --;
  //  if (currentLetter<'_') //wrap around to z
  //    currentLetter = 'z';
  //}

  //if (didMouseClick(200+sizeOfInputArea/2, 200+sizeOfInputArea/2, sizeOfInputArea/2, sizeOfInputArea/2)) //check if click in right button
  //{
  //  currentLetter ++;
  //  if (currentLetter>'z') //wrap back to space (aka underscore)
  //    currentLetter = '_';
  //}

  if (didMouseClick(startRectPosX, startRectPosY, sizeOfInputArea, sizeOfInputArea-keyHeight)) //check if click occured in letter area
  {
    //System.out.println("Clicked on keyboard area!");
    currentTyped+=whichKey();

    //if (currentLetter=='_') //if underscore, consider that a space bar
    //  currentTyped+=" ";
    //else if (currentLetter=='`' & currentTyped.length()>0) //if `, treat that as a delete command
    //  currentTyped = currentTyped.substring(0, currentTyped.length()-1);
    //else if (currentLetter!='`') //if not any of the above cases, add the current letter to the typed string
    //  currentTyped+=currentLetter;
  }
  
  //Check if click occured in vowel key area 
  if (didMouseClick(startRectPosX, startRectPosY + 3*keyHeight, keyWidth*4, keyHeight))
  {
    for (int col = 0; col < 4; col++) {
        if (didMouseClick(startRectPosX + col*keyWidth, startRectPosY + 3*keyHeight, keyWidth, keyHeight)) {
          System.out.println("Vowel found");
          //isPressed[row*4+col] = 1;
          currentTyped+=vowel[col];
        }
     }
  }

  //Check if click occured in space key area 
  //if (didMouseClick(startRectPosX, startRectPosY + 3*keyHeight, keyWidth*2, keyHeight))
  //{
  //  // currentTyped += " "; 
  //  currentTyped+=" "; // debug 
  //  isPressed[26] = 1;
  //}

  //Check if click occured in delete key area 
  /*
  if (didMouseClick(startRectPosX + 2*keyWidth, startRectPosY + 3*keyHeight, keyWidth*2, keyHeight))
  {
    if (currentTyped.length()!=0)
      currentTyped=removeLastChar(currentTyped);
    isPressed[27] = 1;
  }
  */
  //You are allowed to have a next button outside the 2" area
  if (didMouseClick(450, 400, 200, 200)) //check if click is in next button
  {
    nextTrial(); //if so, advance to next trial
  }
  
}


void nextTrial()
{
  if (currTrialNum >= totalTrialNum) //check to see if experiment is done
    return; //if so, just return

  if (startTime!=0 && finishTime==0) //in the middle of trials
  {
    System.out.println("==================");
    System.out.println("Phrase " + (currTrialNum+1) + " of " + totalTrialNum); //output
    System.out.println("Target phrase: " + currentPhrase); //output
    System.out.println("Phrase length: " + currentPhrase.length()); //output
    System.out.println("User typed: " + currentTyped); //output
    System.out.println("User typed length: " + currentTyped.length()); //output
    System.out.println("Number of errors: " + computeLevenshteinDistance(currentTyped.trim(), currentPhrase.trim())); //trim whitespace and compute errors
    System.out.println("Time taken on this trial: " + (millis()-lastTime)); //output
    System.out.println("Time taken since beginning: " + (millis()-startTime)); //output
    System.out.println("==================");
    lettersExpectedTotal+=currentPhrase.length();
    lettersEnteredTotal+=currentTyped.length();
    errorsTotal+=computeLevenshteinDistance(currentTyped.trim(), currentPhrase.trim());
  }

  if (currTrialNum == totalTrialNum-1) //check to see if experiment just finished
  {
    finishTime = millis();
    System.out.println("==================");
    System.out.println("Trials complete!"); //output
    System.out.println("Total time taken: " + (finishTime - startTime)); //output
    System.out.println("Total letters entered: " + lettersEnteredTotal); //output
    System.out.println("Total letters expected: " + lettersExpectedTotal); //output
    System.out.println("Total errors entered: " + errorsTotal); //output
    System.out.println("WPM: " + (lettersEnteredTotal/5.0f)/((finishTime - startTime)/60000f)); //output
    System.out.println("==================");
    currTrialNum++; //increment by one so this mesage only appears once when all trials are done
    return;
  }

  if (startTime==0) //first trial starting now
  {
    System.out.println("Trials beginning! Starting timer..."); //output we're done
    startTime = millis(); //start the timer!
  } else
  {
    currTrialNum++; //increment trial number
  }

  lastTime = millis(); //record the time of when this trial ended
  currentTyped = ""; //clear what is currently typed preparing for next trial
  currentPhrase = phrases[currTrialNum]; // load the next phrase!
  //currentPhrase = "abc"; // uncomment this to override the test phrase (useful for debugging)
}




//=========SHOULD NOT NEED TO TOUCH THIS METHOD AT ALL!==============
int computeLevenshteinDistance(String phrase1, String phrase2) //this computers error between two strings
{
  int[][] distance = new int[phrase1.length() + 1][phrase2.length() + 1];

  for (int i = 0; i <= phrase1.length(); i++)
    distance[i][0] = i;
  for (int j = 1; j <= phrase2.length(); j++)
    distance[0][j] = j;

  for (int i = 1; i <= phrase1.length(); i++)
    for (int j = 1; j <= phrase2.length(); j++)
      distance[i][j] = min(min(distance[i - 1][j] + 1, distance[i][j - 1] + 1), distance[i - 1][j - 1] + ((phrase1.charAt(i - 1) == phrase2.charAt(j - 1)) ? 0 : 1));

  return distance[phrase1.length()][phrase2.length()];
}