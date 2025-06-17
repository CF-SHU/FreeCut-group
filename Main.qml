import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Videoclips 1.0

ApplicationWindow {
    id:window
    width: 640
    height: 480
    visible: true
    title: qsTr("Hello World")
    ColumnLayout{
        anchors.fill:parent
        spacing:0
            RowLayout{
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
            }
            RowLayout{
                ToolBar {
                    RowLayout{
                        ToolButton{ action: actions.open }
                        ToolButton{ action: actions.save }
                        ToolButton{ action: actions.quit }
                    }
                }
            }
        Rectangle{
            id:cenRect
            implicitHeight:(window.height / 2)// - topRect.implicitHeight
            implicitWidth:window.width
           RowLayout{
               spacing:0
               anchors.fill:parent
                Rectangle{
                    id:leftRect
                    implicitWidth:window.height / 4
                    implicitHeight:cenRect.implicitHeight
                    color:"green"
                    border.color:"green"
                }
                Rectangle{
                    id:_cRect
                    implicitWidth:(window.width - (window.width / 4)) / 2
                    implicitHeight:cenRect.implicitHeight
                    color:"blue"
                    border.color:"blue"
                    Dialogs{
                        id:dialogs
                    }
                }
                Rectangle{
                    id:rightRect
                    implicitWidth:window.width - (window.width / 4)
                    implicitHeight:cenRect.implicitHeight
                    color:"black"
                    border.color:"black"
                }
            }
        }

        Rectangle{
            id:bottomRect
            implicitHeight:window.height/2
            implicitWidth:window.width
            color:"pink"
            border.color:"pink"
        }
    }
    Actions{
        id:actions
        open.onTriggered:dialogs.openfile.open()
        }
}
