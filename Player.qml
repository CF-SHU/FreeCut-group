import QtQuick
import QtQuick.Dialogs
import QtCore
import QtMultimedia
import QtQuick.Controls
import Videoclips 1.0
import "control.js" as Controller

Item {
    anchors.fill: parent
    property alias openfile:_openfile
    property alias savefile: _savefile
    property alias openmusic:_openmusic
    property alias musicplay:_musicplay
    property alias savevideofile:_savevideofile
    property alias savemergerfile:_savemergerfile
    property alias about: _about
    property alias mplay:_mplay
    property string inputPath: ""
    property string outputPath: ""
    property string audioOutputPath: ""
   // property alias fixedsave:_fixedsave

    VideoMusic{
        id:vimu
    }

    VideoSegmentMerger{
        id:vi
    }
    FileDialog{
        id:_openfile
        title: "Select some videos"
        currentFolder: StandardPaths.standardLocations
                       (StandardPaths.DocumentsLocation)[0]
        fileMode: FileDialog.OpenFiles
        nameFilters:["Video files(* .mp4,* .flv,* .mkv)"]
        onAccepted: {
            _mplay.source = selectedFile
            inputPath = selectedFile.toString().replace("file://", "")
             console.log("输出文件路径:", inputPath)
            //去除openfile.selectedFile的路径中的"file://"
        }
    }

    FileDialog{
        id:_savefile
        title: "Save your cut video"
        currentFolder:StandardPaths.writableLocation(StandardPaths.DocumentsLocation)
        fileMode:FileDialog.SaveFile
        nameFilters:[ "Audio files (*.mp4 *.oop *.avi *.wav)" ]
        onAccepted: {
            //默认输出路径
            //outputPath = "/root/output.mp4"
            outputPath = selectedFile.toString().replace("file://", "")
            console.log("输出文件路径:", outputPath)

            //保存文件的函数
        //   console.log("输入文件路径:",)
            Controller.savefile()

           // Controller.processCut();
        }

    }

 //    FileDialog{
 //        id:_fixedsave
 //        title: "Save your cut video"
 //        currentFolder: StandardPaths.writableLocation(StandardPaths.DocumentsLocation) + "/wawawawawa" // 固定目录
 //        fileMode:FileDialog.SaveFile
 //        nameFilters:[ "Audio files (*.mp4 *.oop *.avi *.wav)" ]
 //        onAccepted: {
 //            //默认输出路径

 //            // 确保目录存在（如果不存在则创建）
 //            var fixedFolder = StandardPaths.writableLocation(StandardPaths.DocumentsLocation) + "/wawawawawa";
 //            var directory = Qt.createQmlObject('import QtQuick 2.0; Item {}', parent);
 //            var folder = Qt.resolvedUrl(fixedFolder);
 //            var file = new XMLHttpRequest();
 //            file.open("HEAD", folder, false);
 //            file.send();

 //            if (file.status !== 200) {
 //                // 创建目录（简单示例，实际可能需要更健壮的实现）
 //                var createFolderCommand = "mkdir -p \"" + fixedFolder + "\"";
 //                Qt.callLater(function() {
 //                    Qt.openUrlExternally("sh", "-c " + createFolderCommand);
 //                });
 //            }

 //            // 固定输出路径
 //            outputPath = fixedFolder + "/output.mp4"; // 固定文件名
 //            console.log("输出文件路径:", outputPath);

 //            // 模拟保存操作（实际可能需要调用 C++ 函数）
 //            // 这里假设保存成功，直接更新播放器源
 //            oneplayer.mplay.source = outputPath;
 //            oneplayer.mplay.play();

 //            console.log("输出文件路径:", outputPath)
 //        }

 //    }

    FileDialog{
        id:_savevideofile
        title: "Save your cut video"
        currentFolder:StandardPaths.writableLocation(StandardPaths.DocumentsLocation)
        fileMode:FileDialog.SaveFile
        nameFilters:[ "Audio files (*.mp4 *.wav)" ]
        onAccepted: {
            outputPath = selectedFile.toString().replace("file://", "")
            //outputPath = "/root/实训/out.mp4"
            //outputPath = "/root/out.mp4"
            //console.log("输出文件路径:", path)
                vimu.replaceAudio(content.inputPath1,audioOutputPath,outputPath)
                //result.text = success ? "成功！" : "失败！"
                console.log(content.inputPath1)
                console.log(audioOutputPath)
                console.log(outputPath)

        }
    }

    FileDialog{
        id:_openmusic
        title: "Select some musics"
        currentFolder: StandardPaths.standardLocations
                       (StandardPaths.DocumentsLocation)[0]
        fileMode: FileDialog.OpenFiles
        nameFilters:["Video files(* .mp3,* .wav,* .mp4,* .flv,* .mkv)"]
        onAccepted: {
            _musicplay.source = _openmusic.selectedFile
            audioOutputPath = selectedFile.toString().replace("file://", "")
        }
    }

    FileDialog{
        id:_savemergerfile
        title: "Save your merger video"
        currentFolder:StandardPaths.writableLocation(StandardPaths.DocumentsLocation)
        fileMode:FileDialog.SaveFile
        nameFilters:[ "Audio files (*.mp4 *.oop *.avi *.wav)" ]
        onAccepted: {
            //outputPath = "/root/output.mp4"
            outputPath = selectedFile.toString().replace("file://", "")
            console.log("输出文件路径:", outputPath)
            vi.mergeTwoSegments(content.videoCPath[0],content.fromTimes[0],content.toTimes[0],content.videoCPath[1],content.fromTimes[1],content.toTimes[1],outputPath)
        }

    }
    MediaPlayer{
        id:_mplay
        videoOutput:out
        audioOutput:AudioOutput{}
        onPositionChanged: {
            if (!slider.pressed) { // 仅在用户未拖动滑块时更新
                slider.value = _mplay.position;
                //console.log("Current position:", formatTime(_mplay.position)); // 实时打印当前时间
            }
        }
        onDurationChanged: {
            console.log("Video duration:", Controller.formatTime(_mplay.duration)); // 调试输出视频时长
        }
        onPlayingChanged: {
            if(_mplay.playing === true){
                _musicplay.play()
                _musicplay.position = _mplay.position
            }else{
                _musicplay.pause()
            }
        }
    }

    VideoOutput{
        id:out
        anchors.fill:parent
    }

    MediaPlayer{
        id:_musicplay
        audioOutput: AudioOutput{}
        source:" "
    }

    // 时间轴 Slider
    Slider{
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
            text: Controller.formatTime(_mplay.position)+" / "
                  +Controller.formatTime(_mplay.duration)
            color: "white"
        }
    }

    MessageDialog{
        id:_about
        modality: Qt.WindowModal
        buttons:MessageDialog.Ok
        text:"This is a simple vidio editor."
        informativeText: qsTr("小组项目，一个简单的仿剪映的剪切视频软件")
        detailedText: "Copyright©2025  CHW (@qq.com)"
    }

}
