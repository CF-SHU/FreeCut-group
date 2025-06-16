//Main.qml
import QtQuick.Controls
import QtQuick.Layouts
import "videoplayer.js" as Controller

ApplicationWindow {
    id:window
    width: 800
    height: 600
    visible: true

    menuBar:MenuBar{
        Menu{
            title:qsTr("File")
            MenuItem {action:actions.open}
            MenuItem {action:actions.close}
            MenuItem {action:actions.exit}
        }
        Menu{
            title:qsTr("Play")
            MenuItem {action:actions.start}
            MenuItem {action:actions.pause}
            MenuItem {action:actions.stop}
        }
        Menu{
            title:qsTr("Help")
            MenuItem {action:actions.about}
        }
    }

    header:ToolBar{
        RowLayout{
            ToolButton {action:actions.open}
            ToolButton {action:actions.close}
            ToolSeparator {}            
        }
    }
    footer:ToolBar{
        RowLayout{
            ToolButton {action:actions.start}
            ToolButton {action:actions.pause}
            ToolButton {action:actions.stop}
            ToolSeparator {}
        }
    }

    Actions{
        id:actions
        open.onTriggered:Controller.open()
        about.onTriggered: content.dialog.about.open()
    }

    Content{
        id:content
        visible:true
        //anchors.fill: parent
    }
}
