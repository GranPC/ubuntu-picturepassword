import GSettings 1.0
import QtQuick 2.0
import QtQuick.Layouts 1.1
import Ubuntu.Components 1.1
import SystemSettings 1.0
import "../../../../../unity8/Components" // this is absolutely horrible

ItemPage
{
    id: page
    title: i18n.tr( "Picture Password" )

    property string img

    Rectangle
    {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        color: "transparent"
        anchors.margins: units.gu( 2 )

        PicturePassword
        {
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.bottom: navPrev.top

            anchors.bottomMargin: units.gu( 1.5 )

            background: img
        }

        Label
        {
            id: navPrev
            text: i18n.tr( "〈  %1".arg( i18n.tr( "Back" ) ) )
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            color: Theme.palette.selected.backgroundText
            fontSize: "large"

            MouseArea
            {
                anchors.fill: parent
                onClicked: pageStack.pop()
            }
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
                onClicked: pageStack.push( Qt.resolvedUrl( "PicturePasswordSetupMain.qml" ) )
            }
        }
    }
}
