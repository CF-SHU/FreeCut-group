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
    property alias openfile:_openfile
    property alias saveCut: _saveCut
    property alias openAddV:_openAddV
    //property alias saveSomeCut: _saveSomeCut //暂时没什么用
    property alias videoOutput: out
    property alias saveCutmerge: _saveCutmerge
    property alias openmusic:_openmusic
    property alias savevideofile:_savevideofile
    property alias savemergerfile:_savemergerfile
    property alias about: _about
    property alias mplay:_mplay
    property alias musicplay:_musicplay
    property alias mSlider:_slider // 预览窗口时间轴 Slider
    property alias watermark:_watermark//水印
    property alias savewater:_savewater
    property alias savemodel:_savemodel
    property string inputPath: ""
    property string outputPath: "/root/output.mp4"
    property string audioOutputPath: ""

    VideoMusic{
        id:vimu
    }
    VideoMerger{
        id:vm
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
    VideoOutput{
        id:out
        anchors.fill:parent

        property double videoWidthPip: 0.0 //画中画，背景视频的原本宽度
        property double videoHeightPip: 0.0 //画中画，背景视频的原本高度
        property double videoXPip: 0.0 //画中画，背景视频的起点x
        property double videoYPip: 0.0 //画中画，背景视频的起点y

        //视频实际绘制区域的变化
        onContentRectChanged: {
            // 绘制边框以可视化实际视频区域
            videoBorder.width = contentRect.width
            videoBorder.height = contentRect.height
            videoBorder.x = contentRect.x
            videoBorder.y = contentRect.y

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
        }

        // 可视化视频实际区域(紫边框）
        Rectangle {
            id: videoBorder
            color: "transparent"
            border.color: "purple"
            border.width: 2
            visible: true
        }
    }

    Watermark{
        id:_watermark
        position: Qt.point(50, 50) // 初始位置
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

    //打开文件导入素材
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
                filename:fileName1,
            })
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
            Controller.processCut(inputPathPreview,"/root/wawawawawa/ccc.mp4")
        }
    }
    */

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


    //保存合并的视频
    /*
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
 //                // 创建目录
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
*/

    // 保存替换了音频的视频
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
            //result.text = success ? "成功！" : "失败！"
            console.log(content.inputPathPreview)
            console.log(audioOutputPath)
            console.log(outputPath)
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
            _twoPlay.source = _openAddV.selectedFile
            _twoPlay.play()
        }
    }

    //合并两个视频的保存
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
