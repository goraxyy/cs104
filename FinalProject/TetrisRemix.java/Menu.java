import processing.core.PApplet;
import processing.core.PImage;

public class Menu {
  private boolean released = true;
  private PImage generalBackground;
  private PImage mainMiddle;
  private PImage mainButton;

  public Menu(PImage generalBackground, PImage mainMiddle, PImage mainButton) {
    this.generalBackground = generalBackground;
    this.mainMiddle = mainMiddle;
    this.mainButton = mainButton;
  }

  // allow the main sketch to change released
  public void setReleased(boolean released) {
    this.released = released;
  }

  public void display(PApplet applet) {
    applet.background(125);
    applet.imageMode(PApplet.CENTER);
    applet.image(generalBackground, applet.width / 2f, applet.height / 2f);
    applet.image(mainMiddle, applet.width / 2f, applet.height / 2f);
    applet.fill(255);
    applet.textSize(19);
    applet.textAlign(PApplet.CENTER);
    applet.text("Press any button\n to start", applet.width / 2f, applet.height / 2f);
    applet.textSize(15);
    applet.text("CS-104 Final Project Fall 2025", applet.width / 2f, applet.height - 20f);
    applet.text("Made by Justice L, Michael W, and Ali K.", applet.width / 2f, applet.height - 5f);
    if (!released) {
      applet.tint(127);
    }
    applet.image(mainButton, applet.width / 2f, applet.height - applet.height / 3f);
    applet.fill(0);
    applet.text("leaderboard", applet.width / 2f, applet.height - applet.height / 3f - 10);
    applet.noTint();
  }
}
