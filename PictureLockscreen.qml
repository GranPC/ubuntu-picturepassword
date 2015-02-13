/*
 * Based on PassphraseLockscreen.qml from Ubuntu Touch.
 * Copyright (C) 2013 Canonical, Ltd.
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; version 3.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

import QtQuick 2.0
import Ubuntu.Components 0.1
import "../Components"
import QtQuick.Layouts 1.1

Item {
    id: root
    anchors.top: parent.top
    anchors.topMargin: units.gu(4)
    height: parent.height

    property string infoText
    property string errorText
    property bool entryEnabled: true

    signal entered(string passphrase)
    signal cancel()

    function clear(playAnimation) {
        if (playAnimation) {
            wrongPasswordAnimation.start();
        }
    }

    function updateNumbers( sx, sy )
    {
        if ( sx < 0 ) sx++
        if ( sy < 0 ) sy++
        for ( var i = 0; i < numbers.model; i++ )
        {
            var x = i % numbergrid.columns
            var y = Math.floor( i / numbergrid.columns )
            x -= sx
            y -= sy
            numbers.itemAt( i ).text = x + ", " + y
        }
    }


    Column
    {
        id: shakeContainer
        anchors.horizontalCenter: parent.horizontalCenter
        width: parent.width
        spacing: units.gu(2)

        Label
        {
            id: infoField
            objectName: "infoTextLabel"
            fontSize: "x-large"
            color: "#f3f3e7"
            anchors.horizontalCenter: parent.horizontalCenter
            text: "Attempt 1 of 10"
        }
    }

    // TODO: Move this to its own component thingy!!!
    Rectangle
    {
        id: picture

        width: root.width
        height: root.height - root.y - shakeContainer.height - units.gu( 7 )
        y: shakeContainer.height + units.gu( 5 )

        color: 'yellow'

        // The actual thing that takes care of dragging
        MouseArea
        {
            anchors.fill: parent

            property variant lastPos
            onPressed: { lastPos = Qt.point( mouseX, mouseY ) }
            onPositionChanged:
            {
                var dx = mouseX - lastPos.x
                var dy = mouseY - lastPos.y

                var nw = numbers.itemAt( 0 ).width
                var nh = numbers.itemAt( 0 ).height

                numbergrid.x = dx % nw
                numbergrid.y = dy % nh

                infoField.text = dx + "," + dy + " || " + Math.floor( dx / nh ) + "," + Math.floor( dy / nh )

                try
                {
                    updateNumbers( Math.floor( dx / nw ), Math.floor( dy / nh ) )
                }
                catch ( e )
                {
                    // I really need to figure out how to get proper debug spew from this
                    infoField.text = e.toString()
                }
            }
        }

        Grid
        {
            id: numbergrid

            columns: 6
            rows: 10
            Repeater
            {
                id: numbers
                model: ( parent.columns ) * ( parent.rows )

                Label
                {
                    width: picture.width / parent.columns
                    height: picture.height / parent.rows

                    fontSize: "large"
                    color: "white"
                    style: Text.Outline
                    text: index

                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter

                    // TODO: these are just for debugging! get rid of them!
                    Rectangle
                    {
                        x: 0
                        y: 0
                        width: parent.width
                        height: parent.height

                        color: Qt.rgba( 1, 1, 1, 0.2 )
                    }

                    Rectangle
                    {
                        x: -1
                        y: -1
                        width: parent.width + 2
                        height: parent.height + 2
                        color: "blue"

                        z: -5
                    }
                }
            }
        }
    }

    WrongPasswordAnimation {
        id: wrongPasswordAnimation
        objectName: "wrongPasswordAnimation"
        target: shakeContainer
    }
}
