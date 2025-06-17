import QtQuick
import QtQuick.Controls

Item {
    property alias open: _open
    property alias save: _save
    property alias quit: _quit
    property alias about: _about

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

}
