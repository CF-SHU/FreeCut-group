//Actions.qml
import QtQuick
import QtQuick.Controls
import "videoplayer.js" as Controller

Item {
    property alias open: _open
    property alias close: _close
    property alias exit: _exit
    property alias start: _start
    property alias pause: _pause
    property alias stop: _stop
    property alias about: _about

    Action{
        id:_open
        text:qsTr("&Open")
        icon.name:"document-open"
        shortcut:StandardKey.Open
    }

    Action{
        id:_close
        text:qsTr("&Close")
        icon.name:"document-close"
        shortcut:StandardKey.Close
        onTriggered:{
            Controller.close()
        }
    }

    Action{
        id:_exit
        text:qsTr("&Exit")
        icon.name:"application-exit"
        shortcut:StandardKey.Quit
        onTriggered:Qt.quit()
    }

    Action{
        id:_start
        text:qsTr("Start")
        icon.name:"media-playback-start"
        enabled: true
        onTriggered: {
            Controller.play()
        }
    }

    Action{
        id:_pause
        text:qsTr("Pause")
        icon.name:"media-playback-pause"
        enabled: false
        onTriggered: {
            Controller.pause()
        }
    }

    Action{
        id:_stop
        text:qsTr("Stop")
        icon.name:"media-playback-stop"
        enabled: false
        onTriggered: {
            Controller.stop()
        }
    }

    Action{
        id:_about
        text:qsTr("&About")
        icon.name:"help-about"
    }

}
