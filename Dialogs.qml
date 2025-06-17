import QtQuick
import QtQuick.Dialogs
import QtCore
import QtMultimedia
import QtQuick.Controls
import Videoclips 1.0

Item {
    anchors.fill: parent
    property alias openfile:_openfile
    property string path:""

    Button{
        id:_play
        y:100
        width:200
        height:200
        text:qsTr("点我播放")
        onClicked:{
            _mplay.play()
            //vplay.play(path)
        }
    }
    FileDialog{
        id:_openfile
        title: "Select some videos"
        currentFolder: StandardPaths.standardLocations
                       (StandardPaths.DocumentsLocation)[0]
        fileMode: FileDialog.OpenFiles
        nameFilters:["Video files(* .mp4,* .flv,* .mkv)"]
        onAccepted: {
            console.log(openfile.selectedFile)
            //path = openfile.selectedFile.toString().replace("file://", "")
            _mplay.source = openfile.selectedFile
        }
    }
    VideoPlay{
        id:vplay
    }

    MediaPlayer{
        id:_mplay
        videoOutput:out
        audioOutput:AudioOutput{}
        // onMediaStatusChanged:{
        //     if(_mplay.mediaStatus === MediaPlayer.LoadedMedia){
        //         console.log("视频加载成功")
        //     }else if(_mplay.mediaStatus === MediaPlayer.InvalidMedia){
        //         console.log("视频加载失败")
        //     }
        // }
    }
    VideoOutput{
        id:out
        anchors.fill:parent
    }

}
