import processing.sound.*;

int gameState = 0; // 0 = startup, 1 = menu, 2 = story, 3 = instructions, 4 = additional instructions,
// 5 = name entry, 6 = game, 7 = over, 8 = leaderboard
int overPressed = 0;  // 0 = none, 1 = menu, 2 = instructions


Instruction instruction;
Menu menu;
Startup startup;
Story story;

PFont gameFont;
PImage Menu_Main_Middle;
PImage Menu_Main_Button;
PImage general_background;
PImage blank;
PImage alienImg1;
PImage img1;
PImage img2;
PImage img3;
PImage img4;
PImage houseImg;

SoundFile menuMusic;
SoundFile gameMusic;
SoundFile clearLineSound;

String username = "";
boolean enterName = true;
boolean released = true;
boolean firstRun = true;
boolean scoreSaved = false;

String alienText = "";
int alienTextTimer = 0;
int alienTextMaxTime = 0;
boolean outcomePos = false;

void showAlienMessage(String msg) {
  alienText = msg;
  alienTextMaxTime = int(3 * frameRate);
  alienTextTimer = alienTextMaxTime;
}

void drawAlienHUD() {
  if (alienImg1 == null) return;
  if (alienTextTimer <= 0) return;

  float circleX = width/2 - 160;
  float circleY = height - 80;
  float circleR = 60;

  noStroke();
  fill(0, 200, 0);
  ellipse(circleX, circleY, circleR, circleR);

  imageMode(CENTER);
  float sc = min(circleR / alienImg1.width, circleR / alienImg1.height) * 0.9;
  pushMatrix();
  translate(circleX, circleY);
  scale(sc);
  image(alienImg1, 0, 0);
  popMatrix();

  float bubbleX = circleX + circleR/2 + 20;
  float bubbleY = circleY - 35;
  float bubbleW = 260;
  float bubbleH = 70;

  fill(255);
  stroke(0);
  rectMode(CORNER);
  rect(bubbleX, bubbleY, bubbleW, bubbleH, 10);

  fill(0);
  textAlign(LEFT, TOP);
  textSize(14);
  textLeading(18);
  text(alienText, bubbleX + 10, bubbleY + 10, bubbleW - 20, bubbleH - 20);
}

// tetris variables - added cols, rows in case we wont like the box size
int COLS = 10;
int ROWS = 20;
int BLOCK_SIZE = 20;
int GRID_X = 200;
int GRID_Y = 50;

Block[][] grid = new Block[ROWS][COLS];
boolean[][] occupied = new boolean[ROWS][COLS];

Shape currentShape;
Shape nextShape;

int topScore = 0;
int score = 0;
int level = 0;
int linesCleared = 0;
int linesPerLevel = 10;

int fallSpeed = 30;
int fallCounter = 0;

boolean gameInitialized = false;

color[] shapeColors = {
  color(31, 205, 255),
  color(253, 218, 28),
  color(178, 48, 239),
  color(62, 202, 50),
  color(234, 0, 69),
  color(16, 108, 241),
  color(255, 131, 0)
};

class Block {
  int x, y;
  color c;

  Block(int x, int y, color c) {
    this.x = x;
    this.y = y;
    this.c = c;
  }

  void display(int offsetX, int offsetY) {
    fill(c);
    stroke(0);
    strokeWeight(1);
    rect(offsetX + x * BLOCK_SIZE, offsetY + y * BLOCK_SIZE, BLOCK_SIZE, BLOCK_SIZE);
  }

  void displayAt(int px, int py) {
    fill(c);
    stroke(0);
    strokeWeight(1);
    rect(px, py, BLOCK_SIZE, BLOCK_SIZE);
  }
}

class Shape {
  Block[] blocks = new Block[4];
  int[][] coords;
  int type;
  int rotation = 0;
  color shapeColor;
  int centerX, centerY;

  int[][][] tetrominoes = {
    {{0, 1}, {1, 1}, {2, 1}, {3, 1}},
    {{0, 0}, {1, 0}, {0, 1}, {1, 1}},
    {{1, 0}, {0, 1}, {1, 1}, {2, 1}},
    {{1, 0}, {2, 0}, {0, 1}, {1, 1}},
    {{0, 0}, {1, 0}, {1, 1}, {2, 1}},
    {{0, 0}, {0, 1}, {1, 1}, {2, 1}},
    {{2, 0}, {0, 1}, {1, 1}, {2, 1}}
  };

