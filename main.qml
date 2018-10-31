import QtQuick 2.9
import QtQuick.Window 2.3
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import QtCharts 2.0
import UDI 1.1;

Window
{
    id: app

    title: qsTr("TCP communication with PLC")

    property int xx: 0

    minimumWidth: rl.width + 30
    minimumHeight: 300

    ColumnLayout
    {
        id: cl

        anchors.fill: parent
    //    spacing: 20

        ChartView
        {
            id: chart

            Layout.fillWidth: true
            Layout.fillHeight: true
            antialiasing: true

            title: "Real-time data acquisition from SIMATIC S7-1500"
            titleFont.pixelSize: 20

            legend.alignment: Qt.AlignBottom
            legend.font.pixelSize: 12
            legend.font.bold: true
            legend.visible: line0.count > 0

            LineSeries
            {
                id: line0
                name: "Time serie No. 1"
                useOpenGL: true

                Component.onCompleted:
                {
                    axisX.labelsFont = Qt.font({pointSize: 10, bold: true});
                    axisX.min = 0;
                    axisX.max = windowControl.value;
                    axisX.labelFormat = "%d";

                    axisY.labelsFont = Qt.font({pointSize: 10, bold: true});
                    axisY.min = -128;
                    axisY.max = 127;
                    axisY.labelFormat = "%d";
                }
            }

            MouseArea
            {
                property int xs
                property int ys
                property int xe
                property int ye

                anchors.fill: parent
                acceptedButtons: Qt.LeftButton | Qt.RightButton

                onPressed:
                {
                    xs = mouse.x;
                    ys = mouse.y;

                    var c = limit(xs, ys); xs = c[0]; ys = c[1];
                }

                onReleased:
                {
                    rect.width = 0;
                    rect.height = 0;

                    var rect1 = Qt.rect(0,0,0,0);

                    transform(mouse, rect1);

                    chart.zoomIn(rect1);
                }

                onPositionChanged:
                {
                    if (mouse.buttons === Qt.LeftButton) transform(mouse, rect);
                }

                onClicked:
                {
                    if (mouse.button === Qt.RightButton) chart.zoomReset();
                }

                onPressAndHold:
                {
                    chart.zoomReset();
                }

                function limit(x, y)
                {
                    if (x < chart.plotArea.x) x = chart.plotArea.x;
                    if (y < chart.plotArea.y) y = chart.plotArea.y;
                    if (x > chart.plotArea.x + chart.plotArea.width) x = chart.plotArea.x + chart.plotArea.width;
                    if (y > chart.plotArea.y + chart.plotArea.height) y = chart.plotArea.y + chart.plotArea.height;

                    return [x, y];
                }

                function transform(mouse, rect1)
                {
                    xe = mouse.x;
                    ye = mouse.y;

                    var c = limit(xe, ye); xe = c[0]; ye = c[1];

                    if (xe < xs)
                    {
                        rect1.x = xe;
                        rect1.width = xs - xe;
                    }
                    else
                    {
                        rect1.x = xs;
                        rect1.width = xe - xs;
                    }

                    if (ye < ys)
                    {
                        rect1.y = ye;
                        rect1.height = ys - ye;
                    }
                    else
                    {
                        rect1.y = ys;
                        rect1.height = ye - ys;
                    }
                }
            }

            Rectangle
            {
                id: rect
                color: border.color//"transparent"
                opacity: 0.3
                border.color: "#FF55FF"
                border.width: 2
            }
        }

        MySlider
        {
            id: amplitudeControl

            Layout.fillWidth: true

            leftPadding: rl.x
            rightPadding: chart.width - (rl.x + rl.width)

            text:
            {
                var p = value * 100;
                return "Amplitude: " + p.toFixed(0) + " %";
            }

            visible: noise.enabled

            property real oldValue: -1

            value: 0.5
            onValueChanged:
            {
                if (oldValue == -1) oldValue = value;

                if (Math.abs(value - oldValue) > 0.01)
                {
                    udi.send(UDI.Amplitude, value);
                    oldValue = value;
                }
            }

            onPressedChanged: if (!pressed) udi.send(UDI.Amplitude, value);
        }

        Item
        {
            width: 1
        }

        MySlider
        {
            id: noiseControl

            Layout.fillWidth: true

            leftPadding: rl.x
            rightPadding: chart.width - (rl.x + rl.width)

            text:
            {
                var p = value * 100;
                return "Noise level: " + p.toFixed(0) + " %";
            }

            visible: noise.addNoise && noise.enabled

            property real oldValue: -1

            value: 0.2
            onValueChanged:
            {
                if (oldValue == -1) oldValue = value;

                if (Math.abs(value - oldValue) > 0.01)
                {
                    udi.send(UDI.NoiseLevel, value);
                    oldValue = value;
                }
            }

            onPressedChanged: if (!pressed) udi.send(UDI.NoiseLevel, value);
        }

        RowLayout
        {
            id: rl

            Layout.alignment: Qt.AlignHCenter
            Layout.topMargin: 10

            spacing: 20

            MyButton
            {
                id: connect
                text: "Connect"

                onClicked:
                {
                    chart.zoomReset();
                    udi.connect(amplitudeControl.value, noise.addNoise, noiseControl.value);
                    enabled = false;
                }
            }

            MyButton
            {
                id: change
                text: "Change waveform"
                enabled: !connect.enabled
                onClicked: udi.send(UDI.Square);
            }

            MyButton
            {
                id: noise
                property bool addNoise: false

                text: "Add/remove noise"
                enabled: !connect.enabled
                onClicked: { addNoise = !addNoise; udi.send(UDI.AddNoise, addNoise); }
            }

            MyButton
            {
                id: disconnect
                text: "Disconnect"
                enabled: !connect.enabled
                onClicked: { connect.enabled = true; udi.disconnect(); }
            }

            MyButton
            {
                text: "Clear graph"
                onClicked:
                {
                    xx = 0;
                    line0.clear();
                    chart.zoomReset();
                }
            }
        }

        Item
        {
            width: 1
            height: 10
        }

        Rectangle
        {
            Layout.alignment: Qt.AlignHCenter
            //color: "red"
            width: rl.width
            height: 50
            border.color: "lightsteelblue"

            RowLayout
            {
                id: rl2

                anchors.fill: parent
                anchors.leftMargin: 5
                anchors.rightMargin: 5
                anchors.topMargin: 5
                anchors.bottomMargin: 10

                CheckBox
                {
                    id: floatingMode
                    text: "Floating mode, window size:"
                    font: Qt.font({pointSize: 10, bold: false});

                }

                MySlider
                {
                    id: windowControl

                    Layout.fillWidth: true

                    enabled: floatingMode.checked

                    from: 50
                    to: 10000
                    value: 200
                    onValueChanged:
                    {
                        line0.axisX.min = Math.max(0, xx - windowControl.value);
                        line0.axisX.max = Math.max(windowControl.value, xx);
                    }
                }
            }
        }

        Item
        {
            width: 1
            height: 10
        }
    }

    Connections
    {
        target: udi

        onSignalDataArrived:
        {
            var N = 20000;

            if (line0.count > N)
            {
                line0.removePoints(0, N/2);
                if (!floatingMode.checked) line0.axisX.min = Math.max(0, xx - N/2);
            }

            if (floatingMode.checked)
            {
                line0.append(xx, y);
                line0.axisX.min = Math.max(0, xx - windowControl.value);
                line0.axisX.max = Math.max(windowControl.value, xx);
                xx++;
            }
            else
            {
                line0.append(xx, y);
                line0.axisX.max = Math.max(windowControl.value, xx);
                xx++;
            }
        }
    }

    Component.onCompleted:
    {
        if (udi.android) visibility = Window.FullScreen;
        else
        {
            app.width = 800;
            app.height = 600;
            x = (Screen.width - width) / 2;
            y = (Screen.height - height) / 2;
        }

        if (udi.simulation)
        {
            for (var i = 0; i < 200; i++)
            {
                line0.append(xx, 127 * Math.sin(10 * 6.28 * i / 200));
                xx++;
            }
        }

        visible = true;
    }
}
