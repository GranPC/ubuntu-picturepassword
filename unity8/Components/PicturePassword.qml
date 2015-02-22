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

    property bool setup: false
    property int setupNumber: -1
    property int setupX: 0
    property int setupY: 0

    property int columns: 6
    property int rows: 10

    property int offsetX
    property int offsetY

    onSetupNumberChanged: { startSetup( setupNumber ) }

    signal success()
    signal failure()
    signal positionUpdated( var x, var y )

    property bool busy: true

    Timer
    {
        id: resetTimer
        interval: numbergrid.columns * numbergrid.rows * 8 + 180
        onTriggered: { fadeNewNumbersIn() }
    }
    
    function requireNumber( number )
    {
        while( true )
        {
            for ( var x = 0; x < root.columns; x++ )
            {
                for ( var y = 0; y < root.rows; y++ )
                {
                    if ( getNumberForXY( x, y ) == number )
                    {
                        return [ x, y ]
                    }
                }
            }

            seed = Math.round( ( Math.random() * 2 - 1 ) * 100000000 )
        }
    } 

    function startSetup()
    {
        var number = root.setupNumber

        setup = true
        var pos = requireNumber( number )
        setupX = pos[ 0 ]
        setupY = pos[ 1 ]

        updateNumbers( -2, -2 )
    }

    function endSetup()
    {
        setup = false
    }

    function reset( fadeout )
    {
        if ( fadeout )
        {
            for ( var i = 0; i < numbers.model; i++ )
            {
                var item = numbers.itemAt( i )
                var anim = item.resources[ 1 ]
                item.resources[ 0 ].stop()
                anim.start()
            }
            
            resetTimer.start()
        }
        else
        {
            fadeNewNumbersIn()
        }
    }
                        
    function fadeNewNumbersIn()
    {
        if ( !setup )
            seed = Math.round( ( Math.random() * 2 - 1 ) * 100000000 )

        numbergrid.x = 0
        numbergrid.y = 0
        
        dragAgent.x = 0
        dragAgent.y = 0

        dragAgent.gridX = 0
        dragAgent.gridY = 0

        // HACK: we use -2, -2 so we don't have to reposition the grid
        updateNumbers( -2, -2 )

        for ( var i = 0; i < numbers.model; i++ )
        {
            var item = numbers.itemAt( i )
            var anim = item.resources[ 0 ]
            item.resources[ 1 ].stop()
            anim.start()
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
        var unlockpos = convertToViewSpace( unlockx, unlocky )

        for ( var i = 0; i < numbers.model; i++ )
        {
            var item = numbers.itemAt( i )
            if ( item.text == number.toString() )
            {
                var pos = item.mapToItem( picture, item.width / 2, item.height / 2 )

                var dx = pos.x - unlockpos[ 0 ]
                var dy = pos.y - unlockpos[ 1 ]

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

        offsetX = sx
        offsetY = sy

        for ( var i = 0; i < numbers.model; i++ )
        {
            var x = i % numbergrid.columns - 1
            var y = Math.floor( i / numbergrid.columns - 1 )
            x -= sx
            y -= sy
            numbers.itemAt( i ).text = getNumberForXY( x, y )

            var setupOpacity = 0.33
            if ( x == setupX && y == setupY ) setupOpacity = 1
            numbers.itemAt( i ).opacity = setup ? setupOpacity : 1
        }
    }
    
    function convertToImageSpace( x, y )
    {
        var paintedWidth = picture.paintedWidth / 2 + picture.width / 2
        var paintedHeight = picture.paintedHeight / 2 + picture.height / 2
        
        var scale = picture.paintedWidth / picture.sourceSize.width

        if ( picture.paintedHeight == picture.height )
        {
            scale = picture.paintedHeight / picture.sourceSize.height
        }
        
        var centerX = x - picture.width / 2
        var centerY = y - picture.height / 2
        
        centerX /= scale
        centerY /= scale
        
        x = centerX + picture.sourceSize.width / 2
        y = centerY + picture.sourceSize.height / 2

        return [x, y]
    }

    function convertToViewSpace( x, y )
    {
        var paintedWidth = picture.paintedWidth / 2 + picture.width / 2
        var paintedHeight = picture.paintedHeight / 2 + picture.height / 2

        var scale = picture.paintedWidth / picture.sourceSize.width

        if ( picture.paintedHeight == picture.height )
        {
            scale = picture.paintedHeight / picture.sourceSize.height
        }

        var centerX = x - picture.sourceSize.width / 2
        var centerY = y - picture.sourceSize.height / 2

        centerX *= scale
        centerY *= scale

        x = centerX + picture.width / 2
        y = centerY + picture.height / 2

        return [x, y]
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
            id: dragAgent
            anchors.fill: parent

            property variant lastPos
            
            property int gridX
            property int gridY

            onPressed: { lastPos = Qt.point( mouseX, mouseY ) }
            onReleased:
            {
                if ( root.setup )
                {
                    var num = numbers.itemAt( ( setupY + offsetY + 1 ) * numbergrid.columns + setupX + offsetX + 1 )
                    if ( !num )
                    {
                        // Number was out of bounds: user scrolled too far!
                        reset( true )
                    }
                    else
                    {
                        var numpos = num.mapToItem( picture, num.width / 2, num.height / 2 )

                        // Since the image isn't sized exactly the same (cropped, etc) in the lock screen and in the wizard,
                        // we need to convert these positions to image positions

                        var converted = convertToImageSpace( numpos.x, numpos.y )
                        root.positionUpdated( converted[ 0 ], converted[ 1 ] )
                    }
                }
                else
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
            }

            onPositionChanged:
            {
                var dx = mouseX - lastPos.x
                var dy = mouseY - lastPos.y

                gridX += dx
                gridY += dy

                lastPos.x = mouseX
                lastPos.y = mouseY

                var nw = numbers.itemAt( 0 ).width
                var nh = numbers.itemAt( 0 ).height

                numbergrid.x = gridX % nw - nw
                numbergrid.y = gridY % nh - nh

                updateNumbers( Math.floor( gridX / nw ), Math.floor( gridY / nh ) )
            }
        }

        Grid
        {
            id: numbergrid

            columns: root.columns + 2
            rows: root.rows + 2

            Repeater
            {
                id: numbers
                model: parent.columns * parent.rows

                Component.onCompleted: reset( false )

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

                    scale: 0

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
                                property: "scale"
                                to: 1.45
                                duration: 180
                                target: num

                                easing.type: Easing.OutExpo
                            }

                            running: true
                            onRunningChanged:
                            {
                                if ( running )
                                {
                                    root.busy = true
                                }
                                else
                                {
                                    root.busy = false
                                }
                            }
                        },

                        SequentialAnimation
                        {
                            PauseAnimation
                            {
                                duration: index * 8
                            }

                            PropertyAnimation
                            {
                                property: "scale"
                                to: 0.0
                                duration: 180
                                target: num

                                easing.type: Easing.InExpo
                            }

                            running: true
                            
                            onRunningChanged:
                            {
                                if ( running )
                                {
                                    root.busy = true
                                }
                            }
                        }
                    ]
                }
            }
        }
    }
}
