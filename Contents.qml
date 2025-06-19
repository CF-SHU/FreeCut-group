import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtMultimedia

Item {
    property alias dialog:_dialog
    property int currentPlayingIndex: -1
    property alias mplay:_mplay

    Dialogs{
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

    Row{
        anchors.fill: parent
        Rectangle{
            id:left
            width: (parent.width / 3.8)
            height: parent.height
            color: "green"
            ListView{
                id:videoList
                anchors.fill:parent
                spacing:5

                ScrollBar.vertical: ScrollBar {
                    policy: ScrollBar.AsNeeded
                }
                model:ListModel{
                    id:videoModel
                }

                delegate:Rectangle{
                    id:rec
                    width:videoList.width
                    height:(videoList.height / 5)
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

                    // Text {
                    //     id:tt
                    //     anchors.right: parent.right
                    //     text:model.title
                    //     anchors.fill: parent
                    //     anchors.margins:10 //在矩形四周留白10
                    //     elide: Text.ElideRight
                    // }
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
            id:right
            width: parent.width - left.width
            height: parent.height
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

            // 格式化时间为 mm:ss
            function formatTime(milliseconds) {
                var seconds = milliseconds / 1000;
                var minutes = Math.floor(seconds / 60);
                seconds = Math.floor(seconds % 60);
                return minutes + ":" + (seconds < 10 ? "0" : "") + seconds;
            }

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
                       text: formatTime(_mplay.position)
                       color: "white"
                   }

                   Text {
                       text: "/"
                       color: "white"
                   }

                   Text {
                       text: formatTime(_mplay.duration)
                       color: "white"
                   }
               }
        }
    }
    Actions{
        id:act
    }
}
