int[] sx = new int[600];
int[] sy = new int[600];
int snakeLen, dir, foodX, foodY, snakeScore, lastMove;
boolean snakeOver;
int[] dx = {1, 0, -1, 0};
int[] dy = {0, 1, 0, -1};

void snakeStart() {
  snakeLen = 3;
  for (int i = 0; i < snakeLen; i++) {
    sx[i] = 10 - i;
    sy[i] = 10;
  }
  dir = 0;
  snakeScore = 0;
  snakeOver = false;
  foodX = int(random(30));
  foodY = int(random(20));
  lastMove = millis();
}

void snakeKey(char k) {
  if (snakeOver) {
    snakeStart();
    return;
  }
  if (k == 'd' && dir != 2) dir = 0;
  if (k == 's' && dir != 3) dir = 1;
  if (k == 'a' && dir != 0) dir = 2;
  if (k == 'w' && dir != 1) dir = 3;
}

void snakeDraw() {
  if (!snakeOver && millis() - lastMove > 150) {
    lastMove = millis();
    int tailX = sx[snakeLen - 1];
    int tailY = sy[snakeLen - 1];
    for (int i = snakeLen - 1; i > 0; i--) {
      sx[i] = sx[i - 1];
      sy[i] = sy[i - 1];
    }
    sx[0] += dx[dir];
    sy[0] += dy[dir];

    if (sx[0] < 0 || sx[0] >= 30 || sy[0] < 0 || sy[0] >= 20) snakeOver = true;
    for (int i = 1; i < snakeLen; i++) {
      if (sx[0] == sx[i] && sy[0] == sy[i]) snakeOver = true;
    }
    if (sx[0] == foodX && sy[0] == foodY) {
      sx[snakeLen] = tailX;
      sy[snakeLen] = tailY;
      snakeLen++;
      snakeScore++;
      foodX = int(random(30));
      foodY = int(random(20));
    }
    if (snakeOver && snakeScore > best[0]) best[0] = snakeScore;
  }

  // ---- render only ----
  checker(0, 0, mw, mh, 20, ASPH, ASPH2);

  // tyre (food)
  spriteC(TYRE, foodX * 20 + 10, foodY * 20 + 10, 2);

  // body: alternating livery, fading toward the tail
  noStroke();
  for (int i = snakeLen - 1; i >= 1; i--) {
    color c = (i % 2 == 0) ? RED : REDD;
    fill(lerpColor(c, ASPH, constrain(i * 0.015, 0, 0.5)));
    rect(sx[i] * 20 + 1, sy[i] * 20 + 1, 18, 18);
    fill(255, 255, 255, 50);
    rect(sx[i] * 20 + 1, sy[i] * 20 + 1, 18, 3);
    fill(0, 0, 0, 70);
    rect(sx[i] * 20 + 1, sy[i] * 20 + 16, 18, 3);
  }
  // head: the car
  spriteRot(CAR, sx[0] * 20 + 10, sy[0] * 20 + 10, 2, dir * HALF_PI);

  hud("SCORE " + snakeScore + "   BEST " + max(best[0], snakeScore));
  if (snakeOver) banner("CRASHED", "Game over - tilt to restart");
}
