int padX, itemX, itemY, catchScore, lives;

void catchStart() {
  padX = 260;
  itemX = int(random(20, 580));
  itemY = 0;
  catchScore = 0;
  lives = 3;
}

void catchKey(char k) {
  if (lives == 0) {
    catchStart();
    return;
  }
  if (k == 'a') padX = max(0, padX - 40);
  if (k == 'd') padX = min(mw - 80, padX + 40);
}

void catchDraw() {
  if (lives > 0) {
    itemY += 3 + catchScore / 5;
    if (itemY >= mh - 20) {
      if (itemX > padX && itemX < padX + 80) catchScore++;
      else lives--;
      itemX = int(random(20, 580));
      itemY = 0;
      if (lives == 0 && catchScore > best[1]) best[1] = catchScore;
    }
  }

  // ---- render only ----
  fill(ASPH);
  noStroke();
  rect(0, 0, mw, mh);
  // pit-straight lines
  fill(ASPH2);
  for (int i = 0; i < 6; i++) rect(i * 100 + 98, 0, 4, mh);
  fill(255, 255, 255, 30);
  for (int k = 0; k < 10; k++) rect(298, ((k * 50 + frameCount * 3) % 500) - 20, 4, 24);
  checker(0, mh - 8, mw, 8, 8, WHITE, BLACKPX);

  // falling tyre
  spriteC(TYRE, itemX, itemY, 2);

  // catcher: front wing
  fill(0, 120);
  rect(padX + 3, mh - 17, 80, 10);
  fill(WHITE);
  rect(padX, mh - 20, 80, 10);
  fill(RED);
  rect(padX, mh - 20, 16, 10);
  rect(padX + 64, mh - 20, 16, 10);
  fill(BLACKPX);
  rect(padX + 34, mh - 20, 12, 10);
  fill(255, 255, 255, 90);
  rect(padX, mh - 20, 80, 2);

  hud("SCORE " + catchScore + "   BEST " + max(best[1], catchScore));
  // lives as start lamps
  for (int i = 0; i < 3; i++) {
    fill(i < lives ? RED : #2A1216);
    rect(mw - 30 - i * 28, 10, 20, 20);
    if (i < lives) { fill(#FF6A5E); rect(mw - 26 - i * 28, 14, 7, 7); }
  }
  if (lives == 0) banner("OUT OF TYRES", "Game over - tilt to restart");
}
