
String[] labels = {"Brick Braker Game", "Pong game", "Reader", "Catcher"};
int selected = 0;

final int w1 = 0;
final int w2 = 1;
final int w3 = 2;
final int w4 = 3;
final int w5 = 4;

int activeWindow = 0;
int prevMove = 0;

// catch game window + exit-by-FSR-hold (no keyboard needed)
int mx = 450, my = 250, mw = 600, mh = 400;
boolean fsrLock = false;
int fsrHeld = 0;
int lastDirSent = 0;
int lastCtl = 0;
final int EXIT_HOLD_MS = 1500;


void setup() {
  size(1500, 850);
  setupSerial();
  
}

void draw() {
  if(activeWindow == 0){
    background(255);
    
    fill(0);
    textAlign(LEFT, TOP);
    textSize(32);
    text("HOMEPAGE", 120, 30);
    stroke(0);
    strokeWeight(2);
    line(40, 70, 210, 70);
    
    textAlign(CENTER, CENTER);
    textSize(24);
    int boxW = 300;
    int boxH = 250;
    int startX = 50;
    int startY = 160;
    int gapX = 350;
    int gapY = 300;
    
    for (int i = 0; i < labels.length; i++) {
      int col = i % 4;
      int row = i / 4;
      
      int x = startX + col * gapX;
      int y = startY + row * gapY;
      
      if (i == selected) {
        strokeWeight(6);
      } else {
        strokeWeight(2);
      }
      
      fill(255);
      rect(x, y, boxW, boxH, 10);
      fill(0);
      text(labels[i], x + boxW / 2, y + boxH / 2);
    }
    
    // --------------------------------------------------------------------------------------------
    
    if (!calibrated) {
      text("Hold head still... " + sampleCount + "/" + TOTAL_SAMPLES, width / 2, height / 15);
    } else {
      text("Direction Code: " + currentDirection, width / 2, height / 15 - 20);
      textSize(16);
      fill(180);
      text("diffY: " + nf(diffY, 0, 0) + "  |  diffZ: " + nf(diffZ, 0, 0), width / 2, height / 15 + 10);
      text("Press 'C' to recalibrate baseline", width / 2, height - 30);
      textSize(28);
    }
    
    if(millis() - prevMove > 1000){
      
      if (currentDirection == RIGHT) {
        selected = (selected + 1) % labels.length;
        prevMove = millis();
      } else if (currentDirection == LEFT) {
        selected = (selected - 1 + labels.length) % labels.length;
        prevMove = millis();
      }
    }
    
    //println("home: fsr: " + fsr);
    if(fsr <= 150) fsrLock = false;
    if(fsr > 150 && !fsrLock){
      activeWindow = selected+1;
      fsrLock = true;
      fsrHeld = 0;
      if(activeWindow == 1) setupBB();
      if(activeWindow == 2) setupPong();
      if(activeWindow == 3) setupReader();
      if(activeWindow == 4) catchStart();
    }
    
  }else if(activeWindow == 1){ // Brick Braker Game
  
    background(255);
    drawBB();
    backToHome();
    
  }else if(activeWindow == 2){ // Pong game
    
    background(255);
    drawPong();
    backToHome();
    
  }else if(activeWindow == 3){ // Reader
    
    background(255);
    drawReader();
    //backToHome();
    
  }else if(activeWindow == 4){ // Catcher
    
    background(255);
    
    fill(0);
    textAlign(LEFT, TOP);
    textSize(32);
    text("Catch", 120, 30);
    stroke(0);
    strokeWeight(2);
    line(40, 70, 210, 70);

    catchControls();
    fill(255);
    stroke(0);
    strokeWeight(2);
    rect(mx, my, mw, mh);
    pushMatrix();
    translate(mx, my);
    textAlign(LEFT, BASELINE);
    catchDraw();
    popMatrix();
    textAlign(CENTER, CENTER);
    textSize(16);
    fill(180);
    text("Tilt left / right to move  |  hold squeeze to exit", width / 2, my + mh + 30);background(255);
    
    fill(0);
    textAlign(LEFT, TOP);
    textSize(32);
    text("Paint", 120, 30);
    stroke(0);
    strokeWeight(2);
    line(40, 70, 210, 70);
    
  }
}

// temporary keyboard controls
void keyPressed() {
  if(activeWindow == 0){
    if (keyCode == RIGHT) {
      selected = (selected + 1) % labels.length;
    } else if (keyCode == LEFT) {
      selected = (selected - 1 + labels.length) % labels.length;
    }
  }else{
    if (key == 'h' || key == 'H') {
      activeWindow = 0;
    }
  }
  
  if (key == 'c' || key == 'C') {
    calibrated = false;
    sampleCount = 0;
    sumY = 0;
    sumZ = 0;
    currentDirection = NEUTRAL;
  }
}

void backToHome(){
  if(spectra > baseSpectra + 20 || spectra < baseSpectra - 20){
    activeWindow = 0;
  }
}

/**/
// head direction -> catch moves; hold FSR to go home
void catchControls() {
  if (fsr <= 200) { fsrLock = false; fsrHeld = 0; }
  else if (!fsrLock) {
    if (fsrHeld == 0) fsrHeld = millis();
    if (millis() - fsrHeld > EXIT_HOLD_MS) { activeWindow = 0; fsrLock = true; fsrHeld = 0; return; }
  }
  if (!calibrated) return;
  char k = 0;
  if (currentDirection == RIGHT) k = 'd';
  else if (currentDirection == LEFT) k = 'a';
  else if (currentDirection == UP || currentDirection == DOWN) k = 'x'; // restart only
  if (k == 0) { lastDirSent = NEUTRAL; return; }
  if (currentDirection != lastDirSent || millis() - lastCtl > 180) {
    lastDirSent = currentDirection;
    lastCtl = millis();
    catchKey(k);
  }
}
