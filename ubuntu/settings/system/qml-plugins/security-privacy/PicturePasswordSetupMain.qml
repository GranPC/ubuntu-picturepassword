import GSettings 1.0
import QtQuick 2.0
import QtQuick.Layouts 1.1
import Ubuntu.Components 1.1
import SystemSettings 1.0
import "../../../../../unity8/Components" // this is absolutely horrible

ItemPage
{
    id: page
    title: i18n.tr( "Select a position" )

    property string img
    property int number
    property var numberx
    property var numbery

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
            id: picture
            
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.bottom: navPrev.top

            anchors.bottomMargin: units.gu( 1.5 )

            background: img
            setupNumber: number

            onPositionUpdated:
            {
                page.numberx = x
                page.numbery = y
                
                console.warn( x, y )
            }
            
            onSuccess:
            {
                // Write settings
            }

            onFailure:
            {
                page.title = i18n.tr( "Try again" )
            }
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
            id: navNext
            text: i18n.tr( "%1  〉".arg( i18n.tr( "Continue" ) ) )
            anchors.bottom: parent.bottom
            anchors.right: parent.right
            color: Theme.palette.selected.backgroundText
            fontSize: "large"

            MouseArea
            {
                anchors.fill: parent
                onClicked:
                {
                    page.title = i18n.tr( "Confirm your position" )

                    picture.endSetup()
                    picture.reset( true )

                    picture.unlocknumber = number
                    picture.unlockx = numberx
                    picture.unlocky = numbery

                    navNext.enabled = false
                }
            }
        }
    }
}
