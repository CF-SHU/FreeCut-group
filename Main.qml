import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Videoclips 1.0

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

    // 格式化时间为 mm:ss
    function formatTime(milliseconds) {
        var seconds = milliseconds / 1000;
        var minutes = Math.floor(seconds / 60);
        seconds = Math.floor(seconds % 60);
        return minutes + ":" + (seconds < 10 ? "0" : "") + seconds;
    }

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
                   implicitWidth:(window.width / 2)
                   implicitHeight:cenRect.implicitHeight
                   color:"green"
                   border.color:"green"
                   Contents{
                       id:content
                       anchors.fill: parent
                   }
                }
                Rectangle{
                    id:rightRect
                    implicitWidth:window.width - (window.width / 4)
                    implicitHeight:cenRect.implicitHeight
                    color:"black"
                    border.color:"black"
                    Player{
                        id:oneplayer
                    }
                    ToolBar
                    {
                        RowLayout
                        {
                            ToolButton{action:actions.a}//open
                            ToolButton{action:actions.aa}//start
                            ToolButton{action:actions.bb}//pause
                            ToolButton{action:actions.cc}//stop
                        }
                    }

                }
            }
        }

        Rectangle{
            id:bottomRect
            implicitHeight:window.height/2
            implicitWidth:window.width
            color:"pink"
            border.color:"pink"

        // 时间轴 Slider
           Slider {
               id: slider
               y:50
               anchors.centerIn: parent.centerIn
            //   anchors.horizontalCenter: parent.horizontalCenter
               width: parent.width - 40 // 留出一些边距
               from: 0
               to: oneplayer.mplay.duration > 0 ? oneplayer.mplay.duration : 1000 // 默认值为 1000 毫秒（1 秒），避免为 0
               value: oneplayer.mplay.position
               stepSize: 1000 // 步长为 1 秒

               // 当用户拖动 Slider 时，跳转到视频的相应位置
               onValueChanged: {
                   if (pressed) { // 仅在用户拖动滑块时更新
                       console.log("Slider value changed to:", value); // 调试输出
                       oneplayer.mplay.position = value; // 使用 position 属性跳转
                   }
               }
           }

           // 显示当前时间和总时长
           Row {
               anchors.bottom: slider.top
               anchors.horizontalCenter: parent.horizontalCenter
               spacing: 10

               Text {
                   text: formatTime(oneplayer.mplay.position)
                   color: "white"
               }

               Text {
                   text: "/"
                   color: "white"
               }

               Text {
                   text: formatTime(oneplayer.mplay.duration)
                   color: "white"
               }
           }

            Column {
                anchors.centerIn: parent
                spacing: 20

                Button {
                    id: button1
                    text:qsTr("剪辑开始")
                    visible: currentButton === 1
                    onClicked: {
                        currentButton = 2
                    }
                }

                Button {
                    id: button2
                    visible: currentButton === 2
                    text:qsTr("选择该节点作为剪辑的第一个节点")
                 // 格式化时间为秒数
                    function formatTime(milliseconds) {
                        return Math.floor(milliseconds / 1000); // 返回秒数
                   }
                    onClicked: {
                        console.log("Current time:", formatTime(oneplayer.mplay.position)); // 打印当前时间
                        currentButton = 3
                    }
                }

                Button {
                    id: button3
                    visible: currentButton === 3
                    text:qsTr("选择该节点作为剪辑的第二个节点")

                 // 格式化时间为秒数
                    function formatTime(milliseconds) {
                    return Math.floor(milliseconds / 1000); // 返回秒数
                   }

                   onClicked: {
                        console.log("Current time:", formatTime(oneplayer.mplay.position)); // 打印当前时间
                        currentButton = 4
                        }
                }

                Button {
                    id: button4
                    text:qsTr("确认")
                    visible: currentButton === 4
                    onClicked: {
                        currentButton = 1
                    }
                }
           }
        }
    }
    Actions{
        id:actions
        open.onTriggered:content.dialog.openfile.open()
        about.onTriggered: dialogs.about.open()
        a.onTriggered:oneplayer.openfile.open()
    }
    Dialogs{
        id:dialogs
    }

}


















