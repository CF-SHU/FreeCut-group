import QtQuick
import QtQuick.Controls

Item {
    property alias open: _open
    property alias save: _save
    property alias quit: _quit
    property alias about: _about
    property alias stop: _stop
    property alias pause: _pause
    property alias start: _start
    property alias a:_a
    property alias aa:_aa
    property alias bb:_bb
    property alias cc:_cc
   // property alias a:_a

    Action {
        id: _open
        text: qsTr("导入素材")
        icon.name: "document-open"
        shortcut: StandardKey.Open
    }

    Action {
        id: _save
        text: qsTr("保存视频")
        shortcut: StandardKey.Save
        icon.name: "document-save"
    }

    Action {
        id: _quit
        text: qsTr("退出程序")
        icon.name: "application-exit"
        shortcut: StandardKey.Quit
        onTriggered: Qt.quit();
    }

    Action {
        id: _about
        text: qsTr("关于")
        icon.name: "help-about"
    }
    Action
    {
        id:_stop
        text:qsTr("&Stop...")
        icon.name:"media-playback-stop"
        onTriggered:{
            content.mplay.stop()
        }
    }
    Action
    {
        id:_pause
        text:qsTr("&Pause...")
        icon.name:"media-playback-pause"
        onTriggered:{
            content.mplay.pause()
        }
    }
    Action
    {
        id:_start
        text:qsTr("&start...")
        icon.name:"media-playback-start"
        onTriggered:{
            content.mplay.play()
        }
    }
    Action
    {
        id:_a
        text:qsTr("&open...")
        icon.name:"media-playback-start"
        onTriggered:{
            oneplayer.mplay.play()
        }
    }
    Action
    {
        id:_cc
        text:qsTr("&Stop...")
        icon.name:"media-playback-stop"
        onTriggered:{
            oneplayer.mplay.stop()
        }
    }
    Action
    {
        id:_bb
        text:qsTr("&Pause...")
        icon.name:"media-playback-pause"
        onTriggered:{
            oneplayer.mplay.pause()
            if (oneplayer.mplay.playbackState === MediaPlayer.PlayingState) {
                            oneplayer.mplay.pause();
                            console.log("Paused at:", formatTime(oneplayer.mplay.position)); // 暂停时打印当前时间
                        } else {
                            oneplayer.mplay.play();
                        }
        }
    }
    Action
    {
        id:_aa
        text:qsTr("&start...")
        icon.name:"media-playback-start"
        onTriggered:{
            oneplayer.mplay.play()
        }
    }
}
