import GSettings 1.0
import QtQuick 2.0
import QtQuick.Layouts 1.1
import Ubuntu.Components 1.1
import Ubuntu.Content 0.1
import SystemSettings 1.0

ItemPage
{
    id: page
    title: i18n.tr( "Choose an image" )

    Rectangle
    {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        color: "transparent"
        anchors.margins: units.gu( 2 )
        anchors.bottomMargin: units.gu( 0.5 )

        ContentStore
        {
            id: store
            scope: ContentScope.App
        }

        Connections
        {
            property var transfer

            id: imageCallback
            target: transfer

            onStateChanged:
            {
                if ( transfer.state === ContentTransfer.Charged && transfer.items.length > 0 )
                {
                    var img = transfer.items[ 0 ].url
                    pageStack.push( Qt.resolvedUrl( "PicturePasswordSetupNumber.qml" ), { img: img } )
                }
            }
        }

        ContentPeerPicker
        {
            id: picker
            handler: ContentHandler.Source
            contentType: ContentType.Pictures
            showTitle: false
            onPeerSelected:
            {
                peer.selectionType = ContentTransfer.Single

                var transfer = peer.request( store )
                imageCallback.transfer = transfer
            }

            onCancelPressed: pageStack.pop()
        }
    }
}
