// F1 PIXEL ARCADE - same games as final/, new graphics only.
// Input is the wearable's, read exactly like app/ (serial.pde + direction.pde):
//   head tilt (LEFT/RIGHT/UP/DOWN)  -> menu selection / game steering
//   FSR press (> 200)               -> open selected game (home), hold 1.5s to exit
int game = 0;
String[] names = {"Snake", "Catch", "Flappy"};
String[] tags  = {"PIT LANE RUN", "TYRE CATCH", "BARRIER DASH"};
String[] hints = {"TILT  U D L R", "TILT  L / R", "TILT  UP = FLAP"};
int[] best = new int[3];

int mx = 100, my = 100, mw = 600, mh = 400;

// same names/logic as app.pde home page
int selected = 0;
int prevMove = 0;

// extra input plumbing (no keyboard)
boolean fsrLock = false;     // FSR must be released before it counts again
int fsrHeld = 0;             // millis when in-game press began (0 = none)
int lastDirSent = 0;   // 0 = NEUTRAL
int lastCtl = 0;
final int EXIT_HOLD_MS = 1500;

void setup() {
  size(800, 600);
  noSmooth();
  initTheme();
  setupSerial();
}

// only keyboard left is app.pde's 'C' recalibrate
void keyPressed() {
  if (key == 'c' || key == 'C') {
    calibrated = false;
    sampleCount = 0;
    sumY = 0;
    sumZ = 0;
    currentDirection = NEUTRAL;
  }
}

void startGame(int g) {
  game = g;
  if (g == 1) snakeStart();
  if (g == 2) catchStart();
  if (g == 3) flappyStart();
  fsrLock = true;
  fsrHeld = 0;
}

// head direction -> the exact inputs the games already understand
void gameControls() {
  if (!calibrated) return;
  char k = 0;
  if (currentDirection == RIGHT) k = 'd';
  else if (currentDirection == LEFT) k = 'a';
  else if (currentDirection == UP) k = 'w';
  else if (currentDirection == DOWN) k = 's';
  if (k == 0) { lastDirSent = NEUTRAL; return; }

  int gap = (game == 2) ? 180 : (game == 3) ? 350 : 0;
  if (currentDirection != lastDirSent || millis() - lastCtl > gap) {
    lastDirSent = currentDirection;
    lastCtl = millis();
    if (game == 1) snakeKey(k);
    else if (game == 2) catchKey(k);
    else if (game == 3) flappyKey(k);
  }
}

void homeControls() {
  // identical to app.pde home page
  if (millis() - prevMove > 1000) {
    if (currentDirection == RIGHT) {
      selected = (selected + 1) % names.length;
      prevMove = millis();
    } else if (currentDirection == LEFT) {
      selected = (selected - 1 + names.length) % names.length;
      prevMove = millis();
    }
  }
  if (fsr <= 200) fsrLock = false;
  if (fsr > 200 && !fsrLock) startGame(selected + 1);
}

void inGameFsr() {
  if (fsr <= 200) { fsrLock = false; fsrHeld = 0; return; }
  if (fsrLock) return;
  if (fsrHeld == 0) fsrHeld = millis();
  if (millis() - fsrHeld > EXIT_HOLD_MS) {
    game = 0;
    fsrLock = true;
    fsrHeld = 0;
  }
}

void draw() {
  background(BG);
  if (game == 0) homeControls();
  else { inGameFsr(); gameControls(); }
  drawMain();

  if (game > 0) {
    noStroke();
    fill(0, 0, 0, 190);
    rect(0, 0, width, height);

    // modal frame: kerb border + header bar
    kerbFrame(mx - 8, my - 40, mw + 16, mh + 48);
    fill(PANEL);
    rect(mx - 2, my - 34, mw + 4, 28);
    fill(RED);
    rect(mx - 2, my - 34, 6, 28);
    pxText(names[game - 1].toUpperCase() + "  " + tags[game - 1], mx + 14, my - 28, 16, WHITE);
    pxTextR("HOLD SQUEEZE = PIT", mx + mw - 6, my - 28, 14, GREY);
    if (fsrHeld > 0) {
      fill(YEL);
      rect(mx - 2, my - 8, (mw + 4) * constrain((millis() - fsrHeld) / (float) EXIT_HOLD_MS, 0, 1), 4);
    }

    pushMatrix();
    translate(mx, my);
    clip(mx, my, mw, mh);
    if (game == 1) snakeDraw();
    if (game == 2) catchDraw();
    if (game == 3) flappyDraw();
    noClip();
    popMatrix();
  }
}

