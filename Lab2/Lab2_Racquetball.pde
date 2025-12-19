int ellipseX;
int ellipseY;
int ellipseXSpeed;
int ellipseYSpeed;
int ellipseSpeedChoice = 3;
float ellipseR;
float ellipseG;
float ellipseB;
float startSide;

int paddleLength;
float paddleX;
float paddleTop;
float paddleBottom;
float paddleLeft;
float paddleRight;

int points = 0;
int gameState = 0; // Game state: 0 = settings, 1 = play, 2 = end

void setup() {
  // Main settings
  size(640, 360);
  frameRate(30);
  background(50);
  smooth();
  
  // Ellipse position
  ellipseX = (int) random(11, 630);
  ellipseY = 10;
  
  // Ellipse movement
  ellipseXSpeed = ellipseSpeedChoice;
  ellipseYSpeed = ellipseSpeedChoice;
  startSide = random(1);
  if(startSide > 0.5){
    ellipseXSpeed *= -1; 
  } 
}

void resetGame() {
  // Reset points 
  points = 0;
  
  // Reset ellipse position
  ellipseX = (int) random(11, 630);
  ellipseY = 10;
  
  // Reset ellipse movement
  ellipseXSpeed = ellipseSpeedChoice;
  ellipseYSpeed = ellipseSpeedChoice;
  startSide = random(1);
  if (startSide > 0.5) {
    ellipseXSpeed *= -1; 
  }
}

void difficultyScreen(){
  // Text
  background(50);
  noStroke();
  textAlign(CENTER, CENTER);
  textSize(17);
  fill(200);
  text("Bounce the ball with your mouse paddle and score as many points as you can!", width / 2, height / 2 - 15);
  text("Choose the size of the paddle (*bigger paddle = faster ball)", width / 2, height / 2 + 10);
  rectMode(CENTER);
  rect(width / 2 - 150, height / 2 + 50, 100, 40);
  rect(width / 2, height / 2 + 50, 100, 40);
  rect(width / 2 + 150, height / 2 + 50, 100, 40);
  textSize(30);
  fill(255, 0, 0);
  text("100", width / 2 - 150, height / 2 + 50);
  fill(240, 240, 100);
  text("200", width / 2, height / 2 + 50);
  fill(0, 130, 0);
  text("300", width / 2 + 150, height / 2 + 50);
  
  // Mouse press
  if(mousePressed){
    if(mouseY >= height / 2 + 30 && mouseY <= height / 2 + 70){
      // Difficulty 100
      if(mouseX >= width / 2 - 200 && mouseX <= width / 2 - 100){
        paddleLength = 100;
        resetGame();
        gameState = 1;
      }
      // Difficulty 200
      if(mouseX >= width / 2 - 50 && mouseX <= width / 2 + 50){
        paddleLength = 200;
        ellipseSpeedChoice += 1;
        resetGame();
        gameState = 1;
      }
      // Difficulty 300
      if(mouseX >= width / 2 + 100 && mouseX <= width / 2 + 200){
        paddleLength = 300;
        ellipseSpeedChoice += 2;
        resetGame();
        gameState = 1;
      }
    }
  }
}

void playGame() {
  // "Crazy Rainbow Ball"
  if(mousePressed == false){
     background(50);
   }
   
  // Points score
  textSize(25);
  fill(98,119,216);
  text("Points: " + points, 530, 40);
  
  // Ellipse
  fill(ellipseR, ellipseG, ellipseB);
  ellipse(ellipseX, ellipseY, 20, 20);
  
  // Paddle
  rectMode(CENTER);
  paddleX = constrain(mouseX, paddleLength/2, width - paddleLength/2);
  fill(255);
  rect(paddleX, height - 40, paddleLength, 20);
  
  // Random color of the ellipse
  ellipseR = random(256);
  ellipseG = random(256);
  ellipseB = random(256);
  
  // Constant movement of the ellipse
  ellipseX += ellipseXSpeed;
  ellipseY += ellipseYSpeed;
  
  // Bouncing from the walls
  if(ellipseX <= 10 || ellipseX >= width - 10) {
    ellipseXSpeed *= -1;
  }

  // Bouncing from the ceiling
  if(ellipseY <= 10){
    ellipseYSpeed *= -1;
  }
  
  // Paddle collision
  paddleTop = height - 50;
  paddleBottom = height - 30;
  paddleLeft = paddleX - paddleLength/2;
  paddleRight = paddleX + paddleLength/2;

  // Bouncing from the paddle
  if(ellipseY + 10 >= paddleTop && ellipseY - 10 <= paddleBottom && ellipseX + 10 >= paddleLeft && ellipseX - 10 <= paddleRight) {
    ellipseYSpeed *= -1;
    points++;
    ellipseY = (int)paddleTop - 10; // Placing the ball just above paddle, so it won't stick
    
    // Speed up
    if (ellipseXSpeed > 0) ellipseXSpeed++;
    else ellipseXSpeed--;
    if (ellipseYSpeed > 0) ellipseYSpeed++;
    else ellipseYSpeed--;
  }
  
  // Game over
  if(ellipseY > height) {
    gameState = 2;
  }
}

void endScreen(){
  // Text
  background(50);
  textAlign(CENTER, CENTER);
  textSize(32);
  fill(255, 80, 80);
  text("Game Over", width/2, height/2 - 20);
  textSize(20);
  fill(200);
  text("Press any key to start over", width/2, height/2 + 20);
  
  // Key press
  if(keyPressed){
    resetGame();
    gameState = 1;
  }
}

void draw(){
  if(gameState == 0){
    difficultyScreen();
  } else if (gameState == 1) {
    playGame();
  } else if (gameState == 2) {
    endScreen();
  }
}
