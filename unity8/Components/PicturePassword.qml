import QtQuick 2.0
import Ubuntu.Components 0.1
import "../Components"
import QtQuick.Layouts 1.1

Rectangle
{
    id: root

    property int seed: 235989
    property int threshold: units.gu( 4 )

    property int unlocknumber: -1
    property int unlockx: 0
    property int unlocky: 0

    property string background

    signal success()
    signal failure()

    function reset( playAnimation )
    {
        seed = Math.round( ( Math.random() * 2 - 1 ) * 100000000 )
        numbergrid.x = 0
        numbergrid.y = 0

        // HACK: we use -2, -2 so we don't have to reposition the grid
        updateNumbers( -2, -2 )

        if ( playAnimation )
        {
            for ( var i = 0; i < numbers.model; i++ )
            {
                var item = numbers.itemAt( i )
                var anim = item.resources[ 0 ]
                item.scale = 0
                anim.start()
            }
        }
    }

    function getNumberForXY( x, y )
    {
        // Taken from the Android version. Still not ideal.

        // Looks like having x/y 0 causes entire rows of repeating numbers
        if ( x <= 0 ) x--
        if ( y <= 0 ) y--

        return Math.abs( seed ^ ( x * 2138105 + 1 ) * ( y + 1 * 23490 ) ) % 10
    }

    function isNumberAtXY( number, x, y, maxdist )
    {
        var maxdistsqr = maxdist * maxdist

        for ( var i = 0; i < numbers.model; i++ )
        {
            var item = numbers.itemAt( i )
            if ( item.text == number.toString() )
            {
                var dx = item.x + item.width / 2 + numbergrid.x - x
                var dy = item.y + item.height / 2 + numbergrid.y - y

                var distsqr = dx * dx + dy * dy
                if ( distsqr <= maxdistsqr )
                {
                    return true
                }
            }
        }

        return false
    }

    function updateNumbers( sx, sy )
    {
        if ( sx < 0 ) sx++
        if ( sy < 0 ) sy++
        for ( var i = 0; i < numbers.model; i++ )
        {
            var x = i % numbergrid.columns - 1
            var y = Math.floor( i / numbergrid.columns - 1 )
            x -= sx
            y -= sy
            numbers.itemAt( i ).text = getNumberForXY( x, y )
        }
    }

    Image
    {
        id: picture

        width: root.width
        height: root.height
        y: 0

        source: root.background
        fillMode: Image.PreserveAspectCrop
        clip: true

        // The actual thing that takes care of dragging
        MouseArea
        {
            anchors.fill: parent

            property variant lastPos
            onPressed: { lastPos = Qt.point( mouseX, mouseY ) }
            onReleased:
            {
                if ( isNumberAtXY( unlocknumber, unlockx, unlocky, threshold ) )
                {
                    root.success()
                }
                else
                {
                    reset( true )
                    root.failure()
                }
            }

            onPositionChanged:
            {
                var dx = mouseX - lastPos.x
                var dy = mouseY - lastPos.y

                var nw = numbers.itemAt( 0 ).width
                var nh = numbers.itemAt( 0 ).height

                numbergrid.x = dx % nw - nw
                numbergrid.y = dy % nh - nh

                updateNumbers( Math.floor( dx / nw ), Math.floor( dy / nh ) )
            }
        }

        Grid
        {
            id: numbergrid

            columns: 6 + 2
            rows: 10 + 2
            Repeater
            {
                id: numbers
                model: parent.columns * parent.rows

                Component.onCompleted: reset( true )

                Label
                {
                    id: num
                    width: picture.width / ( parent.columns - 2 )
                    height: picture.height / ( parent.rows - 2 )

                    fontSize: "large"
                    color: "white"
                    style: Text.Outline
                    text: index

                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter

                    resources:
                    [
                        SequentialAnimation
                        {
                            PauseAnimation
                            {
                                duration: index * 8
                            }

                            PropertyAnimation
                            {
                                id: "scaleAnimation"
                                property: "scale"
                                from: 0.0
                                to: 1.0
                                duration: 180
                                target: num

                                easing.type: Easing.OutExpo
                            }

                            running: true
                        }
                    ]
                }
            }
        }
    }
}
