float birdY, birdV;
int pipeX, gapY, flapScore;
boolean flapOver;

void flappyStart() {
  birdY = 200;
  birdV = 0;
  pipeX = 600;
  gapY = int(random(100, 300));
  flapScore = 0;
  flapOver = false;
}

void flappyKey(char k) {
  if (flapOver) {
    flappyStart();
    return;
  }
  if (k == 'w') birdV = -7;
}

void barrier(int x, int y, int w, int h, boolean capAtBottom) {
  noStroke();
  for (int j = 0; j * 20 < h; j++) {
    fill(j % 2 == 0 ? RED : WHITE);
    rect(x, y + j * 20, w, min(20, h - j * 20));
  }
  fill(0, 70);
  rect(x + w - 6, y, 6, h);          // shaded edge
  fill(BLACKPX);                      // cap
  rect(x - 3, capAtBottom ? y + h - 8 : y, w + 6, 8);
  fill(255, 255, 255, 60);
  rect(x - 3, capAtBottom ? y + h - 8 : y, w + 6, 2);
}

void flappyDraw() {
  if (!flapOver) {
    birdV += 0.5;
    birdY += birdV;
    pipeX -= 3;
    if (pipeX < -40) {
      pipeX = 600;
      gapY = int(random(100, 300));
      flapScore++;
    }

    if (birdY < 0 || birdY > mh) flapOver = true;
    if (110 > pipeX && 90 < pipeX + 40) {
      if (birdY - 10 < gapY - 60 || birdY + 10 > gapY + 60) flapOver = true;
    }
    if (flapOver && flapScore > best[2]) best[2] = flapScore;
  }

  // ---- render only ----
  fill(ASPH);
  noStroke();
  rect(0, 0, mw, mh);
  checker(0, 0, mw, mh, 40, ASPH, ASPH2);
  // moving track dashes for speed
  fill(255, 255, 255, 28);
  int off = flapOver ? 0 : (frameCount * 3) % 80;
  for (int k = -1; k < 8; k++) rect(k * 80 - off, 196, 40, 6);
  kerbH(0, 0, mw, 8);
  kerbH(0, mh - 8, mw, 8);

  barrier(pipeX, 8, 40, gapY - 60 - 8, true);
  barrier(pipeX, gapY + 60, 40, mh - gapY - 60 - 8, false);

  // car + exhaust
  if (!flapOver) {
    fill(random(1) < 0.5 ? YEL : #FF8A00);
    rect(78, round(birdY) - 3, 6, 6);
    fill(255, 140, 0, 140);
    rect(70, round(birdY) - 2, 6, 4);
  }
  spriteC(CAR, 100, round(birdY), 2);

  hud("SCORE " + flapScore + "   BEST " + max(best[2], flapScore));
  if (flapOver) banner("WALL HIT", "Game over - tilt up to restart");
}
