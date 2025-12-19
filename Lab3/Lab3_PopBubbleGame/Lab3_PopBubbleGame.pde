int score = 0;
int gameState;
float exitX;
float exitY;
int exitCount = 0;

int speedBoost;

ArrayList<Bubble> bubbles;

void setup() {
  size(500, 800);
  gameState = 0;
  exitX = width / 2;
  exitY = height / 2 + 50;
}

void resetGame() {
  score = 0;
  speedBoost = 0;
  bubbles = new ArrayList<Bubble>();

  // spawn at least 5 bubbles
  for (int i = 0; i < 5; i++) {
    bubbles.add(new Bubble());
  }
}

// Clouds background effect
void backGround(){
  background(190, 210, 250);
  noStroke();
  
  fill(235, 235, 255);
  for(int i = 10; i < height; i += 10){
    ellipse(60, i, random(30, 60), random(30, 60));
  }
  for(int i = 10; i < height; i += 10){
    ellipse(width - 60, i, random(30, 60), random(30, 60));
  }
  
  fill(255);
  for(int i = 10; i < height; i += 10){
    ellipse(20, i, random(30, 60), random(30, 60));
  }
  for(int i = 10; i < height; i += 10){
    ellipse(width - 20, i, random(30, 60), random(30, 60));
  }
}

void startPage() {
  background(240);
  textAlign(CENTER, CENTER);
  textSize(18);
  fill(200, 100, 255);
  text("Pop as many bubbles as you can", width / 2, height / 2 - 80);
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
      if(exitCount == 9){ // Trick feature: repeatedly clicking "quit" will close the game after 10 attempts
        super.exit();} // Overlay of 2 buttons will lead to start of the game
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

class Bubble {
  float bubbleSize = random(30, 50);
  float bubbleX = random(bubbleSize, width - bubbleSize);
  float bubbleY = height + bubbleSize;
  float bubbleSpeed = 2;
  float bubbleR = random(50, 255);
  float bubbleG = random(50, 255);
  float bubbleB = random(50, 255);
  
  // Movement
  void move() {
    bubbleY -= bubbleSpeed + speedBoost;
    bubbleX += random(-1.5, 1.5); // Jitter
  }
  
  // Showing
  void display() {
    stroke(0);
    fill(bubbleR, bubbleG, bubbleB, 120);
    ellipse(bubbleX, bubbleY, bubbleSize, bubbleSize);
  }
  
  // Pop check
  boolean isIn(float mx, float my) {
    return dist(mx, my, bubbleX, bubbleY) < bubbleSize/2; // find the distance using pythaggorean theorem and check if it is less than a size of a bubble
  }
  
  //Pass check
  boolean isOffScreen() {
    return bubbleY + bubbleSize < 0;
  }
}

void gamePage() {
  backGround();
  
  // Score
  fill(0);
  textAlign(LEFT, TOP);
  textSize(20);
  text("Score: " + score, 10, 10);
  
  // Update all bubbles
  for (int i = bubbles.size()-1; i >= 0; i--) { // Backwards because it will skip one if it was otherwise
    Bubble b = bubbles.get(i);
    b.move();
    b.display();
    
    if (mousePressed && b.isIn(mouseX, mouseY)) {
      score++;
      speedBoost += 1;
      bubbles.remove(i);          // Remove popped bubble
      bubbles.add(new Bubble());  // Respawn
    }
    
    // Missed bubble
    else if (b.isOffScreen()) {
      score--;
      speedBoost -= 1;
      bubbles.remove(i);
      bubbles.add(new Bubble()); // Respawn
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
