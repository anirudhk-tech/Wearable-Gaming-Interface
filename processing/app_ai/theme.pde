// Shared look: palette, pixel text, pixel sprites, kerbs.
final color BG      = #0B0E17;
final color PANEL   = #151B2E;
final color PANEL2  = #1D2644;
final color ASPH    = #161B2B;
final color ASPH2   = #1A2033;
final color RED     = #E10600;
final color REDD    = #9C0400;
final color WHITE   = #F4F4F4;
final color TEAL    = #00D2BE;
final color YEL     = #FFD400;
final color GREY    = #8A93A8;
final color BLACKPX = #0A0A0F;

PFont pxFont;

void initTheme() {
  pxFont = createFont("Courier New Bold", 32, false);
  textFont(pxFont);
}

void pxText(String s, float x, float y, int sz, color c) {
  textFont(pxFont);
  textSize(sz);
  textAlign(LEFT, TOP);
  fill(0, 160);
  text(s, x + max(1, sz / 12), y + max(1, sz / 12));
  fill(c);
  text(s, x, y);
}

void pxTextR(String s, float x, float y, int sz, color c) {
  textFont(pxFont);
  textSize(sz);
  float w = textWidth(s);
  pxText(s, x - w, y, sz, c);
}

void pxTextC(String s, float cx, float y, int sz, color c) {
  textFont(pxFont);
  textSize(sz);
  pxText(s, cx - textWidth(s) / 2, y, sz, c);
}

void checker(int x, int y, int w, int h, int cell, color a, color b) {
  noStroke();
  for (int j = 0; j * cell < h; j++) {
    for (int i = 0; i * cell < w; i++) {
      fill(((i + j) % 2 == 0) ? a : b);
      rect(x + i * cell, y + j * cell, min(cell, w - i * cell), min(cell, h - j * cell));
    }
  }
}

void kerbH(int x, int y, int w, int h) {
  noStroke();
  for (int i = 0; i * h < w; i++) {
    fill(i % 2 == 0 ? RED : WHITE);
    rect(x + i * h, y, min(h, w - i * h), h);
  }
}

void kerbV(int x, int y, int w, int h) {
  noStroke();
  for (int i = 0; i * w < h; i++) {
    fill(i % 2 == 0 ? RED : WHITE);
    rect(x, y + i * w, w, min(w, h - i * w));
  }
}

void kerbFrame(int x, int y, int w, int h) {
  fill(BG);
  noStroke();
  rect(x - 4, y - 4, w + 8, h + 8);
  kerbH(x, y, w, 6);
  kerbH(x, y + h - 6, w, 6);
  kerbV(x, y, 6, h);
  kerbV(x + w - 6, y, 6, h);
}

color pal(char c) {
  switch (c) {
    case 'R': return RED;
    case 'r': return REDD;
    case 'W': return WHITE;
    case 'K': return #15151C;
    case 'D': return #4A5068;
    case 'G': return GREY;
    case 'Y': return YEL;
    case 'T': return TEAL;
    case 'O': return #FF8A00;
  }
  return 0;
}

void sprite(String[] rows, float x, float y, int s) {
  noStroke();
  for (int j = 0; j < rows.length; j++) {
    for (int i = 0; i < rows[j].length(); i++) {
      char c = rows[j].charAt(i);
      if (c == '.') continue;
      fill(pal(c));
      rect(x + i * s, y + j * s, s, s);
    }
  }
}

// F1 car, top-down, nose pointing right (10 x 6)
String[] CAR = {
  "WWKKR.KK..",
  "WRRRRRRRR.",
  "WRRYYRRRRR",
  "WRRYYRRRRR",
  "WRRRRRRRR.",
  "WWKKR.KK.."
};

// Tyre (10 x 10), yellow soft-compound sidewall
String[] TYRE = {
  "..DDDDDD..",
  ".DKKKKKKD.",
  "DKKYYYYKKD",
  "DKYYKKYYKD",
  "DKYKGGKYKD",
  "DKYKGGKYKD",
  "DKYYKKYYKD",
  "DKKYYYYKKD",
  ".DKKKKKKD.",
  "..DDDDDD.."
};

// centre a sprite on (cx, cy)
void spriteC(String[] rows, float cx, float cy, int s) {
  sprite(rows, cx - rows[0].length() * s / 2.0, cy - rows.length * s / 2.0, s);
}

// rotated (multiples of 90deg) sprite centred on (cx, cy)
void spriteRot(String[] rows, float cx, float cy, int s, float ang) {
  pushMatrix();
  translate(round(cx), round(cy));
  rotate(ang);
  sprite(rows, -rows[0].length() * s / 2.0, -rows.length * s / 2.0, s);
  popMatrix();
}

void hud(String s) {
  noStroke();
  fill(0, 170);
  rect(6, 6, textWidth(s) * 0 + 12 + s.length() * 10, 26);
  fill(RED);
  rect(6, 6, 4, 26);
  pxText(s, 18, 10, 16, WHITE);
}

void banner(String s, String sub) {
  noStroke();
  fill(0, 200);
  rect(0, 140, 600, 120);
  kerbH(0, 140, 600, 6);
  kerbH(0, 254, 600, 6);
  pxTextC(s, 300, 164, 40, RED);
  pxTextC(sub, 300, 222, 16, WHITE);
}

void drawIcon(int i, int x, int y, int w, int h) {
  pushMatrix();
  translate(x, y);
  noStroke();
  if (i == 0) {            // snake: car train + tyre
    for (int k = 0; k < 5; k++) { fill(k % 2 == 0 ? RED : REDD); rect(30 + k * 24, 100, 20, 20); }
    spriteRot(CAR, 30 + 5 * 24 + 10, 110, 2, 0);
    spriteC(TYRE, 168, 50, 2);
  } else if (i == 1) {     // catch: falling tyres + wing
    spriteC(TYRE, 60, 30 + (frameCount / 4) % 40, 2);
    spriteC(TYRE, 150, 60 + (frameCount / 5) % 30, 2);
    fill(WHITE); rect(60, 128, 90, 8);
    fill(RED);   rect(60, 128, 30, 8); rect(120, 128, 30, 8);
  } else {                 // flappy: barriers + car
    for (int k = 0; k < 4; k++) { fill(k % 2 == 0 ? RED : WHITE); rect(150, k * 20, 36, 20); }
    for (int k = 0; k < 3; k++) { fill(k % 2 == 0 ? WHITE : RED); rect(150, 100 + k * 20, 36, 20); }
    sprite(CAR, 40, 60 + round(sin(frameCount * 0.1) * 8), 3);
  }
  popMatrix();
}