  Shape(int type) {
    this.type = type;
    this.shapeColor = shapeColors[type];
    this.centerX = COLS / 2 - 1;
    this.centerY = 0;

    coords = new int[4][2];
    for (int i = 0; i < 4; i++) {
      coords[i][0] = tetrominoes[type][i][0];
      coords[i][1] = tetrominoes[type][i][1];
    }
    updateBlocks();
  }

  void updateBlocks() {
    for (int i = 0; i < 4; i++) {
      blocks[i] = new Block(centerX + coords[i][0], centerY + coords[i][1], shapeColor);
    }
  }

  void display() {
    for (Block b : blocks) {
      b.display(GRID_X, GRID_Y);
    }
  }

  void displayPreview(int px, int py) {
    for (int i = 0; i < 4; i++) {
      int bx = px + coords[i][0] * 15;
      int by = py + coords[i][1] * 15;
      fill(shapeColor);
      stroke(0);
      rect(bx, by, 15, 15);
    }
  }

  boolean canMove(int dx, int dy) {
    for (Block b : blocks) {
      int newX = b.x + dx;
      int newY = b.y + dy;
      if (newX < 0 || newX >= COLS || newY >= ROWS) return false;
      if (newY >= 0 && occupied[newY][newX]) return false;
    }
    return true;
  }

  void move(int dx, int dy) {
    if (canMove(dx, dy)) {
      centerX += dx;
      centerY += dy;
      updateBlocks();
    }
  }

  void rotate() {
    if (type == 1) return;

    int[][] newCoords = new int[4][2];
    int pivotX = coords[1][0];
    int pivotY = coords[1][1];

    for (int i = 0; i < 4; i++) {
      int x = coords[i][0] - pivotX;
      int y = coords[i][1] - pivotY;
      newCoords[i][0] = -y + pivotX;
      newCoords[i][1] = x + pivotY;
    }

    boolean valid = true;
    for (int i = 0; i < 4; i++) {
      int newX = centerX + newCoords[i][0];
      int newY = centerY + newCoords[i][1];
      if (newX < 0 || newX >= COLS || newY >= ROWS) {
        valid = false;
        break;
      }
      if (newY >= 0 && occupied[newY][newX]) {
        valid = false;
        break;
      }
    }

    if (valid) {
      coords = newCoords;
      updateBlocks();
    }
  }

  void lock() {
    for (Block b : blocks) {
      if (b.y >= 0) {
        grid[b.y][b.x] = new Block(b.x, b.y, b.c);
        occupied[b.y][b.x] = true;
      }
    }
  }
}

void setup() {
  size(600, 600);
  background(0);
  frameRate(60);

  general_background = loadImage("background.png");
  Menu_Main_Middle   = loadImage("Tetris_Main-Screen_evenevenbetter.png");
  Menu_Main_Button   = loadImage("buttonzzz.png");
  blank              = loadImage("Tetris-blank.png");
  alienImg1          = loadImage("Alien1.png");
  img1               = loadImage("img1.png");
  img2               = loadImage("img2.png");
  img3               = loadImage("img3.png");
  img4               = loadImage("img4.png");
  houseImg           = loadImage("House.png");
 
  println("images:", general_background, Menu_Main_Middle, Menu_Main_Button, blank, alienImg1, img1, img2, img3, img4);

  try {
    menuMusic = new SoundFile(this, "music2.mp3");
    gameMusic = new SoundFile(this, "music3.mp3");
    clearLineSound = new SoundFile(this, "clearline1.mp3");
    menuMusic.loop();
  }
  catch (Exception e) {
    println("Error loading sounds: " + e.getMessage());
  }

  gameFont = createFont("PixeloidMono.ttf", 36);
  textFont(gameFont);
  instruction = new Instruction(img1, img2, img3, img4);
  menu       = new Menu(general_background, Menu_Main_Middle, Menu_Main_Button);
  startup    = new Startup();
  story      = new Story(gameFont);
}

void initGame() {
  for (int r = 0; r < ROWS; r++) {
    for (int c = 0; c < COLS; c++) {
      grid[r][c] = null;
      occupied[r][c] = false;
    }
  }

  score = 0;
  level = 0;
  linesCleared = 0;
  fallSpeed = 30;
  fallCounter = 0;

  currentShape = new Shape(int(random(7)));
  nextShape = new Shape(int(random(7)));
  gameInitialized = true;
}

