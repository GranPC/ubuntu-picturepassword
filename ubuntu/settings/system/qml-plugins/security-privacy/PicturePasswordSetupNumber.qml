import GSettings 1.0
import QtQuick 2.0
import QtQuick.Layouts 1.1
import Ubuntu.Components 1.1
import SystemSettings 1.0
import QtGraphicalEffects 1.0
import "."

ItemPage
{
    id: page
    title: i18n.tr( "Select a number" )

    property string img
    property int num

    ParallelAnimation
    {
        id: fade

        NumberAnimation
        {
            target: blur
            property: "radius"
            to: 0
            duration: 300
            easing.type: Easing.OutExpo
        }

        NumberAnimation
        {
            target: darkening
            property: "opacity"
            to: 0
            duration: 300
        }

        NumberAnimation
        {
            target: numbers
            property: "opacity"
            to: 0
            duration: 300
            easing.type: Easing.OutExpo
        }

        onStopped: pageStack.push( Qt.resolvedUrl( "PicturePasswordSetupMain.qml" ), { img: page.img, number: page.num } )
    }

    function chooseNumber( num )
    {
        page.num = num
        fade.start()
    }

    Rectangle
    {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        color: "transparent"
        anchors.margins: units.gu( 2 )

        Image
        {
            id: image
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.bottom: navPrev.top

            anchors.bottomMargin: units.gu( 1.5 )

            source: img
            fillMode: Image.PreserveAspectCrop
            visible: false
        }

        FastBlur
        {
            id: blur

            anchors.fill: image
            source: image
            radius: units.dp( 40 )

            Rectangle
            {
                id: darkening
                color: "black"
                opacity: 0.5
                anchors.fill: parent
            }
        }

        Grid
        {
            id: numbers

            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter

            rows: 4
            columns: 3
            spacing: units.gu( 2 )

            property int numberSize: units.gu( 8 )

            Repeater
            {
                model: 9

                PicturePasswordButton
                {
                    text: index + 1
                    width: numbers.numberSize
                    height: numbers.numberSize

                    onClicked:
                    {
                        chooseNumber( index + 1 )
                    }
                }
            }

            Rectangle
            {
                width: numbers.numberSize
                height: numbers.numberSize
                color: "transparent"
            }

            PicturePasswordButton
            {
                text: "0"
                width: numbers.numberSize
                height: numbers.numberSize

                onClicked:
                {
                    chooseNumber( 0 )
                }
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
