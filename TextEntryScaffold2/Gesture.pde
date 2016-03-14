import java.lang.reflect.Method;
class Gestures {
  int  maxOffset, minLength;
  String functionName;
  PVector startPos, endPos;
  PApplet pApp;
  Method[] m;
  Gestures(int minimum,int offSet,PApplet theApplet) {
    m=new Method[4];
    pApp = theApplet;
    maxOffset=offSet;    //number pixels you are allowed to travel off the axis and still being counted as a swipe
    minLength=minimum;    // number of pixels you need to move your finger to count as a swipe
  }
  // where did our motion start
  void setStartPos(PVector pos) {
    startPos=pos;
  }
  // where did it end and also call to check if it was a valid swipe
  void setEndPos(PVector pos) {
    endPos=pos;
    checkSwipe();
    endPos=new PVector();
    startPos=new PVector();
  }
  // check if it is a valid swipe that has been performed and if so perform the attached function
  void checkSwipe() {
    if (abs(startPos.x-endPos.x)>minLength&&abs(startPos.y-endPos.y)<maxOffset) {
      if (startPos.x<endPos.x) {
        performAction(2);    // a swipe right
      }
      else {
        performAction(0);    // a swipe left
      }
    }
    else {
      if (abs(startPos.y-endPos.y)>minLength&&abs(startPos.x-endPos.x)<maxOffset) {
        if (startPos.y<endPos.y) {
          performAction(3);  // a swipe downwards
        }
        else {
          performAction(1);  // a swipe upwards
        }
      }
    }
  }
  // call the function that we have defined with setAction
  void performAction(int direction) {
    if (m[direction] == null)
      return;
    try {
      m[direction].invoke(pApp);
    } 
    catch (Exception e) {
      e.printStackTrace();
    }
  }
  // define a function that should get called when the different swipes is done
  void setAction(int direction, String method) {
    if (method != null && !method.equals("")) {
      try {
        m[direction] = pApp.getClass().getMethod(method);
      } 
      catch (SecurityException e) {
        e.printStackTrace();
      } 
      catch (NoSuchMethodException e) {
        e.printStackTrace();
      }
    }
  }
  // attach a function to a left swipe
  void setSwipeLeft(String _funcName) {
    setAction(0, _funcName);
  }
  void setSwipeUp(String _funcName) {
    setAction(1, _funcName);
  }
  void setSwipeRight(String _funcName) {
    setAction(2, _funcName);
  }
  void setSwipeDown(String _funcName) {
    setAction(3, _funcName);
  }
}