void spawnNewShape() {
  currentShape = nextShape;
  currentShape.centerX = COLS / 2 - 1;
  currentShape.centerY = 0;
  currentShape.updateBlocks();
  nextShape = new Shape(int(random(7)));

  if (!currentShape.canMove(0, 0)) {
    gameState = 7;
    gameInitialized = false;
    if (gameMusic != null) gameMusic.stop();
    if (menuMusic != null) menuMusic.loop();
  }
}

int clearLines() {
  int lines = 0;

  for (int r = ROWS - 1; r >= 0; r--) {
    boolean full = true;
    for (int c = 0; c < COLS; c++) {
      if (!occupied[r][c]) {
        full = false;
        break;
      }
    }

    if (full) {
      lines++;
      if (clearLineSound != null) clearLineSound.play();

      for (int row = r; row > 0; row--) {
        for (int c = 0; c < COLS; c++) {
          grid[row][c] = grid[row-1][c];
          occupied[row][c] = occupied[row-1][c];
          if (grid[row][c] != null) {
            grid[row][c].y = row;
          }
        }
      }
      for (int c = 0; c < COLS; c++) {
        grid[0][c] = null;
        occupied[0][c] = false;
      }
      r++;
    }
  }
  return lines;
}

void updateScore(int lines) {
  int[] points = {0, 40, 100, 300, 1200};
  score += points[lines] * (level + 1);
  linesCleared += lines;

  if (lines == 4) {
    showAlienMessage("Whoa! A perfect Tetris, human!");
  } else if (lines == 3) {
    showAlienMessage("Triple clear! Keep it up.");
  } else if (lines == 2) {
    showAlienMessage("Nice combo, two lines at once.");
  } else if (lines == 1) {
    showAlienMessage("One line down, many to go!");
  }

  if (linesCleared >= (level + 1) * linesPerLevel) {
    level++;
    fallSpeed = max(5, 30 - level * 3);
  }
}

void drawGrid() {
  for (int r = 0; r < ROWS; r++) {
    for (int c = 0; c < COLS; c++) {
      if (grid[r][c] != null) {
        grid[r][c].display(GRID_X, GRID_Y);
      }
    }
  }
}

void handleGameInput() {
  if (key == CODED) {
    if (keyCode == LEFT) {
      currentShape.move(-1, 0);
    } else if (keyCode == RIGHT) {
      currentShape.move(1, 0);
    } else if (keyCode == DOWN) {
      if (currentShape.canMove(0, 1)) {
        currentShape.move(0, 1);
      }
    } else if (keyCode == UP) {
      currentShape.rotate();
    }
  } else if (key == ' ') {
    while (currentShape.canMove(0, 1)) {
      currentShape.move(0, 1);
    }
    currentShape.lock();
    int lines = clearLines();
    if (lines > 0) updateScore(lines);
    spawnNewShape();
  }
}

void mousePressed() {
  float hw = Menu_Main_Button.width/2;
  float hh = Menu_Main_Button.height/2;

  // menu screen button
  if (gameState == 1) {
    if (mouseX > width/2 - hw && mouseX < width/2 + hw &&
        mouseY > (height - height/3) - hh && mouseY < (height - height/3) + hh) {
      released = false;
    }
  }

  // leaderboard exit button
  if (gameState == 8) {
    if (mouseX > width/2 - hw && mouseX < width/2 + hw &&
        mouseY > (height - height/10) - hh && mouseY < (height - height/10) + hh) {
      released = false;
    }
  }

  // over screen: two buttons (menu, instructions)
  if (gameState == 7) {
    float btnY = height - height/5;
    float btnXMenu = width/2 - 120;
    float btnXInstr = width/2 + 120;

    overPressed = 0;

    // menu button pressed
    if (mouseX > btnXMenu - hw && mouseX < btnXMenu + hw &&
        mouseY > btnY - hh && mouseY < btnY + hh) {
      overPressed = 1;
    }

    // instructions button pressed
    if (mouseX > btnXInstr - hw && mouseX < btnXInstr + hw &&
        mouseY > btnY - hh && mouseY < btnY + hh) {
      overPressed = 2;
    }
  }
}

