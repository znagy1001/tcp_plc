import QtQuick 2.0
import QtQuick.Controls 2.2

Slider
{
    id: control

    property alias text: text.text

    opacity: enabled ? 1 : 0.7

    Text
    {
        id: text
        anchors.left: parent.left
        anchors.leftMargin: parent.leftPadding
        y: -10
        font: Qt.font({pointSize: 10, bold: false});
    }

    background: Rectangle
    {
        x: control.leftPadding
        y: control.topPadding + control.availableHeight / 2 - height / 2
        implicitWidth: 200
        implicitHeight: 4
        width: control.availableWidth
        height: implicitHeight
        radius: 2
        color: "#bdbebf"

        Rectangle
        {
            width: control.visualPosition * parent.width
            height: parent.height
            color: control.enabled ? "#21be2b" : "grey"
            radius: 2
        }
    }

    handle: Rectangle
    {
        x: control.leftPadding + control.visualPosition * (control.availableWidth - width)
        y: control.topPadding + control.availableHeight / 2 - height / 2
        implicitWidth: 26
        implicitHeight: 26
        radius: 13
        color: control.pressed ? "#f0f0f0" : "#f6f6f6"
        border.color: "#bdbebf"
    }
}

