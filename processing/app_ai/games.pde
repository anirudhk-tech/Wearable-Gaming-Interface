// Same game logic as final/. Each game is a class so every player gets their own copy.
final int GW = 600, GH = 400;
int[][] best = new int[2][3];   // [player][game]

abstract class Game {
  int pi;
  Game(int p) { pi = p; }
  abstract void start();
  abstract void key(char k);
  abstract void draw();
}

// ---------------------------------------------------------------- SNAKE
class SnakeG extends Game {
  int[] sx = new int[600];
  int[] sy = new int[600];
  int snakeLen, dir, foodX, foodY, snakeScore, lastMove;
  boolean snakeOver;
  int[] dx = {1, 0, -1, 0};
  int[] dy = {0, 1, 0, -1};
  SnakeG(int p) { super(p); start(); }

  void start() {
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

  void key(char k) {
    if (snakeOver) { start(); return; }
    if (k == 'd' && dir != 2) dir = 0;
    if (k == 's' && dir != 3) dir = 1;
    if (k == 'a' && dir != 0) dir = 2;
    if (k == 'w' && dir != 1) dir = 3;
  }

  void draw() {
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
      if (snakeOver && snakeScore > best[pi][0]) best[pi][0] = snakeScore;
    }

    // render
    checker(0, 0, GW, GH, 20, PANEL, #1B1B20);
    noStroke();
    fill(WHITE);
    rect(foodX * 20 + 3, foodY * 20 + 3, 14, 14);
    fill(RED);
    rect(foodX * 20 + 7, foodY * 20 + 7, 6, 6);
    for (int i = snakeLen - 1; i >= 1; i--) {
      fill(i % 2 == 0 ? RED : REDD);
      rect(sx[i] * 20 + 1, sy[i] * 20 + 1, 18, 18);
    }
    fill(WHITE);
    rect(sx[0] * 20, sy[0] * 20, 20, 20);
    fill(RED);
    rect(sx[0] * 20 + 5, sy[0] * 20 + 5, 10, 10);

    hud("SCORE " + snakeScore + "   BEST " + max(best[pi][0], snakeScore));
    if (snakeOver) banner("GAME OVER", "tilt to restart");
  }
}

// ---------------------------------------------------------------- CATCH
class CatchG extends Game {
  int padX, itemX, itemY, catchScore, lives;
  CatchG(int p) { super(p); start(); }

  void start() {
    padX = 260;
    itemX = int(random(20, 580));
    itemY = 0;
    catchScore = 0;
    lives = 3;
  }

  void key(char k) {
    if (lives == 0) { start(); return; }
    if (k == 'a') padX = max(0, padX - 40);
    if (k == 'd') padX = min(GW - 80, padX + 40);
  }

  void draw() {
    if (lives > 0) {
      itemY += 3 + catchScore / 5;
      if (itemY >= GH - 20) {
        if (itemX > padX && itemX < padX + 80) catchScore++;
        else lives--;
        itemX = int(random(20, 580));
        itemY = 0;
        if (lives == 0 && catchScore > best[pi][1]) best[pi][1] = catchScore;
      }
    }

    // render
    noStroke();
    fill(PANEL);
    rect(0, 0, GW, GH);
    fill(#1B1B20);
    for (int i = 0; i < 6; i++) rect(i * 100 + 98, 0, 4, GH);
    checker(0, GH - 8, GW, 8, 8, WHITE, BG);

    fill(WHITE);
    ellipse(itemX, itemY, 20, 20);
    fill(RED);
    ellipse(itemX, itemY, 8, 8);

    fill(WHITE);
    rect(padX, GH - 20, 80, 10);
    fill(RED);
    rect(padX, GH - 20, 16, 10);
    rect(padX + 64, GH - 20, 16, 10);

    hud("SCORE " + catchScore + "   BEST " + max(best[pi][1], catchScore));
    for (int i = 0; i < 3; i++) {
      fill(i < lives ? RED : PANEL2);
      rect(GW - 30 - i * 28, 10, 20, 20);
    }
    if (lives == 0) banner("GAME OVER", "tilt to restart");
  }
}

// ---------------------------------------------------------------- FLAPPY
class FlappyG extends Game {
  float birdY, birdV;
  int pipeX, gapY, flapScore;
  boolean flapOver;
  FlappyG(int p) { super(p); start(); }

  void start() {
    birdY = 200;
    birdV = 0;
    pipeX = 600;
    gapY = int(random(100, 300));
    flapScore = 0;
    flapOver = false;
  }

  void key(char k) {
    if (flapOver) { start(); return; }
    if (k == 'w') birdV = -7;
  }

  void barrier(int x, int y, int w, int h) {
    noStroke();
    for (int j = 0; j * 20 < h; j++) {
      fill(j % 2 == 0 ? RED : WHITE);
      rect(x, y + j * 20, w, min(20, h - j * 20));
    }
    fill(0, 70);
    rect(x + w - 6, y, 6, h);
  }

  void draw() {
    if (!flapOver) {
      birdV += 0.5;
      birdY += birdV;
      pipeX -= 3;
      if (pipeX < -40) {
        pipeX = 600;
        gapY = int(random(100, 300));
        flapScore++;
      }

      if (birdY < 0 || birdY > GH) flapOver = true;
      if (110 > pipeX && 90 < pipeX + 40) {
        if (birdY - 10 < gapY - 60 || birdY + 10 > gapY + 60) flapOver = true;
      }
      if (flapOver && flapScore > best[pi][2]) best[pi][2] = flapScore;
    }

    // render
    noStroke();
    fill(PANEL);
    rect(0, 0, GW, GH);
    fill(255, 255, 255, 24);
    int off = flapOver ? 0 : (frameCount * 3) % 80;
    for (int k = -1; k < 8; k++) rect(k * 80 - off, 196, 40, 6);
    kerbH(0, 0, GW, 8);
    kerbH(0, GH - 8, GW, 8);

    barrier(pipeX, 8, 40, gapY - 60 - 8);
    barrier(pipeX, gapY + 60, 40, GH - gapY - 60 - 8);

    fill(WHITE);
    ellipse(100, birdY, 20, 20);
    fill(RED);
    ellipse(100, birdY, 8, 8);

    hud("SCORE " + flapScore + "   BEST " + max(best[pi][2], flapScore));
    if (flapOver) banner("GAME OVER", "tilt up to restart");
  }
}
