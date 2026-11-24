// F1 ARCADE - red/black/white. 1 or 2 players, each with their own wearable.
// Input is read exactly like app/ (serial.pde + direction.pde):
//   head tilt  -> menu selection / game steering      FSR > 200 -> select; hold 1.5s -> exit
final int W = 1400, H = 800;     // logical canvas, scaled to fill the screen
String[] names = {"Snake", "Catch", "Flappy"};
String[] hints = {"TILT U D L R", "TILT L / R", "TILT UP = FLAP"};

int mode = 0;          // 0 = 1 player, 1 = 2 player
int focusRow = 1;      // 0 = mode row, 1 = game row
int selected = 0;
int game = 0;          // 0 = home, 1..3
int prevMove = 0;
Game[] play = new Game[2];

boolean fsrLock = false;
int fsrHeld = 0;
int[] lastDirSent = {0, 0};   // 0 = NEUTRAL
int[] lastCtl = {0, 0};
final int EXIT_HOLD_MS = 1500;

void setup() {
  fullScreen();
  noSmooth();
  initTheme();
  setupSerial();
}

void keyPressed() {
  if (key == 'c' || key == 'C') for (int i = 0; i < 2; i++) sensors[i].recalibrate();
}

int players() { return mode + 1; }

boolean ready() {
  for (int i = 0; i < players(); i++) if (!sensors[i].calibrated) return false;
  return true;
}

void startGame(int g) {
  game = g;
  for (int i = 0; i < players(); i++) {
    if (g == 1) play[i] = new SnakeG(i);
    if (g == 2) play[i] = new CatchG(i);
    if (g == 3) play[i] = new FlappyG(i);
    lastDirSent[i] = 0;
  }
  fsrLock = true;
  fsrHeld = 0;
}

void homeControls() {
  Sensor s = sensors[0];
  if (millis() - prevMove > 1000 && s.calibrated) {
    int d = s.currentDirection;
    if (d == UP)   { focusRow = 0; prevMove = millis(); }
    if (d == DOWN) { focusRow = 1; prevMove = millis(); }
    if (d == RIGHT || d == LEFT) {
      int step = (d == RIGHT) ? 1 : -1;
      if (focusRow == 0) mode = (mode + step + 2) % 2;
      else selected = (selected + step + names.length) % names.length;
      prevMove = millis();
    }
  }
  if (s.fsr <= 200) fsrLock = false;
  if (s.fsr > 200 && !fsrLock && focusRow == 1 && ready()) startGame(selected + 1);
}

void gameControls() {
  boolean any = false;
  for (int i = 0; i < players(); i++) if (sensors[i].fsr > 200) any = true;
  if (!any) { fsrLock = false; fsrHeld = 0; }
  else if (!fsrLock) {
    if (fsrHeld == 0) fsrHeld = millis();
    if (millis() - fsrHeld > EXIT_HOLD_MS) { game = 0; fsrLock = true; fsrHeld = 0; return; }
  }

  for (int i = 0; i < players(); i++) {
    Sensor s = sensors[i];
    if (!s.calibrated) continue;
    char k = 0;
    if (s.currentDirection == RIGHT) k = 'd';
    else if (s.currentDirection == LEFT) k = 'a';
    else if (s.currentDirection == UP) k = 'w';
    else if (s.currentDirection == DOWN) k = 's';
    if (k == 0) { lastDirSent[i] = 0; continue; }
    int gap = (game == 2) ? 180 : (game == 3) ? 350 : 0;
    if (s.currentDirection != lastDirSent[i] || millis() - lastCtl[i] > gap) {
      lastDirSent[i] = s.currentDirection;
      lastCtl[i] = millis();
      play[i].key(k);
    }
  }
}

void draw() {
  background(BG);
  float sc = min(width / (float) W, height / (float) H);
  translate((width - W * sc) / 2, (height - H * sc) / 2);
  scale(sc);

  if (game == 0) { homeControls(); drawHome(); }
  else { gameControls(); drawGame(); }
}

// ------------------------------------------------------------ game screen
void drawGame() {
  kerbH(0, 0, W, 10);
  checker(0, H - 20, W, 20, 10, WHITE, BG);
  pxText(names[game - 1].toUpperCase() + "  " + (players() == 1 ? "1 PLAYER" : "2 PLAYER"), 60, 34, 32, WHITE);
  pxTextR("HOLD SQUEEZE = EXIT", W - 60, 44, 16, GREY);
  if (fsrHeld > 0) {
    fill(RED);
    noStroke();
    rect(60, 80, (W - 120) * constrain((millis() - fsrHeld) / (float) EXIT_HOLD_MS, 0, 1), 6);
  }

  if (players() == 1) panel(0, 220, 110, 1.6);
  else { panel(0, 70, 220, 1.0); panel(1, 730, 220, 1.0); }
}

void panel(int pi, float x, float y, float sc) {
  pushMatrix();
  translate(x, y);
  scale(sc);
  if (pi == 0 || players() == 2) pxText("P" + (pi + 1), 0, -34, 26, RED);
  if (players() == 2 && !sensors[pi].calibrated) pxText("CALIBRATING " + sensors[pi].sampleCount + "/" + TOTAL_SAMPLES, 60, -30, 16, GREY);
  play[pi].draw();
  // mask pipe overhang, then frame
  noStroke();
  fill(BG);
  rect(-120, -10, 120, GH + 20);
  rect(GW, -10, 120, GH + 20);
  kerbFrameLines();
  popMatrix();
}

