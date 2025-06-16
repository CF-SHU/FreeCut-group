//Dialogs.qml
import QtQuick
import QtQuick.Dialogs
import QtCore

Item {
    property alias fileOpen: _open
    property alias openFail:_openFail
    property alias about: _about

    FileDialog{
        id:_open
        title:qsTr("Select some video files")
        currentFolder: StandardPaths.standardLocations
                       (StandardPaths.DocumentsLocation)[0]
        fileMode: FileDialog.OpenFile
        nameFilters: [ "Video files (*mp4 *.mkv *.avi)" ]
    }

    MessageDialog{
        id:_openFail
        text:qsTr("FreeCut 0.1")
        modality:Qt.WindowModal
        informativeText:qsTr("Fail to open file!")
    }

    MessageDialog{
        id:_about
        text:qsTr("FreeCut 0.1")
        buttons:MessageDialog.Ok
        modality:Qt.WindowModal
        informativeText:qsTr("Copyright © cm\nFreeCut is a simplistic video player & cutter.")
    }
}
