// Grid settings
int rows = 5;
int cols = 8;
boolean[][] bricks;
float brickW, brickH;
float topOffset = 50;

// Paddle settings
float paddleW = 100;
float paddleH = 15;
float paddleX;
float paddleY;
float paddleSpeed = 7; // Adjust to make the bar faster or slower

// Ball settings
float ballX, ballY;
float ballSize = 14;
float speedX = 4;
float speedY = -4;

// Game state
int score = 0;
int lives = 3;
boolean gameOver = false;
boolean gameWon = false;

void setupBB() {
  brickW = width / (float) cols;
  brickH = height * 0.05;      // Scales brick height proportionally (e.g., 25px on 500px height)
  paddleW = width * 0.16;      // Scales paddle width proportionally (e.g., ~100px on 600px width)
  paddleY = height - 40;
  resetGame();
  /*
  brickW = width / (float) cols;
  brickH = 25;
  paddleY = height - 40;
  resetGame();
  */
}

void drawBB() {
  background(20);

  if (gameOver || gameWon) {
    drawEndScreen();
    return;
  }

  // 1. Update & Draw Paddle
  if (currentDirection == LEFT) {
    paddleX -= paddleSpeed;
  } else if (currentDirection == RIGHT) {
    paddleX += paddleSpeed;
  }
  
  // Keep paddle inside screen bounds
  paddleX = constrain(paddleX, 0, width - paddleW);

  fill(255);
  rect(paddleX, paddleY, paddleW, paddleH, 5);
  
  // 2. Update & Draw Ball
  ballX += speedX;
  ballY += speedY;
  ellipse(ballX, ballY, ballSize, ballSize);

  // Wall collisions
  if (ballX - ballSize / 2 <= 0 || ballX + ballSize / 2 >= width) {
    speedX *= -1;
  }
  if (ballY - ballSize / 2 <= 0) {
    speedY *= -1;
  }

  // Bottom out-of-bounds (lose life)
  if (ballY - ballSize / 2 > height) {
    lives--;
    if (lives <= 0) {
      gameOver = true;
    } else {
      resetBall();
    }
  }

  // Paddle collision
  if (ballY + ballSize / 2 >= paddleY &&
      ballY - ballSize / 2 <= paddleY + paddleH &&
      ballX >= paddleX &&
      ballX <= paddleX + paddleW &&
      speedY > 0) {
    speedY *= -1;
    // Deflect angle based on where the ball hits the paddle
    float hitOffset = (ballX - (paddleX + paddleW / 2)) / (paddleW / 2);
    speedX = hitOffset * 5;
  }

  // 3. Draw Bricks & Check Collisions
  int activeBricks = 0;
  for (int r = 0; r < rows; r++) {
    for (int c = 0; c < cols; c++) {
      if (bricks[r][c]) {
        activeBricks++;
        float bx = c * brickW;
        float by = topOffset + r * brickH;

        fill(100 + r * 30, 180, 255 - r * 30);
        stroke(20);
        rect(bx, by, brickW, brickH);

        // Simple bounding-box check
        if (ballX + ballSize / 2 > bx &&
            ballX - ballSize / 2 < bx + brickW &&
            ballY + ballSize / 2 > by &&
            ballY - ballSize / 2 < by + brickH) {
          bricks[r][c] = false;
          speedY *= -1;
          score += 10;
        }
      }
    }
  }

  if (activeBricks == 0) {
    gameWon = true;
  }

  // 4. HUD (Score & Lives)
  fill(255);
  textSize(16);
  textAlign(LEFT, TOP);
  text("Score: " + score, 15, 15);
  textAlign(RIGHT, TOP);
  text("Lives: " + lives, width - 15, 15);
}

void resetBall() {
  ballX = width / 2;
  ballY = height / 2;
  speedX = random(-3, 3);
  speedY = -4;
}

void resetGame() {
  bricks = new boolean[rows][cols];
  for (int r = 0; r < rows; r++) {
    for (int c = 0; c < cols; c++) {
      bricks[r][c] = true;
    }
  }
  score = 0;
  lives = 3;
  gameOver = false;
  gameWon = false;
  paddleX = (width - paddleW) / 2;
  resetBall();
}

void drawEndScreen() {
  fill(255);
  textAlign(CENTER, CENTER);
  textSize(32);
  text(gameWon ? "YOU WIN!" : "GAME OVER", width / 2, height / 2 - 20);
  textSize(18);
  text("Final Score: " + score + "\nClick anywhere to restart", width / 2, height / 2 + 30);
}
