// Red / black / white only (plus neutral greys).
final color BG      = #0A0A0A;
final color PANEL   = #16161A;
final color PANEL2  = #222228;
final color RED     = #E10600;
final color REDD    = #8F0400;
final color WHITE   = #F4F4F4;
final color GREY    = #8C8C96;

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
  textFont(pxFont); textSize(sz);
  pxText(s, x - textWidth(s), y, sz, c);
}
void pxTextC(String s, float cx, float y, int sz, color c) {
  textFont(pxFont); textSize(sz);
  pxText(s, cx - textWidth(s) / 2, y, sz, c);
}

void checker(int x, int y, int w, int h, int cell, color a, color b) {
  noStroke();
  for (int j = 0; j * cell < h; j++)
    for (int i = 0; i * cell < w; i++) {
      fill(((i + j) % 2 == 0) ? a : b);
      rect(x + i * cell, y + j * cell, min(cell, w - i * cell), min(cell, h - j * cell));
    }
}
void kerbH(int x, int y, int w, int h) {
  noStroke();
  for (int i = 0; i * h < w; i++) { fill(i % 2 == 0 ? RED : WHITE); rect(x + i * h, y, min(h, w - i * h), h); }
}
void kerbV(int x, int y, int w, int h) {
  noStroke();
  for (int i = 0; i * w < h; i++) { fill(i % 2 == 0 ? RED : WHITE); rect(x, y + i * w, w, min(w, h - i * w)); }
}

void hud(String s) {
  noStroke();
  fill(0, 190);
  rect(6, 6, 16 + s.length() * 10, 26);
  fill(RED);
  rect(6, 6, 4, 26);
  pxText(s, 18, 10, 16, WHITE);
}

void banner(String s, String sub) {
  noStroke();
  fill(0, 220);
  rect(0, 140, GW, 120);
  kerbH(0, 140, GW, 6);
  kerbH(0, 254, GW, 6);
  pxTextC(s, GW / 2, 164, 40, RED);
  pxTextC(sub, GW / 2, 222, 16, WHITE);
}
