import processing.core.PApplet; // JAM because J - Justice, A - Ali, M - Michael

public class Startup {

    private int yTitle = -50;
    private int xTitle1 = 0;
    private int xTitle2 = 0;
    private int rise = 0;

    private boolean released = true;

    public Startup() {
    }

    public void setReleased(boolean released) {
        this.released = released;
    }

    public void display(PApplet applet, GameStateHolder stateHolder) {
        int fall = 3;
        int slide = 5;

        boolean yes = false;
        applet.background(0);
        applet.fill(255);
        applet.textAlign(PApplet.CENTER);
        applet.textSize(80);

        applet.fill(191, 64, 191);
        if (yTitle <= applet.height / 2f)
            applet.text("J", applet.width / 2f - 50, yTitle);
        else
            applet.text("J", applet.width / 2f - 50, applet.height / 2f);

        if (yTitle - 100 <= applet.height / 2f)
            applet.text("A", applet.width / 2f, yTitle - 100);
        else
            applet.text("A", applet.width / 2f, applet.height / 2f);

        if (yTitle - 200 <= applet.height / 2f)
            applet.text("M", applet.width / 2f + 60, yTitle - 200);
        else {
            applet.text("M", applet.width / 2f + 60, applet.height / 2f);
            yes = true;
        }

        yTitle += fall;

        if (yes) {
            applet.frameRate(60);
            applet.noStroke();
            applet.fill(117, 0, 0);

            if (xTitle1 > applet.width) {
                if (rise <= 100) {
                    applet.frameRate(10);
                    applet.rect(0, applet.height / 2f + 30, applet.width, -rise);
                    rise += 3;
                    applet.fill(232, 225, 162);
                    applet.rect(applet.width, applet.height / 2f - 70, -applet.width, -10);
                    applet.rect(0, applet.height / 2f + 30, applet.width, 10);

                    applet.fill(191, 64, 191);
                    applet.text("J", applet.width / 2f - 50, applet.height / 2f);
                    applet.text("A", applet.width / 2f, applet.height / 2f);
                    applet.text("M", applet.width / 2f + 60, applet.height / 2f);
                } else {
                    applet.rect(0, applet.height / 2f + 30, applet.width, -100);
                    applet.fill(232, 225, 162);
                    applet.rect(applet.width, applet.height / 2f - 70, -applet.width, -10);
                    applet.rect(0, applet.height / 2f + 30, applet.width, 10);

                    applet.fill(191, 64, 191);
                    applet.text("J", applet.width / 2f - 50, applet.height / 2f);
                    applet.text("A", applet.width / 2f, applet.height / 2f);
                    applet.text("M", applet.width / 2f + 60, applet.height / 2f);

                    // instead of directly using global gameState, we used small holder class
                    stateHolder.setGameState(1);
                }
            }

            applet.fill(232, 225, 162);
            if (xTitle2 <= applet.width) {
                applet.rect(applet.width, applet.height / 2f - 70, -xTitle2, -10);
                xTitle2 += slide;
            }

            if (xTitle1 <= applet.width) {
                applet.rect(0, applet.height / 2f + 30, xTitle1, 10);
                xTitle1 += slide;
            }
        }
    }

    // helper to let this class change the state without using a global
    public interface GameStateHolder {
        void setGameState(int newState);
    }
}
