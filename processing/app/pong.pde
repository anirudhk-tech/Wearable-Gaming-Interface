// Pong Paddle settings
float pongPaddleW = 15;
float pongPaddleH = 90;
float player1Y, player2Y;
float player1X, player2X;
float player1Speed = 7;
float player2Speed = 7;

// Pong Ball settings
float pongBallX, pongBallY;
float pongBallSize = 14;
float pongSpeedX = 5;
float pongSpeedY = 3;

// Pong Game state
int player1Score = 0;
int player2Score = 0;
int winningScore = 5;
boolean pongGameOver = false;

int player1Direction = NEUTRAL;
int player2Direction = NEUTRAL;

void setupPong() {
  // Adapts automatically to your main window's width and height
  pongPaddleH = height * 0.18;
  player1X = 30;
  player2X = width - 30 - pongPaddleW;
  resetPongGame();
}

void drawPong() {
  background(20);

  if (pongGameOver) {
    drawPongEndScreen();
    return;
  }
  
  player1Direction = currentDirection;
  player2Direction = currentDirection;
  
  // 1. Update Player 1 Paddle (Left)
  if (player1Direction == UP) {
    player1Y -= player1Speed;
  } else if (player1Direction == DOWN) {
    player1Y += player1Speed;
  }
  player1Y = constrain(player1Y, 0, height - pongPaddleH);

  // 2. Update Player 2 Paddle (Right)
  if (player2Direction == UP) {
    player2Y -= player1Speed;
  } else if (player2Direction == DOWN) {
    player2Y += player1Speed;
  }
  player2Y = constrain(player2Y, 0, height - pongPaddleH);

  // 3. Draw Center Line & Paddles
  stroke(80);
  strokeWeight(2);
  for (int y = 0; y < height; y += 20) {
    line(width / 2, y, width / 2, y + 10);
  }

  noStroke();
  fill(255);
  rect(player1X, player1Y, pongPaddleW, pongPaddleH, 4);
  rect(player2X, player2Y, pongPaddleW, pongPaddleH, 4);

  // 4. Update & Draw Ball
  pongBallX += pongSpeedX;
  pongBallY += pongSpeedY;
  ellipse(pongBallX, pongBallY, pongBallSize, pongBallSize);

  // Top & Bottom wall bounce
  if (pongBallY - pongBallSize / 2 <= 0 || pongBallY + pongBallSize / 2 >= height) {
    pongSpeedY *= -1;
  }

  // Player 1 Paddle collision (Left)
  if (pongBallX - pongBallSize / 2 <= player1X + pongPaddleW &&
      pongBallX + pongBallSize / 2 >= player1X &&
      pongBallY >= player1Y &&
      pongBallY <= player1Y + pongPaddleH &&
      pongSpeedX < 0) {
    pongSpeedX *= -1.05; // Slight speed-up per hit
    float hitOffset = (pongBallY - (player1Y + pongPaddleH / 2)) / (pongPaddleH / 2);
    pongSpeedY = hitOffset * 5;
  }

  // Player 2 Paddle collision (Left)
  if (pongBallX + pongBallSize / 2 >= player2X &&
      pongBallX - pongBallSize / 2 <= player2X + pongPaddleW &&
      pongBallY >= player2Y &&
      pongBallY <= player2Y + pongPaddleH &&
      pongSpeedX > 0) {
    pongSpeedX *= -1.05;
    float hitOffset = (pongBallY - (player2Y + pongPaddleH / 2)) / (pongPaddleH / 2);
    pongSpeedY = hitOffset * 5;
  }

  // 5. Scoring (Left & Right goals)
  if (pongBallX < 0) {
    player2Score++;
    checkPongWin();
    resetPongBall(1); // Serve toward Player 2
  } else if (pongBallX > width) {
    player1Score++;
    checkPongWin();
    resetPongBall(-1); // Serve toward Player 1
  }

  // 6. Scores
  fill(255);
  textSize(32);
  textAlign(CENTER, TOP);
  text(player1Score, width * 0.25, 20);
  text(player2Score, width * 0.75, 20);

}

void checkPongWin() {
  if (player1Score >= winningScore || player2Score >= winningScore) {
    pongGameOver = true;
  }
}

void resetPongBall(int dirX) {
  pongBallX = width / 2;
  pongBallY = height / 2;
  pongSpeedX = 5 * dirX;
  pongSpeedY = random(-3, 3);
}

void resetPongGame() {
  player1Score = 0;
  player2Score = 0;
  pongGameOver = false;
  player1Y = (height - pongPaddleH) / 2;
  player2Y = (height - pongPaddleH) / 2;
  resetPongBall(random(1) > 0.5 ? 1 : -1);
}

void drawPongEndScreen() {
  fill(255);
  textAlign(CENTER, CENTER);
  textSize(32);
  text(player1Score >= winningScore ? "Player 1 WINS!" : "Player 2 WINS!", width / 2, height / 2 - 20);
  textSize(18);
  text("P1: " + player1Score + " - P2: " + player2Score, width / 2, height / 2 + 25);
}
