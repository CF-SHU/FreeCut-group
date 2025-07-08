//Player.qml
import QtQuick
import QtQuick.Dialogs
import QtCore
import QtMultimedia
import QtQuick.Controls
import Videoclips 1.0
import "control.js" as Controller

Item {
    anchors.fill: parent
    property alias musicplay:_musicplay //MediaPlayer实例化,打开音乐按钮的播放
    property alias mSlider:_slider // 预览窗口时间轴 Slider
    property alias watermark:_watermark//水印

    property alias about: _about
    property alias mplay:_mplay //mplay，用于预览窗口播放素材的实例化
    property alias videoOutput: out

    property alias openAddV:_openAddV //添加画中画,只能添加一个文件
    property alias openmusic:_openmusic //打开音乐按钮

    property alias saveCutmerge: _saveCutmerge //保存一个视频的切片合并的视频
    property alias saveCut: _saveCut //保存剪切的视频
    property alias savewater:_savewater //保存水印视频
    property alias savevideofile:_savevideofile //保存替换了音频的视频
    property alias savemergerfile:_savemergerfile //合并两个视频的保存，必须是相同的文件

    property alias savemodel:_savemodel //ListModel

    property alias openfile:_openfile //打开文件导入素材？？_mplay.source


    property string inputPath: ""
    property string outputPath: "/root/output.mp4"
    property string audioOutputPath: "" //替换了音频的视频，调用命令行需要用到的音频路径

    //C++类
    //替换视频中的音频
    VideoMusic{
        id:vimu
    }
    VideoMerger{
        id:vm
    }
    Watermark{
        id:_watermark
        position: Qt.point(50, 50) // 初始位置
    }

    ListModel{
        id:_savemodel
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
    //预览窗口处理画中画分辨率和拖动范围
    VideoOutput{
        id:out
        anchors.fill:parent

        property double videoWidthPip: 0.0 //画中画，背景视频的原本宽度
        property double videoHeightPip: 0.0 //画中画，背景视频的原本高度
        property double videoXPip: 0.0 //画中画，背景视频的起点x
        property double videoYPip: 0.0 //画中画，背景视频的起点y

        //视频实际绘制区域的变化
        onContentRectChanged: {
            //绘制边框以可视化实际视频区域
            videoBorder.width = contentRect.width
            videoBorder.height = contentRect.height
            videoBorder.x = contentRect.x
            videoBorder.y = contentRect.y

            //获取画中画所需数值
            videoWidthPip = contentRect.width
            videoHeightPip = contentRect.height
            videoXPip = contentRect.x
            videoYPip = contentRect.y
        }

        function drag(addVideo){
            addVideo.x = Math.max(videoXPip,Math.min(addVideo.x, videoWidthPip-addVideo.width))
            addVideo.y = Math.max(videoYPip,Math.min(addVideo.y, videoHeightPip-addVideo.height))
            console.log("x,y drag: ",addVideo.x,addVideo.y)
            return videoWidthPip/sourceRect.width
        }//限制画中画拖动范围，返回背景视频的分辨率

        // 可视化视频实际区域(紫边框）
        Rectangle {
            id: videoBorder
            color: "transparent"
            border.color: "purple"
            border.width: 2
            visible: true
        }
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
                _musicplay.position = value
            }
        }
    }
    // 显示预览窗口当前时间和总时长，即显示时间轴的数值变化
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

    //打开文件导入素材？？_mplay.source
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
            //去除openfile.selectedFile的路径中的"file://"
            console.log("输出文件路径:", inputPath)
        }
    }

    //保存一个视频的切片合并的视频
    FileDialog{
        id:_saveCutmerge
        title: "Save your cut video"
        currentFolder:StandardPaths.writableLocation(StandardPaths.DocumentsLocation)
        fileMode:FileDialog.SaveFile
        nameFilters:[ "Audio files (*.mp4  *.avi *.mkv )" ]
        onAccepted: {
            outputPath = selectedFile.toString().replace("file://", "")
            console.log("输出文件路径:", outputPath)
            vcm.mergeVideos(outputPath)

            const fileName1 = selectedFile.toString().split('/').pop().replace(/\.[^/.]+$/, "")
            savemodel.append({
                filepath:selectedFile,
                filename:fileName1,
                filecpath:outputPath
            })
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
            Controller.processCut(inputPathPreview,outputPath)
            Controller.deletefile("/root/wawawawawa")

            const fileName1 = selectedFile.toString().split('/').pop().replace(/\.[^/.]+$/, "")
            savemodel.append({
                filepath:selectedFile,
                filename:fileName1
            })
        }
    }

    //保存添加水印的视频
    FileDialog{
        id:_savewater
        title: "Save your cut video which has be added watermark"
        currentFolder:StandardPaths.writableLocation(StandardPaths.DocumentsLocation)
        fileMode:FileDialog.SaveFile
        nameFilters:[ "Audio files (*.mp4 *.mov *.avi *.mkv *.mp3 *.wav *.flac *.ogg)" ]
        onAccepted: {
            outputPath = selectedFile.toString().replace("file://", "")
            console.log("输出文件路径:", outputPath)
            const fileName1 = selectedFile.toString().split('/').pop().replace(/\.[^/.]+$/, "")
            watermark.addTextWatermarkToVideo(inputPathPreview,outputPath,_watermark.text,_watermark.color,_watermark.size,_watermark.alpha)

            savemodel.append({
                filepath:selectedFile,
                filename:fileName1,
                filecpath:outputPath
            })
        }
    }

    //保存替换了音频的视频
    FileDialog{
        id:_savevideofile
        title: "Save your cut video"
        currentFolder:StandardPaths.writableLocation(StandardPaths.DocumentsLocation)
        fileMode:FileDialog.SaveFile
        nameFilters:[ "Audio files (*.mp4 *.mov *.avi *.mkv *.wav)" ]
        onAccepted: {
            outputPath = selectedFile.toString().replace("file://", "")
            const fileName1 = selectedFile.toString().split('/').pop().replace(/\.[^/.]+$/, "")
            vimu.replaceAudio(content.inputPathPreview,audioOutputPath,outputPath)

            ouput.checked = false //让导入视频的按钮变为not checked
            savemodel.append({
                filepath:selectedFile,
                filename:fileName1,
                filecpath:outputPath
            })
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
            _pipPlay.source = _openAddV.selectedFile
            _pipPlay.play()
        }//_pipPlay实例化在contents.qml中
    }

    //合并两个视频的保存，必须是相同的文件
    FileDialog{
        id:_savemergerfile
        title: "Save your merger video"
        currentFolder:StandardPaths.writableLocation(StandardPaths.DocumentsLocation)
        fileMode:FileDialog.SaveFile
        nameFilters:[ "Audio files (*.mp4 *.oop *.avi *.wav)" ]
        onAccepted: {
            outputPath = selectedFile.toString().replace("file://", "")
            console.log("输出文件路径:", outputPath)
            console.log("第一个视频：",content.mergePath1)
            console.log("第一个视频：",content.mergePath2)
            vm.mergeVideos(content.mergePath1,content.mergePath2,outputPath)

            const fileName1 = selectedFile.toString().split('/').pop().replace(/\.[^/.]+$/, "")
            savemodel.append({
                filepath:selectedFile,
                filename:fileName1,
                filecpath:outputPath
            })
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
