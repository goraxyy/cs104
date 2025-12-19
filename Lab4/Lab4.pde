import processing.sound.*; // sound library

PImage appleImg; // apple iamge

// sound files
SoundFile turnSound;
SoundFile eatSound;
SoundFile collisionSound;

// variables
int gameState = 0; // 0 = menu; 1 = game; 2 = lose
int dif;
int gridX;
int gridY;
int score;
int frameCounter = 0;
int speed;

Snake snake;
int[] apple = new int[2];
int dirX = 1;
int dirY = 0;

void setup() {
  size(550, 625); // optimal = 550x625
  noStroke();
  appleImg = loadImage("apple.png");
  turnSound = new SoundFile(this, "turn.mp3");
  eatSound = new SoundFile(this, "eat.mp3");
  collisionSound = new SoundFile(this, "collision.mp3");
}

void backGround() { // done
  background(86, 138, 52);
  rectMode(CORNERS);
  fill(74, 117, 44);
  rect(0, 0, width, 75);

  gridY = 125;
  rectMode(CENTER);
  for (int i = 1; i <= 10; i++) {
    gridX = width / 2 - 225;
    for (int j = 1; j <= 10; j++) {
      if ((i + j) % 2 == 0) fill(170, 215, 80);
      else fill(162, 209, 72);
      rect(gridX, gridY, 50, 50);
      gridX += 50;
    }
    gridY += 50;
  }
}

void menu() { // done
  backGround();

  // tint
  fill(0, 0, 0, 150);
  rectMode(CORNERS);
  rect(0, 0, width, height);

  // instructions box
  rectMode(CENTER);
  fill(77, 193, 249);
  rect(width / 2, 252, 200, 100, 10);
  fill(255);
  textSize(15);
  textAlign(LEFT, CENTER);
  text("Instructions\n1) Press arrow keys to move\n2) Eat apples to grow\n3) Don't hit yourself \n     or the walls!", width / 2 - 90, 252);

  // difficulty buttons
  fill(142, 204, 58);
  rect(width / 2 - 70, 337, 60, 50, 10);
  fill(254, 191, 0);
  rect(width / 2, 337, 60, 50, 10);
  fill(231, 70, 29);
  rect(width / 2 + 70, 337, 60, 50, 10);

  // play button
  textAlign(CENTER, CENTER);
  fill(18, 85, 204);
  rect(width / 2, 397, 200, 50, 10);
  fill(255);
  textSize(20);
  text("Play", width / 2, 397);

  if (mousePressed) {
    // play button
    if (mouseX > width/2 - 100 && mouseX < width/2 + 100 && mouseY > 372 && mouseY < 422) {
      initGame();
      gameState = 1;
      delay(200); // so that it doesn't immediately re-click
    }
    // easy button
    if (mouseX > width/2 - 100 && mouseX < width/2 - 40 && mouseY > 312 && mouseY < 362) {
      dif = 1;
      delay(200);
    }
    // medium button
    if (mouseX > width/2 - 30 && mouseX < width/2 + 30 && mouseY > 312 && mouseY < 362) {
      dif = 2;
      delay(200);
    }
    // hard button
    if (mouseX > width/2 + 40 && mouseX < width/2 + 100 && mouseY > 312 && mouseY < 362) {
      dif = 3;
      delay(200);
    }
  }
}

void initGame() { // odne
  snake = new Snake();
  dirX = 1;
  dirY = 0;
  score = 0;
  frameCounter = 0;

  //speed based on difficulty
  if (dif == 1) speed = 32;
  else if (dif == 2) speed =16;
  else speed = 8;

  generateApple();
}

void generateApple() {
  boolean valid = false;
  while (!valid) {
    apple[0] = int(random(10));
    apple[1] = int(random(10));
    valid = true;
    // if apple is on snake
    for (int i = 0; i < snake.body.size(); i++) {
      int[] segment = snake.body.get(i);
      if (segment[0] == apple[0] && segment[1] == apple[1]) {
        valid = false;
        break;
      }
    }
  }
}

class Snake { // semi done
  ArrayList<int[]> body;

