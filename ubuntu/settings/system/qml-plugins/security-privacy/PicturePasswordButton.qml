import QtQuick 2.0
import Ubuntu.Components 1.1

AbstractButton
{
    id: root

    property string text

    Label
    {
        horizontalAlignment: Text.AlignHCenter
        anchors.centerIn: parent

        text: root.text
        color: "white"
        fontSize: "x-large"

        style: Text.Outline
    }
}
