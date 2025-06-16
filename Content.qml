//Content.qml
import QtQuick
import QtMultimedia
import "videoplayer.js" as Controller

Item {
    anchors.fill: parent

    property alias dialog: _dialog
    property alias player: _player

    Dialogs{
        id:_dialog
        fileOpen.onRejected:{
            return;
        }
        fileOpen{
            onAccepted:{
                let filePath = fileOpen.selectedFile;
                _player.source = filePath
                console.log("mkv or avi path: ",filePath)
                Controller.play()
            }
        }
    }

    Rectangle {
        id:rec
        anchors.fill:parent
        color: "black"

        MediaPlayer {
            id: _player
            videoOutput: videoOutput
            onMediaStatusChanged: {
                if(mediaStatus === MediaPlayer.LoadedMedia) {
                    console.log("Audio loaded successfully")
                }else if(mediaStatus === MediaPlayer.InvalidMedia){
                    console.log("Failed to load audio:",errorString)
                    _dialog.openFail.open()
                }
            }
            onPlaybackStateChanged: {
                Controller.updateButtonStates()
            }
        }

        VideoOutput {
            id: videoOutput
            anchors.fill: parent
        }       
    }
}