  Snake() {
    body = new ArrayList<int[]>();
    body.add(new int[]{5, 5});
    body.add(new int[]{4, 5});
    body.add(new int[]{3, 5});
  }

  void update() {
    int[] head = body.get(0);
    int[] newHead = new int[]{head[0] + dirX, head[1] + dirY};

    // wall collision
    if (newHead[0] < 0 || newHead[0] >= 10 || newHead[1] < 0 || newHead[1] >= 10) {
      collisionSound.play();
      gameState = 2;
      return; // to stop
    }

    // self collision
    for (int i = 0; i < body.size(); i++) {
      int[] segment = body.get(i);
      if (newHead[0] == segment[0] && newHead[1] == segment[1]) {
        collisionSound.play();
        gameState = 2;
        return;
      }
    }

    body.add(0, newHead);

    // apple collision
    if (newHead[0] == apple[0] && newHead[1] == apple[1]) {
      score++;
      eatSound.play();
      generateApple();
    } else {
      body.remove(body.size() - 1);
    }
  }


  void display() { // i know how the design looks, how the tail and the head are not attached to the body
    int[] head = body.get(0);
    float distToApple = dist(head[0], head[1], apple[0], apple[1]);
    boolean showTongue = distToApple <= 3;

    // draw body segments
    for (int i = 1; i < body.size() - 1; i++) {
      int[] segment = body.get(i);
      float x = width / 2 - 225 + segment[0] * 50;
      float y = 125 + segment[1] * 50;

      fill(50, 100, 200);
      rectMode(CENTER);
      rect(x, y, 50, 50);
    }

    // draw tail (half square on opposite side from body connection)
    if (body.size() > 1) {
      int[] tail = body.get(body.size() - 1);
      int[] beforeTail = body.get(body.size() - 2);
      float x = width / 2 - 225 + tail[0] * 50;
      float y = 125 + tail[1] * 50;

      fill(30, 70, 150);

      // draw tail as half square on far side from connection
      if (tail[0] < beforeTail[0]) { // body is to the right, draw left half
        rectMode(CORNER);
        rect(x - 25, y - 25, 25, 50);
      } else if (tail[0] > beforeTail[0]) { // body is to the left, draw right half
        rectMode(CORNER);
        rect(x, y - 25, 25, 50);
      } else if (tail[1] < beforeTail[1]) { // body is below, draw top half
        rectMode(CORNER);
        rect(x - 25, y - 25, 50, 25);
      } else { // body is above, draw bottom half
        rectMode(CORNER);
        rect(x - 25, y, 50, 25);
      }
    }

    // draw head (half square on far side from body)
    int[] neck = body.size() > 1 ? body.get(1) : head;
    float headX = width / 2 - 225 + head[0] * 50;
    float headY = 125 + head[1] * 50;

    fill(70, 120, 220);

    // draw head as half square on far side from neck
    if (head[0] > neck[0]) { // moving right, draw right half
      rectMode(CORNER);
      rect(headX, headY - 25, 25, 50);

      // eyes
      fill(255);
      ellipse(headX + 15, headY - 10, 15, 15);
      ellipse(headX + 15, headY + 10, 15, 15);
      fill(18, 63, 167);
      ellipse(headX + 16, headY - 10, 7, 7);
      ellipse(headX + 16, headY + 10, 7, 7);

      // tongue
      if (showTongue) {
        stroke(200, 50, 50);
        strokeWeight(2);
        line(headX + 25, headY - 3, headX + 35, headY - 5);
        line(headX + 25, headY + 3, headX + 35, headY + 5);
        noStroke();
      }
    } else if (head[0] < neck[0]) { // moving left, draw left half
      rectMode(CORNER);
      rect(headX - 25, headY - 25, 25, 50);

      // eyes
      fill(255);
      ellipse(headX - 15, headY - 10, 15, 15);
      ellipse(headX - 15, headY + 10, 15, 15);
      fill(18, 63, 167);
      ellipse(headX - 16, headY - 10, 7, 7);
      ellipse(headX - 16, headY + 10, 7, 7);
      // tongue
      if (showTongue) {
        stroke(200, 50, 50);
        strokeWeight(2);
        line(headX - 25, headY - 3, headX - 35, headY - 5);
        line(headX - 25, headY + 3, headX - 35, headY + 5);
        noStroke();
      }
    } else if (head[1] > neck[1]) { // moving down, draw bottom half
      rectMode(CORNER);
      rect(headX - 25, headY, 50, 25);

      // eyes
      fill(255);
      ellipse(headX - 10, headY + 15, 15, 15);
      ellipse(headX + 10, headY + 15, 15, 15);
      fill(18, 63, 167);
      ellipse(headX - 10, headY + 16, 7, 7);
      ellipse(headX + 10, headY + 16, 7, 7);

      // tongue
      if (showTongue) {
        stroke(200, 50, 50);
        strokeWeight(2);
        line(headX - 3, headY + 25, headX - 5, headY + 35);
        line(headX + 3, headY + 25, headX + 5, headY + 35);
        noStroke();
      }
    } else { // moving up, draw top half
      rectMode(CORNER);
      rect(headX - 25, headY - 25, 50, 25);

      // eyes
      fill(255);
      ellipse(headX - 10, headY - 15, 15, 15);
      ellipse(headX + 10, headY - 15, 15, 15);
      fill(18, 63, 167);
      ellipse(headX - 10, headY - 16, 7, 7);
      ellipse(headX + 10, headY - 16, 7, 7);
      // tongue
      if (showTongue) {
        stroke(200, 50, 50);
        strokeWeight(2);
        line(headX - 3, headY - 25, headX - 5, headY - 35);
        line(headX + 3, headY - 25, headX + 5, headY - 35);
        noStroke();
      }
    }
  }
}

