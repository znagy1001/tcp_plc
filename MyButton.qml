import QtQuick 2.0
import QtQuick.Controls 2.2

Rectangle
{
    id: root
    property alias text: text.text

    width: textToMeasure.width + 30
    height: textToMeasure.height + 20

    border.width: 1
    border.color: "lightsteelblue"

    signal clicked();

    Text
    {
        id: text
        anchors.centerIn: parent
        font.pixelSize: 15
        color: enabled ? "black" : "gray"
    }

    Text
    {
        id: textToMeasure
        text: text.text
        font: text.font
        visible: false
    }

    MouseArea
    {
        anchors.fill: parent
        onPressed: root.color = Qt.darker("white", 1.1);
        onReleased: root.color = "white";
        onClicked: root.clicked();
    }
}
