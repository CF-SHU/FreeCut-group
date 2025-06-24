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
    property alias saveCut: _saveCut
    //property alias saveSomeCut: _saveSomeCut //暂时没什么用
    property alias openmusic:_openmusic
    property alias openAddV: _openAddV //画中画添加
    property alias savevideofile:_savevideofile
    property alias about: _about
    property alias mplay:_mplay
    //property alias twoPlay: _twoPlay
    property alias musicplay:_musicplay
    property alias mSlider:_slider // 预览窗口时间轴 Slider
    property string inputPath: ""
    property string outputPath: "/root/output.mp4"
    property string audioOutputPath: ""

    VideoMusic{
        id:vimu
    }
    //mplay，用于预览窗口播放素材的实例化
    MediaPlayer{
        id:_mplay
        videoOutput:out
        audioOutput:AudioOutput{}
        onPositionChanged: {
            if (!mSlider.pressed) { // 仅在用户未拖动滑块时更新
                mSlider.value = _mplay.position;
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

    //musicplay,打开音乐按钮的播放
    MediaPlayer{
        id:_musicplay
        audioOutput: AudioOutput{}
        source:" "
    }
    // 预览窗口时间轴 Slider
    Slider{
        id: _slider
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
    // 显示预览窗口当前时间和总时长
    Row {
        anchors.bottom: _slider.top
        anchors.horizontalCenter: parent.horizontalCenter
        spacing: 10
        Text {
            text: Controller.formatTime(oneplayer.mplay.position)+" / "
                  +Controller.formatTime(oneplayer.mplay.duration)
            color: "white"
        }
    }

    //openfile
    FileDialog{
        id:_openfile
        title: "Select some videos"
        currentFolder: StandardPaths.standardLocations
                       (StandardPaths.DocumentsLocation)[0]
        fileMode: FileDialog.OpenFiles
        nameFilters:["Video files (*.mp4 *.mov *.avi *.mkv *.mp3 *.wav *.flac *.ogg)"]
        onAccepted: {
            _mplay.source = selectedFile
            inputPath = selectedFile.toString().replace("file://", "")
            console.log("输出文件路径:", inputPath)
            //去除openfile.selectedFile的路径中的"file://"
        }
    }

    //保存剪切的视频
    FileDialog{
        id:_saveCut
        title: "Save your cut video"
        currentFolder:StandardPaths.writableLocation(StandardPaths.DocumentsLocation)
        fileMode:FileDialog.SaveFile
        nameFilters:[ "Audio files (*.mp4 *.mov *.avi *.mkv *.mp3 *.wav *.flac *.ogg)" ]
        onAccepted: {
            outputPath = selectedFile.toString().replace("file://", "")
            console.log("输出文件路径:", outputPath)
            Controller.deletefile("/root/wawawawawa")
            Controller.processCut(inputPathPreview,outputPath)
        }
    }

    //保存多次剪切的视频
    /*
    FileDialog{
        id:_saveSomeCut
        title: "Save your cut video"
        currentFolder:StandardPaths.writableLocation(StandardPaths.DocumentsLocation)
        fileMode:FileDialog.SaveFile
        nameFilters:[ "Audio files (*.mp4 *.mov *.avi *.mkv *.mp3 *.wav *.flac *.ogg)" ]
        onAccepted: {
            outputPath = selectedFile.toString().replace("file://", "")
            console.log("输出文件路径:", outputPath)
            //保存文件的函数
            //Controller.savefile()
            Controller.processCut(inputPath1,"/root/wawawawawa/ccc.mp4")
        }
    }
    */

    // savevideofile
    FileDialog{
        id:_savevideofile
        title: "Save your cut video"
        currentFolder:StandardPaths.writableLocation(StandardPaths.DocumentsLocation)
        fileMode:FileDialog.SaveFile
        nameFilters:[ "Audio files (*.mp4 *.mov *.avi *.mkv *.wav)" ]
        onAccepted: {
            outputPath = selectedFile.toString().replace("file://", "")
            vimu.replaceAudio(content.inputPath1,audioOutputPath,outputPath)
            //result.text = success ? "成功！" : "失败！"
            console.log(content.inputPath1)
            console.log(audioOutputPath)
            console.log(outputPath)
        }
    }

    //打开音乐按钮
    FileDialog{
        id:_openmusic
        title: "Select some musics"
        currentFolder: StandardPaths.standardLocations
                       (StandardPaths.DocumentsLocation)[0]
        fileMode: FileDialog.OpenFiles
        nameFilters:["Video files(*.mp3 *.wav *.flac *.ogg)"]
        onAccepted: {
            _musicplay.source = _openmusic.selectedFile
            audioOutputPath = selectedFile.toString().replace("file://", "")
        }
    }
    //添加画中画,只能添加一个文件
    FileDialog{
        id:_openAddV
        title: "Select videos"
        currentFolder: StandardPaths.standardLocations(StandardPaths.DocumentsLocation)[0]
        fileMode: FileDialog.OpenFile
        nameFilters: ["Video files(*mp4 *.mov *.avi *.mkv *.wav)"]
        onAccepted: {
            _twoPlay.source = _openAddV.selectedFile
            _twoPlay.play()
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