void drawMain() {
  // top kerb + checkered strip
  kerbH(0, 0, width, 10);
  checker(0, 570, width, 30, 10, WHITE, BLACKPX);

  // header
  pxText("F1 ARCADE", 40, 36, 44, WHITE);
  pxText("WEARABLE GAMING INTERFACE", 42, 88, 14, TEAL);
  sprite(CAR, 330, 44, 4);

  // start lights (decorative)
  int lit = (frameCount / 25) % 7;
  for (int i = 0; i < 5; i++) {
    int lx = 600 + i * 34;
    boolean on = lit > i && lit < 6;
    fill(on ? RED : #2A1216);
    rect(lx, 36, 24, 24);
    if (on) { fill(#FF6A5E); rect(lx + 4, 40, 8, 8); }
  }
  pxText("LIGHTS OUT", 600, 70, 12, GREY);

  // cards
  for (int i = 0; i < 3; i++) {
    int x = 40 + i * 250;
    int y = 140;
    int cw = 220, ch = 380;
    card(x, y, cw, ch, i);
  }
  if (!calibrated) {
    fill(0, 200);
    rect(0, 250, width, 100);
    kerbH(0, 250, width, 6);
    kerbH(0, 344, width, 6);
    pxTextC("HOLD HEAD STILL... " + sampleCount + "/" + TOTAL_SAMPLES, width / 2, 280, 28, YEL);
    pxTextC("CALIBRATING SENSOR", width / 2, 318, 14, WHITE);
  } else {
    pxText("TILT LEFT / RIGHT = SELECT   SQUEEZE = RACE   (C = RECALIBRATE)", 40, 540, 14, GREY);
    pxText("DIR " + currentDirection + "   FSR " + nf(fsr, 0, 0) + "   dY " + nf(diffY, 0, 0) + "  dZ " + nf(diffZ, 0, 0), 40, 556, 12, GREY);
  }
}

void card(int x, int y, int cw, int ch, int i) {
  noStroke();
  boolean sel = (i == selected);
  if (sel) y -= 10;
  fill(#05070C);
  rect(x + 6, y + 6, cw, ch);              // drop shadow
  if (sel) { fill(TEAL); rect(x - 4, y - 4, cw + 8, ch + 8); }
  fill(PANEL);
  rect(x, y, cw, ch);
  fill(PANEL2);
  rect(x + 8, y + 8, cw - 16, 150);         // preview window
  drawIcon(i, x + 8, y + 8, cw - 16, 150);

  // grid position badge
  fill(RED);
  rect(x, y, 56, 30);
  pxText("P" + (i + 1), x + 10, y + 5, 20, WHITE);

  pxText(names[i].toUpperCase(), x + 16, y + 176, 28, WHITE);
  pxText(tags[i], x + 16, y + 214, 12, TEAL);

  // key chip
  fill(BG);
  rect(x + 16, y + 250, cw - 32, 30);
  pxText(hints[i], x + 26, y + 257, 14, YEL);

  // press chip
  fill(sel ? RED : PANEL2);
  rect(x + 16, y + 292, cw - 32, 30);
  pxText(sel ? "SQUEEZE TO PLAY" : "TILT TO SELECT", x + 26, y + 299, 14, sel ? WHITE : GREY);

  // best
  pxText("BEST", x + 16, y + 342, 12, GREY);
  pxTextR(nf(best[i], 3), x + cw - 16, y + 334, 24, WHITE);
}
