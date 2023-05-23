import QtQuick.Controls 2.15
import QtQuick.Shapes 1.15
import QtQuick.Window 2.15
import QtQml 2.15

Window {
    id: gameWindow
    width: 600
    height: 900
    visible: true

    property int score: 0
    property int record: 0
    property bool gameOver: false

    Rectangle {
        id: player
        width: 50
        height: 50
        color: "blue"
        radius: width / 2
        anchors.bottom: parent.bottom
        x: (gameWindow.width - width) / 2

        Keys.onPressed: {
            if (event.key === Qt.Key_Left) {
                if (player.x >= 10)
                    player.x -= 10
            } else if (event.key === Qt.Key_Right) {
                if (player.x + player.width <= gameWindow.width - 10)
                    player.x += 10
            }
        }
    }

    Repeater {
        id: invadersColumn
        model: 4

        Repeater {
            id: invadersRow
            model: 2

            Rectangle {
                id: invader
                width: 20
                height: 30
                color: "red"
                radius: width / 2
                x: Math.random() * (gameWindow.width - invader.width)
                y: Math.random() * -gameWindow.height

                property int moveDirection: 1 // 1 - ruch w prawo, -1 - ruch w lewo
                property int moveSpeed: 15 // Szybkość ruchu wroga

                Timer {
                    id: invaderTimer
                    interval: 1000 / invader.moveSpeed
                    running: !gameWindow.gameOver
                    repeat: true

                    onTriggered: {
                        invader.y += 10

                        if (invader.y + invader.height >= player.y && invader.x <= player.x + player.width && invader.x + invader.width >= player.x) {
                            // Kolizja gracza z wrogiem - gra się kończy
                            gameWindow.gameOver = true;
                            invaderTimer.stop();
                            showGameOverDialog();
                        }

                        if (invader.y >= gameWindow.height) {
                            // Wrog dotarł do dolnej krawędzi - usuń wroga i zresetuj jego pozycję
                            score++;
                            if(score > record)
                                record = score;
                            invaderTimer.stop();
                            invader.y = Math.random() * -gameWindow.height;
                            invader.x = Math.random() * (gameWindow.width - invader.width);
                            invaderTimer.start();
                        }

                        // Losowy ruch w lewo lub prawo
                        if (Math.random() < 0.05) {
                            invader.moveDirection = -invader.moveDirection;
                        }

                        // Sprawdzanie kolizji z krawędziami ekranu
                        if (invader.x <= 0 || invader.x + invader.width >= gameWindow.width) {
                            invader.moveDirection = -invader.moveDirection;
                        }

                        invader.x += invader.moveDirection * 10;
                    }
                }
            }
        }
    }

    Rectangle {
            id: backgroundRect
            width: gameWindow.width
            height: gameWindow.height
            color: "lightblue"
            z: -1
        }

    Text {
        id: scoreLabel
        text: "Score: " + gameWindow.score
        font.pixelSize: 20
        color: "black"
        anchors.top: parent.top
        anchors.horizontalCenter: parent.horizontalCenter
    }

    Item {
        id: gameOverDialog
        visible: gameWindow.gameOver
        anchors.fill: parent

        Rectangle {
            width: parent.width
            height: parent.height
            color: "black"
            opacity: 0.7

            Text {
                text: "Przegrałeś!\nZdobyte punkty: " + gameWindow.score + "\nRekord aktualnej sesji: " + gameWindow.record
                font.pixelSize: 24
                color: "white"
                anchors.centerIn: parent
                wrapMode: Text.Wrap
            }

            Button {
                text: "Restart"
                anchors {
                    horizontalCenter: parent.horizontalCenter
                    top: parent.verticalCenter
                    topMargin: 20
                }
                onClicked: {
                    restartGame();
                }
            }
        }
    }

    Item {
        focus: true
        Keys.onPressed: {
            if (event.key === Qt.Key_Left) {
                if (player.x >= 10)
                    player.x -= 10
            } else if (event.key === Qt.Key_Right) {
                if (player.x + player.width <= gameWindow.width - 10)
                    player.x += 10
            }
        }
    }

    function showGameOverDialog() {
        gameOverDialog.visible = true;
    }

    function restartGame() {
        score = 0;
        gameOver = false;
        gameOverDialog.visible = false;
        invadersColumn.model = 0;
        for (var i = 0; i < invadersColumn.count; i++) {
            invadersColumn.itemAt(i).destroy();
        }
        invadersColumn.model = 4;


        player.forceActiveFocus();
    }

}
