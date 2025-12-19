import processing.core.PApplet;
import processing.core.PImage;

public class Instruction {
  private PImage img1;
  private PImage img2;
  private PImage img3;
  private PImage img4;

  public Instruction(PImage img1, PImage img2, PImage img3, PImage img4) {
    this.img1= img1;
    this.img2= img2;
    this.img3= img3;
    this.img4= img4;
  }

  public void displayA(PApplet applet) {
    applet.background(44, 0, 142);
    applet.rectMode(PApplet.CORNER);
    applet.fill(0);
    applet.rect(40, 40, 520, 520);
    applet.fill(255);
    applet.textAlign(PApplet.CENTER);
    applet.textSize(19);
    applet.text("Use the Left Arrow and Right Arrow keys\n to move the blocks left and right.", applet.width / 2f, 100);
    applet.text("Use the Up Arrow key to rotate\n the blocks  clockwise.", applet.width / 2f, 180);
    applet.text("Press the Down Arrow key\n to quickly move the block downwards \n or Space key to immediately drop.", applet.width / 2f, 260);
    applet.text("Reach a score \n of 999999 to get rid\n of the alien for good.", applet.width / 2f, 340);
    applet.text("Press the Space key to Continue.", applet.width / 2f, 440);
    applet.text("Press the Enter key to see\n additional instuctions.", applet.width / 2f, 480);
  }

  public void displayB(PApplet applet) {
    applet.background(44, 0, 142);
    applet.rectMode(PApplet.CORNER);
    applet.fill(0);
    applet.rect(40, 40, 520, 520);
    applet.fill(255);
    applet.imageMode(PApplet.CORNER);
    applet.image(img1, 40, 40, 200, 200);
    applet.image(img2, 360, 40, 200, 200);
    applet.image(img3, 40, 280, 200, 200);
    applet.image(img1, 360, 280, 200, 200);
    applet.textSize(20);
    applet.text("Rotate", applet.width / 2f, 200);
    applet.text("Line\n Clear", applet.width / 2f, 400);
    applet.fill(255);
    applet.textAlign(PApplet.CENTER);
    applet.textSize(19);
    applet.text("Press the Space key to Continue.", applet.width / 2f, 520);
  }
}
