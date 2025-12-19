int score = 0;
int gameState;
float exitX;
float exitY;
int exitCount = 0;

int speedBoost;

ArrayList<Square> squares;

void setup() {
  size(700, 500);
  gameState = 0;
  exitX = width / 2;
  exitY = height / 2 + 50;
}

void resetGame() {
  score = 0;
  speedBoost = 0;
  squares = new ArrayList<Square>();

  // Spawn at least 5 bubbles
  for (int i = 0; i < 5; i++) {
    squares.add(new Square());
  }
}

// Clouds background effect
void backGround() {
  background(255, 70, 70);
  noStroke();

  fill(255, 140, 140);
  for (int i = 10; i < width; i += 10) {
    ellipse(i, 50, random(30, 60), random(30, 60));
  }
  for (int i = 10; i < width; i += 10) {
    ellipse(i, height - 50, random(30, 60), random(30, 60));
  }

  fill(255);
  for (int i = 10; i < width; i += 10) {
    ellipse(i, 15, random(30, 60), random(30, 60));
  }
  for (int i = 10; i < width; i += 10) {
    ellipse(i, height - 15, random(30, 60), random(30, 60));
  }
}

void startPage() {
  background(240);
  textAlign(CENTER, CENTER);
  textSize(18);
  fill(200, 100, 255);
  text("Catch as many squares as you can", width / 2, height / 2 - 80);
  text("and let as few escape as possible", width / 2, height / 2 - 50);

  // Start button
  textSize(30);
  rectMode(CENTER);
  fill(200, 200, 50);
  rect(width / 2, height / 2, 200, 50);
  fill(255);
  text("Good boy", width / 2, height / 2);

  // Exit button
  textSize(15);
  fill(205, 50, 50);
  rect(exitX, exitY, 100, 25);
  fill(255);
  text("Bad boy", exitX, exitY);

  // Mouse press
  if (mousePressed) {
    if (mouseX >= exitX - 50 && mouseX <= exitX + 50
      && mouseY >= exitY - 12 && mouseY <= exitY + 12) {
      if (exitCount == 9) { // Trick feature: repeatedly clicking "quit" will close the game after 10 attempts
        super.exit();
      } // Overlay of 2 buttons will lead to start of the game
      else {
        exitX = random(50, width - 50);
        exitY = random(50, height - 50);
        exitCount++;
      }
    }
    if (mouseX >= width / 2 - 100 && mouseX <= width / 2 + 100
      && mouseY >= height / 2 - 25 && mouseY <= height / 2 + 25) {
      resetGame();
      gameState = 1;
    }
  }
}

void paddleDisplay() {
  rectMode(CENTER);
  fill(0);
  rect(width - 30, mouseY, 20, 100);
}

class Square {
  // Setting variables
  float squareSize = random(30, 50);
  float squareX = random(-squareSize, 100); // made it 100 to randomize
  float squareY = random(squareSize, height - squareSize);
  float squareSpeed = random(2, 4); // made it vary to randomize
  float squareR = random(50, 255);
  float squareG = random(50, 255);
  float squareB = random(50, 255);

  // Movement
  void move() {
    squareX += squareSpeed + speedBoost;
  }

  // Showing
  void display() {
    stroke(0);
    fill(squareR, squareG, squareB, 120);
    rectMode(CENTER);
    rect(squareX, squareY, squareSize, squareSize);
  }

  // Paddle-collision check
  boolean hitsPaddle(float paddleX, float paddleY, float paddleW, float paddleH) {
    return (squareX + squareSize/2 > paddleX - paddleW/2 &&
      squareX - squareSize/2 < paddleX + paddleW/2 &&
      squareY + squareSize/2 > paddleY - paddleH/2 &&
      squareY - squareSize/2 < paddleY + paddleH/2);
  }

  // Pass check
  boolean isOffScreen() {
    return squareX - squareSize > width;
  }
}

void gamePage() {
  backGround();

  float paddleX = width - 30;
  float paddleY = mouseY;
  float paddleW = 20;
  float paddleH = 100;

  paddleDisplay();

  // Score
  fill(0);
  textAlign(LEFT, TOP);
  textSize(20);
  text("Score: " + score, 10, 10);

  for (int i = squares.size()-1; i >= 0; i--) {
    Square s = squares.get(i);
    s.move();
    s.display();

    // Paddle hit
    if (s.hitsPaddle(paddleX, paddleY, paddleW, paddleH)) {
      score++;
      speedBoost += 1;
      squares.remove(i);
      squares.add(new Square()); // Respawn
    }

    // Missed square
    else if (s.isOffScreen()) {
      score--;
      speedBoost -= 1;
      squares.remove(i);
      squares.add(new Square()); // Respawn
    }
  }

  if (score < 0) {
    gameState = 2;
  }
}

void endPage() {
  background(255);
  textAlign(CENTER, CENTER);
  textSize(32);
  fill(255, 80, 80);
  text("Game Over", width/2, height/2 - 20);
  textSize(20);
  fill(200, 100, 255);
  text("Press any key to start over", width/2, height/2 + 20);

  if (keyPressed) {
    resetGame();
    gameState = 1;
  }
}

void draw() {
  if (gameState == 0) {
    startPage();
  } else if (gameState == 1) {
    gamePage();
  } else {
    endPage();
  }
}
