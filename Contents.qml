import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtMultimedia
import "control.js" as Controller
import QtQuick.Dialogs
import QtCore
import Videoclips 1.0

Item {

    property alias dialog:_dialog
    property int currentPlayingIndex: -1
    property alias mplay:_mplay
    property string inputPath1: ""
    property var videoCPath: [" ", " ", " "," "," "]
    property var videoQPath: [" ", " ", " "," "," "]
    property int a: 0
    property var fromTimes:[0,0,0,0,0]
    property var toTimes:[0,0,0,0,0]
    ListModel{
        id:videoModel
    }
    Player{
        id:_dialog
        openfile{
            onRejected:{
                return;
            }//also OK!

            onAccepted: {
                let selectfilePath = openfile.selectedFiles;
                for(let i = 0; i < selectfilePath.length; ++i){
                    const filePath = selectfilePath[i]
                    _mplay.source = filePath
                    //vvvv.source = filePath
                    const fileName = filePath.toString().split('/').pop().replace(/\.[^/.]+$/, "")
                    //将路径字符串按斜杠
                    videoModel.append({
                        title: fileName,
                        filePath: filePath,
                    })
                    console.log("Videos path: ",filePath)
                }
            }
        }
    }

ColumnLayout{
   anchors.fill: parent
   spacing: 0 // 移除间距使布局更紧凑

    RowLayout{
        anchors.fill: parent
        height: parent.height -bottomRect.height
        spacing: 0 // 移除间距

        Rectangle{
            id:left
           Layout.preferredWidth: parent.width * 0.15
           Layout.preferredHeight: parent.height - bottomRect.height
            color: "green"

            ListView{
                id:videoList
                anchors.fill:parent
                spacing:5

                ScrollBar.vertical: ScrollBar {
                    policy: ScrollBar.AsNeeded
                }

                model: videoModel  // 绑定到全局 videoModel
                delegate:Rectangle{
                    id:rec
                    width:videoList.width
                    height:(videoList.height / 10)
                    border.color: "lightblue"
                    radius: 5 //添加圆角半径
                    color:{
                        if (currentPlayingIndex === index) {
                            return "lightblue" // 播放状态颜色
                        } else {
                            index % 2 === 0 ? "lightgrey" : "white"
                        }
                    }
                    Video{
                        id:_vvvv
                        anchors.fill: parent
                        source: model.filePath
                        autoPlay: true
                        muted: true
                        loops: MediaPlayer.Infinite
                        onPlaybackStateChanged: {
                            seek(100)
                            pause()
                        }
                    }


                    TapHandler {
                        onTapped: {
                            content.currentPlayingIndex = index
                            console.log("now music index & currentPlayingIndex is ",index,content.currentPlayingIndex)
                            _mplay.source = model.filePath
                            _mplay.play()
                        }
                        onDoubleTapped:{
                            if(content.currentPlayingIndex===index){
                                if (_mplay.playbackState === MediaPlayer.PlayingState) {
                                    _mplay.pause()
                                }
                            }
                        }
                    }

                    // 添加颜色过渡动画
                    Behavior on color {
                        ColorAnimation { duration: 1500 }
                    }
                }

                //添加动画
                add: Transition {
                    NumberAnimation { property: "opacity"; from: 0; to: 1; duration: 2000 }
                }//透明度动画
            }
        }
        Rectangle{
            id:mid

           Layout.preferredWidth: parent.width * 0.35
           Layout.preferredHeight: left.height
            color: "blue"

            Column{
                anchors.fill: parent
                ToolBar
                {
                    id:tool
                    RowLayout{
                        ToolButton{action:act.start}
                        ToolButton{action:act.pause}
                        ToolButton{action:act.stop}
                    }
                }

                Rectangle{
                    width: parent.width
                    height: parent.height
                    MediaPlayer{
                        id:_mplay
                        videoOutput:out
                        audioOutput:AudioOutput{}
                        //autoPlay: true
                    }
                    VideoOutput{
                        id:out
                        anchors.fill:parent
                    }

                }

            }

            // // 格式化时间为 mm:ss
            // function formatTime(milliseconds) {
            //     var seconds = milliseconds / 1000;
            //     var minutes = Math.floor(seconds / 60);
            //     seconds = Math.floor(seconds % 60);
            //     return minutes + ":" + (seconds < 10 ? "0" : "") + seconds;
            // }

            // 时间轴 Slider
               Slider {
                   id: slider
                   anchors.bottom: parent.bottom
                   anchors.horizontalCenter: parent.horizontalCenter
                   width: parent.width - 40 // 留出一些边距
                   from: 0
                   to: _mplay.duration > 0 ? _mplay.duration : 1000 // 默认值为 1000 毫秒（1 秒），避免为 0
                   value: _mplay.position
                   stepSize: 1000 // 步长为 1 秒

                   // 当用户拖动 Slider 时，跳转到视频的相应位置
                   onValueChanged: {
                       if (pressed) { // 仅在用户拖动滑块时更新
                           console.log("Slider value changed to:", value); // 调试输出
                           _mplay.position = value; // 使用 position 属性跳转
                       }
                   }
               }

               // 显示当前时间和总时长
               Row {
                   anchors.bottom: slider.top
                   anchors.horizontalCenter: parent.horizontalCenter
                   spacing: 10

                   Text {
                       text: Controller.formatTime(_mplay.position)
                       color: "white"
                   }

                   Text {
                       text: "/"
                       color: "white"
                   }

                   Text {
                       text: Controller.formatTime(_mplay.duration)
                       color: "white"
                   }
               }
        }

       Rectangle{
               id:rightRect
              Layout.preferredWidth: parent.width * 0.5
              Layout.preferredHeight: left.height
               color:"black"
               border.color:"black"

               // 添加一个属性来控制select按钮的可见性
                 property bool showSelectButton: true

               Player{
                   id:oneplayer
               }

               ToolBar
               {
                   RowLayout
                   {
                      // ToolButton{action:act.a}//open
                       ToolButton{action:act.aa}//start
                       ToolButton{action:act.bb}//pause
                       ToolButton {
                                      action: act.cc // stop
                                      // 添加停止按钮点击后的处理
                                      onClicked: {
                                          rightRect.showSelectButton = true // 显示select按钮
                                          // 原有的停止逻辑
                                          oneplayer.mplay.stop()
                                      }
                                  }
                   }
               }
               Button
               {
                   id:select
                   x:50
                   y:50
                   height:100
                   width:100
                   visible: rightRect.showSelectButton // 绑定可见性到属性
                   onClicked:
                   {
                      dialog.open()
                   }
               }

               Dialog {
                   id: dialog
                   width: 300
                   height: 200
                   modal: true
                   title: "请选择进行剪辑的视频"

                   Rectangle{
                      id:popup
                      // width: (parent.width / 3.8)
                      // height: parent.height
                      anchors.fill: parent
                      color: "green"

                   ListView{
                       id:videoList2
                       anchors.fill:parent
                       spacing:5

                       ScrollBar.vertical: ScrollBar {
                           policy: ScrollBar.AsNeeded
                       }

                       model:videoModel

                       delegate:Rectangle{
                           id:rec2
                           width:(videoList2.width/2)
                           height:(videoList2.height / 5)
                           border.color: "lightblue"
                           radius: 5 //添加圆角半径
                           color:{
                               if (currentPlayingIndex === index) {
                                   return "lightblue" // 播放状态颜色
                               } else {
                                   index % 2 === 0 ? "lightgrey" : "white"
                               }
                           }

                           Video{
                               id:_vvvv2
                               anchors.fill: parent
                               source: model.filePath
                               autoPlay: true
                               muted: true
                               loops: MediaPlayer.Infinite
                               onPlaybackStateChanged: {
                                   seek(100)
                                   pause()
                               }
                           }


                           TapHandler {
                               onTapped: {
                                   console.log("Tapped filePath:", model.filePath); // 调试输出
                                   content.currentPlayingIndex = index
                                   console.log("now music index & currentPlayingIndex is ",index,content.currentPlayingIndex)
                                   oneplayer.mplay.source = model.filePath
                                   inputPath1 = model.filePath.toString().replace("file://", "")
                                   oneplayer.mplay.play()
                                   rightRect.showSelectButton = false // 隐藏select按钮
                                   dialog.close() // 关闭对话框
                               }
                           }

                           // 添加颜色过渡动画
                           Behavior on color {
                               ColorAnimation { duration: 1500 }
                           }
                       }

                       //添加动画
                       add: Transition {
                           NumberAnimation { property: "opacity"; from: 0; to: 1; duration: 2000 }
                       }//透明度动画
                   }
               }
           }

        }
  //  }
}
    VideoCutter {
        id: cutter
        onProgressChanged: {
            progressBar.value = percent
            progressLabel.text = percent + "%"
        }
        onFinished: (success, error) => {
            console.log("剪切结果:", success, error)
            resultText.text = success ? "剪切成功!" : "失败: " + error
            resultText.color = success ? "green" : "red"
            progressBar.visible = false
        }
    }

    Rectangle{
        id:bottomRect
       Layout.fillWidth: true
       Layout.preferredHeight: parent.height * 0.5 // 下半部分占50%高度
        color:"pink"
        border.color:"pink"

    // 时间轴 Slider
        Slider {
           id: slider2
           y:50
           anchors.centerIn: parent.centerIn
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
           anchors.bottom: slider2.top
           anchors.horizontalCenter: parent.horizontalCenter
           spacing: 10
           Text {
               text: Controller.formatTime(oneplayer.mplay.position)+" / "
                     +Controller.formatTime(oneplayer.mplay.duration)
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
                    cutter.getStartSec(formatTime(oneplayer.mplay.position));
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
                    cutter.getEndSec(formatTime(oneplayer.mplay.position));
                                  currentButton = 4
               }
            }

            Button {
               id: button4
               text:qsTr("确认")
               visible: currentButton === 4
               onClicked: {
                 //  console.log("test cut path: ",oneplayer.inputPath)


                   //选择指定路径保存
                   // oneplayer.savefile.open()
                   // progressBar.visible = true
                   // progressBar.value = 0
                   // resultText.text = "处理中..."
                   // resultText.color = "blue"

                   //  //保存到固定的的目录
                   //  var filepath= model.filePath

                   //保存到固定的的目录
                   var outputPath="/root/wawawawawa/ccc.mp4"
                   Controller.processCut(inputPath1,outputPath)
                  // cutter.cutVideo(oneplayer.mplay.inputPath,outputPath,cutter.returnStartSec(), cutter.returnEndSec()-cutter.returnStartSec())

                   //将视频路径给oneplayer播放器
                   oneplayer.mplay.stop()//结束上一个视频的播放
                   oneplayer.mplay.source = "file:///root/wawawawawa/ccc.mp4"
                   oneplayer.mplay.play()

                   currentButton = 1
               }
            }


            ProgressBar {
                id: progressBar
                visible: false
                width: 200
                height: 20
                from: 0
                to: 100
                value: 0
                Label {
                    id: progressLabel
                    anchors.centerIn: parent
                    text: "0%"
                }
           }

           Text {
               id: resultText
               font.pixelSize: 14
               width: 300
           }
       }



        Button{
            id:cutaudio
            text:"关闭原声"
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: parent.left
            onClicked: {
                oneplayer.mplay.audioOutput.muted = true
                noti.notification.show("已关闭原声")
            }
        }
        Button{
           id:openaudio
           anchors.top:cutaudio.bottom
           text:"打开原声"
           onClicked: {
               oneplayer.mplay.audioOutput.muted = false
               noti.notification.show("已打开原声")
           }
        }
        Button{
            id:music
            anchors.bottom: cutaudio.top
            text:"插入音频"
            onClicked: {
               oneplayer.openmusic.open()
            }
        }
        Button{
           id:ouput
           anchors.top: openaudio.bottom
           text:"导出视频"
           onClicked: {
               oneplayer.savevideofile.open()
           }
        }
        Button{
           id:savefileto
           anchors.top: openaudio.bottom
           text:"保存剪辑好的视频"
           onClicked: {

               //选择指定路径保存
               oneplayer.savefile.open()
               progressBar.visible = true
               progressBar.value = 0
               resultText.text = "处理中..."
               resultText.color = "blue"

               //删除前面产生的临时视频文件

               //Controller.deletedir("/root/wawawawawa")
           }
        }
        Button{
          id:mer1
          text:"选择要合并的视频"
          z:2
          anchors.top: ouput.bottom
          onClicked: {
            dialog2.open()
            mer2.z = 2
          }
        }

        Button {
           id: mer2
           z:1
           text:qsTr("选择第一个节点")
           anchors.top: mer1.top
           onClicked: {
               z = 1
               mer3.z = 2
               fromTimes[a] = oneplayer.mplay.position
               console.log("时间点1:",fromTimes[a])
           }
        }

        Button {
           id: mer3
           text:qsTr("选择第二个节点")
           anchors.top: mer1.top
           onClicked: {
               z=0
              toTimes[a] = oneplayer.mplay.position
              console.log("时间点2:",toTimes[a])
             a++
           }
        }

        Button{
          id:mer4
          text:"预览剪辑好的视频"
          anchors.top: mer1.bottom
          onClicked: {
            oneplayer.savemergerfile.open()
          }
        }

        Dialog{
          id: dialog2
          width: 300
          height: 200
          modal: true
          title: "请选择进行剪辑的视频"

          Rectangle{
             id:popup2
             // width: (parent.width / 3.8)
             // height: parent.height
             anchors.fill: parent
             color: "green"

          ListView{
              id:videoList3
              anchors.fill:parent
              spacing:5

              ScrollBar.vertical: ScrollBar {
                  policy: ScrollBar.AsNeeded
              }

              model:videoModel

              delegate:Rectangle{
                  id:rec3
                  width:(videoList2.width)
                  height:(videoList2.height / 2)
                  border.color: "lightblue"
                  radius: 5 //添加圆角半径
                  color:{
                      if (currentPlayingIndex === index) {
                          return "lightblue" // 播放状态颜色
                      } else {
                          index % 2 === 0 ? "lightgrey" : "white"
                      }
                  }

                  Video{
                      id:_vvvv3
                      //anchors.fill: parent
                      anchors.left: parent.left
                      width: parent.width/2
                      height: parent.height
                      source: model.filePath
                      autoPlay: true
                      muted: true
                      loops: MediaPlayer.Infinite
                      onPlaybackStateChanged: {
                          seek(100)
                          pause()
                      }
                  }

                  TapHandler {
                      onTapped: {
                          console.log("Tapped filePath:", model.filePath); // 调试输出
                          content.currentPlayingIndex = index
                          console.log("now music index & currentPlayingIndex is ",index,content.currentPlayingIndex)
                          oneplayer.mplay.source = model.filePath
                          videoCPath[a] = model.filePath.toString().replace("file://", "")
                          videoQPath[a] = model.filePath
                          console.log(a,videoQPath[a])
                          oneplayer.mplay.play()
                          rightRect.showSelectButton = false
                          dialog2.close() // 关闭对话框
                      }
                  }

                  // 添加颜色过渡动画
                  Behavior on color {
                      ColorAnimation { duration: 1500 }
                  }
              }

              //添加动画
              add: Transition {
                  NumberAnimation { property: "opacity"; from: 0; to: 1; duration: 2000 }
              }//透明度动画
          }
      }
    }

    }
}

   // }

    Actions{
        id:act

        a.onTriggered:oneplayer.openfile.open()
        aa.onTriggered: oneplayer.mplay.play()
        bb.onTriggered: oneplayer.mplay.pause()
        cc.onTriggered: {
                oneplayer.mplay.stop()
                rightRect.showSelectButton = true // 确保停止按钮也显示select按钮
            }
    }
    Notification{
        id:noti
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
    }

}
