import GSettings 1.0
import QtQuick 2.0
import QtQuick.Layouts 1.1
import Ubuntu.Components 1.1
import SystemSettings 1.0

ItemPage
{
    id: page
    title: i18n.tr( "Picture Password" )

    Rectangle
    {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        color: "transparent"
        anchors.margins: units.gu( 2 )

        Label
        {
            text: i18n.tr( "Picture Password allows you to use a combination of a number and picture to unlock your device, instead of typing a password.\n\n<video goes here, some day>\n\nTo set up this feature, you choose the:\n\n• Picture\n• Number\n• Part of the picture to drag the number to" )
            wrapMode: Text.WordWrap
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
        }

        Label
        {
            text: i18n.tr( "%1  〉".arg( i18n.tr( "Continue" ) ) )
            anchors.bottom: parent.bottom
            anchors.right: parent.right
            color: Theme.palette.selected.backgroundText
            fontSize: "large"

            MouseArea
            {
                anchors.fill: parent
                onClicked: pageStack.push( Qt.resolvedUrl( "PicturePasswordSetupImage.qml" ) )
            }
        }
    }
}
