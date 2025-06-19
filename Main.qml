import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Videoclips 1.0
import "control.js" as Controller
import QtQuick.Dialogs
import QtCore
import QtMultimedia

ApplicationWindow {
    id:window
    width: 640
    height: 480
    visible: true
    title: qsTr("VideoCut")

    // 定义按钮的初始状态
    property int currentButton: 1 // 1: 第一个按钮可见

    ColumnLayout{
        anchors.fill:parent
        spacing:0
        MenuBar {
            Menu {
                title: qsTr("File")
                MenuItem { action: actions.open }
                MenuItem { action: actions.save }
                MenuItem { action: actions.quit }
            }
            Menu {
                title: qsTr("Help")
                MenuItem { action: actions.about }
            }
        }

        ToolBar {
            RowLayout{
                ToolButton{ action: actions.open }
                ToolButton{ action: actions.save }
                ToolButton{ action: actions.quit }
            }
        }

        Rectangle{
            id:cenRect
            Layout.fillWidth: true
            Layout.fillHeight: true

           Contents{
               id:content
               anchors.fill: parent
           }
        }

    }
    Actions{
        id:actions
        open.onTriggered:content.dialog.openfile.open()
        about.onTriggered: oneplayer.about.open()

    }
}
