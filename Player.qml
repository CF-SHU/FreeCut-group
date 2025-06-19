import QtQuick
import QtQuick.Dialogs
import QtCore
import QtMultimedia
import QtQuick.Controls
import Videoclips 1.0

Item {
    anchors.fill: parent
    property alias openfile:_openfile
    property alias savefile: _savefile
    property alias mplay:_mplay
    property string inputPath: ""
    property string outputPath: ""

    // Button{
    //     id:_play
    //     y:100
    //     width:200
    //     height:200
    //     text:qsTr("点我播放")
    //     onClicked:{
    //         _mplay.play()
    //         visible = false
    //     }
    // }
    FileDialog{
        id:_openfile
        title: "Select some videos"
        currentFolder: StandardPaths.standardLocations
                       (StandardPaths.DocumentsLocation)[0]
        fileMode: FileDialog.OpenFiles
        nameFilters:["Video files(* .mp4,* .flv,* .mkv)"]
        onAccepted: {
            //inputPath = selectedFile.toString().replace("file://", "")
            outputPath = "/root/output.mp4"
            //去除openfile.selectedFile的路径中的"file://"
            //console.log("openfile path: ",inputPath)
            _mplay.source = selectedFile
            inputPath = selectedFile.toString().replace("file://", "")
        }
    }
    FileDialog{
        id:_savefile
        title: "Save your cut video"
        currentFolder:StandardPaths.writableLocation(StandardPaths.DocumentsLocation)
        fileMode:FileDialog.SaveFile
        nameFilters:[ "Audio files (*.mp3 *.oop *.mp4 *.wav)" ]
        onAccepted: {
            outputPath = selectedFile.toString().replace("file://", "")
            console.log("输出文件路径:", path)
        }
    }

    MediaPlayer{
        id:_mplay
        videoOutput:out
        audioOutput:AudioOutput{}
        onPositionChanged: {
            if (!slider.pressed) { // 仅在用户未拖动滑块时更新
                slider.value = _mplay.position;
                console.log("Current position:", formatTime(_mplay.position)); // 实时打印当前时间
            }
        }
        onDurationChanged: {
            console.log("Video duration:", formatTime(_mplay.duration)); // 调试输出视频时长
        }

    }
    VideoOutput{
        id:out
        anchors.fill:parent
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
