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
    property alias about: _about

    FileDialog{
        id:_openfile
        title: "Select some videos"
        currentFolder: StandardPaths.standardLocations
                       (StandardPaths.DocumentsLocation)[0]
        fileMode: FileDialog.OpenFiles
        nameFilters:["Video files(* .mp4,* .flv,* .mkv)"]

    }


    MessageDialog{
        id:_about
        modality: Qt.WindowModal
        buttons:MessageDialog.Ok
        text:"This is a simple vidio editor."
        informativeText: qsTr("")
        //请将下面的信息修改为你自己的名字和邮件
        detailedText: "Copyright©2025  CHW (@qq.com)"
    }
}


