void play() { // finally done
  backGround();

  // update snake
  frameCounter++;
  if (frameCounter >= speed) {
    snake.update();
    frameCounter = 0;
  }

  // draw apple
  float appleX = width / 2 - 225 + apple[0] * 50;
  float appleY = 125 + apple[1] * 50;

  imageMode(CENTER);
  image(appleImg, appleX, appleY, 40, 40);

  // draw snake
  snake.display();

  // draw score
  fill(255);
  textSize(24);
  textAlign(LEFT, CENTER);
  text("Score: " + score, 20, 40);
}

void lose() { // done
  backGround();

  // tint
  fill(0, 0, 0, 150);
  rectMode(CORNERS);
  rect(0, 0, width, height);

  rectMode(CENTER);
  fill(254, 191, 0);
  rect(width / 2, 342, 200, 50, 10);

  fill(231, 70, 29);
  textSize(35);
  textAlign(CENTER, CENTER);
  text("Game Over", width / 2, 252);

  fill(255);
  textSize(24);
  text("Score: " + score, width / 2, 292);

  textSize(20);
  text("Menu", width / 2, 342);

  if (mousePressed) {
    // menu button
    if (mouseX > width/2 - 100 && mouseX < width/2 + 100 && mouseY > 317 && mouseY < 367) {
      gameState = 0;
      delay(200);
    }
  }
}

void keyPressed() { // controls
  if (gameState == 1) {
    if (keyCode == UP && dirY != 1) {
      dirX = 0;
      dirY = -1;
      turnSound.play();
    } else if (keyCode == DOWN && dirY != -1) {
      dirX = 0;
      dirY = 1;
      turnSound.play();
    } else if (keyCode == LEFT && dirX != 1) {
      dirX = -1;
      dirY = 0;
      turnSound.play();
    } else if (keyCode == RIGHT && dirX != -1) {
      dirX = 1;
      dirY = 0;
      turnSound.play();
    }
  }
}

void draw() { // done
  if (gameState == 0) {
    menu();
  }
  if (gameState == 1) {
    play();
  }
  if (gameState == 2) {
    lose();
  }
}

// BUGs:
// 1) if turn twice quickly, snake will either self-collide or keep its direction
// 2) not a direct bug, but the sounds could have been picked better; more accurate to the original google snake game
// 3) sounds are sort of delayed