void mouseReleased() {
  float hw = Menu_Main_Button.width/2;
  float hh = Menu_Main_Button.height/2;
  if (gameState == 1) {
    if (mouseX > width/2 - hw && mouseX < width/2 + hw &&
      mouseY > (height - height/3) - hh && mouseY < (height - height/3) + hh) {
      gameState = 8;
      released = true;
    }
  }
  if (gameState == 8) {
    if (mouseX > width/2 - hw && mouseX < width/2 + hw &&
      mouseY > (height - height/10) - hh && mouseY < (height - height/10) + hh) {
      gameState = 1;
      released = true;
    }
  }
if (gameState == 7) {
  float btnY = height - height/5;
  float btnXMenu = width/2 - 120;
  float btnXInstr = width/2 + 120;

  // menu button
  if (mouseX > btnXMenu - hw && mouseX < btnXMenu + hw &&
      mouseY > btnY - hh && mouseY < btnY + hh) {
    gameState = 1;
  }

  // instructions button
  if (mouseX > btnXInstr - hw && mouseX < btnXInstr + hw &&
      mouseY > btnY - hh && mouseY < btnY + hh) {
    gameState = 3;
  }

  overPressed = 0;
}



  released = true;
}

void leaderBoard() {
  Table table = loadTable("Names_scores.csv", "header");
  table.setColumnType(1, Table.INT);
  table.sort(1);

  textAlign(CENTER);
  background(0);
  fill(255);
  textSize(64);
  text("Leaderboard", width/2, 50);

  int rowCount = table.getRowCount();
  int start = rowCount - 1;
  int end = max(0, rowCount - 5);

  int n = 1;
  for (int i = start; i >= end; i--) {
    TableRow row = table.getRow(i);
    String name = row.getString(0);
    int sc = row.getInt(1);
    text(name + ": " + sc, width/2, 50 + 75 * n);
    n++;
  }


  if (released == false) {
    tint(127);
  }
  image(Menu_Main_Button, width/2, height - height/10);
  textSize(50);
  fill(0);
  text("Exit", width/2, height - height/10);
  noTint();
}

void startup() {
  startup.display(this, newState -> gameState = newState);
}

void menu() {
  menu.display(this);
}

void instructions() {
  instruction.displayA(this);
}

void additionalInstructions() {
  instruction.displayB(this);
}

void story() {
  story.display(this);
}

void nameentery() {
  background(0);
  if (enterName) {
    fill(255);
    text("Enter your username:", 300, 290);
    text(username + "|", 300, 310); // for a typing effect
  } else {
    text("Hello, " + username, 300, 310);
  }
}

void keyReleased() {
  if (gameState == 1) {
    if (firstRun) {
      gameState = 2;
    } else {
      gameState = 3;
    }
  } else if (gameState == 2) {
    gameState = 3;
  } else if (gameState == 3) {
    gameState = 4;
  } else if (gameState == 4) {
    if (firstRun) {
      gameState = 5;
    } else {
      startGame();
    }
  }
}

void startGame() {
  if (menuMusic != null) menuMusic.stop();
  if (gameMusic != null) gameMusic.loop();
  gameState = 6;
  scoreSaved = false;
}

void keyPressed() {
  if (gameState == 5 && enterName) {
    if (key == ENTER || key == RETURN) {
      if (username.length() > 0) {
        enterName = false;
        firstRun = false;
        startGame();
      }
    } else if (key == BACKSPACE && username.length() > 0) {
      username = username.substring(0, username.length() - 1);
    } else if (key != CODED) {
      username += key;
    }
  }

  if (gameState == 6 && gameInitialized) {
    handleGameInput();
  }
}

