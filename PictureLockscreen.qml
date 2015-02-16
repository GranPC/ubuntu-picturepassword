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

    signal entered(string passphrase)
    signal cancel()
    signal authenticated()

    function clear(playAnimation)
    {
        if ( playAnimation )
        {
            wrongPasswordAnimation.start()
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

    PicturePassword
    {
        id: picture
        width: root.width
        height: root.height - root.y - shakeContainer.height - units.gu( 4 )
        y: shakeContainer.height + units.gu( 4 )

        unlocknumber: 3
        unlockx: 0
        unlocky: 0

        onSuccess: root.authenticated()
        onFailure: clear( true )
    }

    WrongPasswordAnimation {
        id: wrongPasswordAnimation
        objectName: "wrongPasswordAnimation"
        target: shakeContainer
    }
}
