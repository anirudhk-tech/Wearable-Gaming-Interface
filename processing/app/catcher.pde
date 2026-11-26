int padX, itemX, itemY, catchScore, hearts, catchBest;
boolean ballFall = true;

void catchStart() {
  padX = 260;
  itemX = int(random(20, 580));
  itemY = int(random(100, 580));
  catchScore = 0;
  hearts = 3;
}
/**/
void catchKey(char k) {
  if (hearts == 0) {
    catchStart();
    return;
  }
  if (k == 'a') padX = max(0, padX - 40);
  if (k == 'd') padX = min(mw - 80, padX + 40);
}

void catchDraw() {
  if (hearts > 0) {
    if(ballFall == true){
      itemY += 3 + catchScore / 10;
    }else if(ballFall == false){
      itemY -= 3 + catchScore / 10;
    }
    if (itemY >= mh - 20) {
      if (itemX > padX && itemX < padX + 80){
        catchScore++;
        ballFall = !ballFall;
      }else{
        hearts--;
      }
      itemX = int(random(20, 580));
      itemY = 0;
      if (hearts == 0 && catchScore > catchBest) catchBest = catchScore;
    }
  }

  fill(255, 150, 0);
  noStroke();
  ellipse(itemX, itemY, 20, 20);
  fill(0);
  rect(padX, mh - 20, 80, 10);

  textSize(16);
  text("Score: " + catchScore + "   hearts: " + hearts, 10, 20);
  if (hearts == 0) {
    textSize(30);
    text("Game over - tilt to restart", 150, 200);
  }
}