void game() {
  background(125);
  rectMode(CORNER);

  if (!gameInitialized) {
    initGame();
    showAlienMessage("Ready to stack some blocks, human?");
  }

  if (alienTextTimer > 0) {
    alienTextTimer--;
    if (alienTextTimer == 0) {
      alienText = "";
    }
  }

  if (score > topScore) {
    topScore = score;
  }

  fill(0);
  rect(GRID_X, GRID_Y, COLS * BLOCK_SIZE, ROWS * BLOCK_SIZE);

  if (houseImg != null) {
    pushMatrix();
    imageMode(CENTER);

    float boxW = COLS * BLOCK_SIZE;
    float boxH = ROWS * BLOCK_SIZE;

    float targetW = boxW * 0.4;
    float targetH = boxH * 0.2;
    float s = min(targetW / houseImg.width, targetH / houseImg.height);
    float scaledH = houseImg.height * s;

    float cx = GRID_X + boxW / 2.0;
    float cy = GRID_Y + boxH - scaledH / 2.0 - 2;

    translate(cx, cy);
    scale(s);
    tint(255, 160);
    image(houseImg, 0, 0);
    noTint();
    popMatrix();
  }

  fill(0);
  rect(20, 50, 160, 130);
  fill(255);
  textSize(16);
  text("TOP", 75, 75);
  textSize(20);
  text(str(topScore), 60, 100);
  textSize(16);
  text("SCORE", 65, 130);
  textSize(20);
  text(str(score), 60, 155);

  fill(0);
  rect(420, 50, 160, 70);
  fill(255);
  textSize(20);
  text("LEVEL", 470, 70);
  textSize(24);
  text(str(level), 490, 90);

  fill(0);
  rect(420, 140, 160, 70);
  fill(255);
  textSize(16);
  text("NEXT", 480, 155);
  nextShape.displayPreview(450, 170);

  drawGrid();
  currentShape.display();

  boolean danger = false;
  for (int c = 0; c < COLS; c++) {
    if (occupied[15][c]) {
      danger = true;
      break;
    }
  }
  if (danger && alienTextTimer == 0) {
    showAlienMessage("Careful! Your tower is almost touching space!");
  }

  fallCounter++;
  if (fallCounter >= fallSpeed) {
    fallCounter = 0;
    if (currentShape.canMove(0, 1)) {
      currentShape.move(0, 1);
    } else {
      currentShape.lock();
      int lines = clearLines();
      if (lines > 0) updateScore(lines);
      spawnNewShape();
    }
  }

  drawAlienHUD();
  if (score >= 999999) { // ceiling
    score = 999999;
    outcomePos = true;
    gameState = 7;
  }
}

void over() {
  tint(128, 126);
  imageMode(CENTER);
  image(general_background, width/2, height/2);
  noTint();
  image(blank, width/2, height/2, 900, 300);

  textAlign(CENTER);
  textSize(50);
  if (outcomePos == false) {
    fill(234, 0, 69);
    text("Game Over", width/2, 150);
  } else {
    fill(62, 202, 50);
    text("You Win", width/2, 150);
  }
  textSize(40);
  fill(253, 218, 28);
  text("Final Score: " + score, width/2, 250);
  fill(255);

  // save score only once per game
  if (!scoreSaved) {
    Table table = loadTable("Names_scores.csv", "header");
    table.setColumnType(1, Table.INT);

    TableRow newrow = table.addRow();
    newrow.setString(0, username);
    newrow.setInt(1, score);

    table.sort(1);
    saveTable(table, "data/Names_scores.csv");
    scoreSaved = true;
  }

  // display top 5 scores
  Table table = loadTable("Names_scores.csv", "header");
  table.setColumnType(1, Table.INT);
  table.sort(1);

  textAlign(CENTER);
  fill(255);
  textSize(20);

  int rowCount = table.getRowCount();
  int start = rowCount - 1;
  int end = max(0, rowCount - 5);

  int n = 0;
  for (int i = start; i >= end; i--) {
    TableRow row = table.getRow(i);
    String name = row.getString(0);
    int s = row.getInt(1);
    float y = 275 + 30 * n;
    text(name + " " + s, width/2, y);
    n++;
  }

// buttons
textSize(30);
float btnY = height - height/5;
float btnXMenu = width/2 - 120;
float btnXInstr = width/2 + 120;

// menu button
if (overPressed == 1) tint(128);
else noTint();
image(Menu_Main_Button, btnXMenu, btnY);

// instructions button
if (overPressed == 2) tint(128);
else noTint();
image(Menu_Main_Button, btnXInstr, btnY);

noTint();
fill(0);
text("Menu", btnXMenu, btnY);
textSize(20);
text("Instructions", btnXInstr, btnY - 5);
}

void draw() {
  if (gameState == 0) {
    startup.display(this, newState -> gameState = newState);
  } else if (gameState == 1) {
    menu.display(this);
  } else if (gameState == 2) {
    story.display(this);
  } else if (gameState == 3) {
    instruction.displayA(this);
  } else if (gameState == 4) {
    instruction.displayB(this);
  } else if (gameState == 5) {
    nameentery();
  } else if (gameState == 6) {
    game();
  } else if (gameState == 7) {
    over();
  } else if (gameState == 8) {
    leaderBoard();
  }
}