void kerbFrameLines() {
  noFill();
  stroke(WHITE);
  strokeWeight(3);
  rect(0, 0, GW, GH);
  noStroke();
}

// ------------------------------------------------------------ home screen
void drawHome() {
  kerbH(0, 0, W, 10);
  checker(0, H - 20, W, 20, 10, WHITE, BG);

  pxText("F1 ARCADE", 60, 40, 64, WHITE);
  fill(RED);
  noStroke();
  rect(60, 116, 200, 6);

  // sensor status
  for (int i = 0; i < 2; i++) {
    Sensor s = sensors[i];
    String st = !s.connected ? "NO SENSOR" : (!s.calibrated ? "HOLD STILL " + s.sampleCount + "/" + TOTAL_SAMPLES : "READY");
    boolean needed = i < players();
    fill(needed ? PANEL2 : PANEL);
    rect(W - 380, 40 + i * 44, 320, 36);
    fill(s.calibrated ? RED : PANEL);
    rect(W - 380, 40 + i * 44, 8, 36);
    pxText("P" + (i + 1) + "  " + st, W - 360, 47 + i * 44, 16, needed ? WHITE : GREY);
  }

  // mode switch
  String[] ml = {"1 PLAYER", "2 PLAYER"};
  for (int i = 0; i < 2; i++) {
    int x = 60 + i * 340, y = 160;
    boolean on = (i == mode);
    if (focusRow == 0) { fill(WHITE); rect(x - 4, y - 4, 328, 78); }
    fill(on ? RED : PANEL2);
    rect(x, y, 320, 70);
    pxTextC(ml[i], x + 160, y + 20, 30, on ? WHITE : GREY);
  }
  pxText(focusRow == 0 ? "TILT L/R = SWITCH   TILT DOWN = GAMES" : "TILT UP = MODE   TILT L/R = PICK   SQUEEZE = PLAY", 60, 250, 16, GREY);

  // games
  for (int i = 0; i < 3; i++) card(60 + i * 440, 300, 400, 420, i);

  if (!ready()) {
    pxText("CALIBRATING... HOLD HEAD STILL  (C = RECALIBRATE)", 60, 740, 16, RED);
  } else {
    Sensor s = sensors[0];
    pxText("P1 DIR " + s.currentDirection + "  FSR " + nf(s.fsr, 0, 0) + "   (C = RECALIBRATE)", 60, 740, 14, GREY);
  }
}

void card(int x, int y, int cw, int ch, int i) {
  boolean sel = (i == selected);
  noStroke();
  if (sel && focusRow == 1) { fill(WHITE); rect(x - 5, y - 5, cw + 10, ch + 10); }
  fill(PANEL);
  rect(x, y, cw, ch);
  fill(PANEL2);
  rect(x + 10, y + 10, cw - 20, 170);
  icon(i, x + 10, y + 10);

  fill(sel ? RED : PANEL2);
  rect(x, y, 70, 34);
  pxText("0" + (i + 1), x + 12, y + 5, 22, WHITE);

  pxText(names[i].toUpperCase(), x + 20, y + 200, 36, WHITE);
  pxText(hints[i], x + 20, y + 252, 16, GREY);

  fill(sel ? RED : PANEL2);
  rect(x + 20, y + 290, cw - 40, 40);
  pxTextC(sel ? "SQUEEZE TO PLAY" : "SELECT", x + cw / 2, y + 301, 18, sel ? WHITE : GREY);

  pxText("BEST", x + 20, y + 354, 14, GREY);
  pxText("P1 " + best[0][i], x + 20, y + 378, 20, WHITE);
  pxText("P2 " + best[1][i], x + 200, y + 378, 20, WHITE);
}

void icon(int i, int x, int y) {
  pushMatrix();
  translate(x, y);
  noStroke();
  if (i == 0) {
    for (int k = 0; k < 6; k++) { fill(k % 2 == 0 ? RED : REDD); rect(50 + k * 28, 100, 24, 24); }
    fill(WHITE); rect(50 + 6 * 28, 100, 24, 24);
    fill(WHITE); rect(300, 40, 18, 18);
  } else if (i == 1) {
    fill(WHITE); ellipse(120, 30 + (frameCount / 4) % 60, 22, 22);
    ellipse(260, 50 + (frameCount / 5) % 50, 22, 22);
    fill(WHITE); rect(150, 140, 100, 12);
    fill(RED); rect(150, 140, 26, 12); rect(224, 140, 26, 12);
  } else {
    for (int k = 0; k < 4; k++) { fill(k % 2 == 0 ? RED : WHITE); rect(280, k * 22, 40, 22); }
    for (int k = 0; k < 3; k++) { fill(k % 2 == 0 ? WHITE : RED); rect(280, 110 + k * 22, 40, 22); }
    fill(WHITE); ellipse(100, 85 + sin(frameCount * 0.1) * 14, 24, 24);
  }
  popMatrix();
}
