import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtMultimedia
import "control.js" as Controller
import QtQuick.Dialogs
import QtCore
import Videoclips 1.0

Item {
    property alias dialog:_dialog//
    property int currentPlayingIndex: -1
    property alias mplay:_mplay //素材视频/音频的播放
    property string inputPath1: ""

    ListModel{
        id:videoModel
    }

    //videoModel dialog openfiles:
    Player{
        id:_dialog
        openfile{
            onRejected:{
                return;
            }
            onAccepted: {
                let selectfilePath = openfile.selectedFiles;
                for(let i = 0; i < selectfilePath.length; ++i){
                    const filePath = selectfilePath[i]
                    _mplay.source = filePath
                    let mediaTypeFlag = Controller.detectMediaType(filePath);
                    const fileName = filePath.toString().split('/').pop().replace(/\.[^/.]+$/, "")
                    videoModel.append({
                        title: fileName,
                        filePath: filePath,
                        mediaType: mediaTypeFlag
                    })
                    console.log("Videos path: ",filePath)
                }
            }
        }
    }

    ColumnLayout{
        anchors.fill: parent
        spacing: 0 // 移除间距使布局更紧凑 ？原本是10？

        //上面三个窗口的排列
        RowLayout{
            anchors.fill: parent
            height: parent.height -bottomRect.height
            spacing: 0 // 移除间距

            //素材导入窗口
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

                    //delegate
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

                        //视频第一帧显示：素材的视频
                        /*
                        Loader {
                            active: model.mediaType === "video"
                            // anchors {
                            //     right: parent.right
                            //     rightMargin: 10
                            //     verticalCenter: parent.verticalCenter
                            // }

                            sourceComponent: Component {
                                Video {
                                    id: _vvvv
                                    anchors.fill: parent
                                    source: model.filePath
                                    autoPlay: true
                                    muted: true
                                    loops: MediaPlayer.Infinite

                                    onPlaybackStateChanged: {
                                        if (playbackState === MediaPlayer.PlayingState) {
                                            // 播放到特定位置后暂停（作为缩略图）
                                            seek(100)
                                            pause()
                                        }
                                    }
                                }

                            }
                        }
                        */
                        //文本显示：素材音频的标题
                        Loader{
                            active: model.mediaType === "audio"
                            anchors {
                                rightMargin: 10
                                verticalCenter: parent.verticalCenter // 垂直居中
                                horizontalCenter: parent.horizontalCenter // 水平居中
                            }
                            sourceComponent: Component{
                                Text{
                                    id:audioText
                                    text:model.title
                                    color:"green"
                                    font.bold: true
                                    horizontalAlignment: Text.AlignHCenter
                                }
                            }
                        }

                        //视频第一帧显示：素材的视频
                        Video {
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

                        //单击素材播放，双击素材暂停
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
                            ColorAnimation { duration: 1000 }
                        }
                    }

                    //添加动画
                    add: Transition {
                        NumberAnimation { property: "opacity"; from: 0; to: 1; duration: 2000 }
                    }//透明度动画
                }
            }
            //素材播放窗口
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
                        color: "blue"
                        MediaPlayer{
                            id:_mplay
                            videoOutput:out
                            audioOutput:AudioOutput{}
                        }
                        VideoOutput{
                            id:out
                            anchors.fill:parent
                        }
                    }
                }

                //素材播放的时间轴 Slider
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
                        text: Controller.formatTime(_mplay.position)+" / "
                                +Controller.formatTime(_mplay.duration)
                        color: "white"
                    }
                }
            }

            //预览窗口
            Rectangle{
                id:rightRect
                Layout.preferredWidth: parent.width * 0.5
                Layout.preferredHeight: left.height
                color:"black"
                border.color:"black"
                // 添加一个属性来控制select按钮的可见性
                property bool showSelectButton: true

                //实例化一个Player
                Player{
                    id:oneplayer
                }

                ToolBar
                {
                    RowLayout
                    {
                        ToolButton{action:act.aa}//start
                        ToolButton{action:act.bb}//pause
                        ToolButton {
                            action: act.cc // stop
                            // 添加停止按钮点击后的处理，点击停止后复现选择按钮
                            onClicked: {
                                rightRect.showSelectButton = true // 显示select按钮
                                // 原有的停止逻辑
                                oneplayer.mplay.stop()
                            }
                        }
                    }
                }
                //打开素材列表按钮
                Button
                {
                    id:select
                    x:50
                    y:50
                    height:100
                    width:100
                    visible: rightRect.showSelectButton // 绑定可见性到属性
                    onClicked: dialog.open()
                }
                //选择对话框select
                Dialog {
                    id: dialog
                    width: parent.width / 2
                    height: parent.height /2
                    modal: true
                    title: "请选择进行剪辑的视频"

                    Rectangle{
                        id:popup
                        anchors.fill: parent
                        color: "green"

                        ListView{
                            id:videoList2
                            anchors.fill:parent
                            spacing:5

                            ScrollBar.vertical: ScrollBar {
                                policy: ScrollBar.AlwaysOn
                            }

                            model:videoModel

                            delegate:Rectangle{
                                id:rec2
                                width:(videoList2.width)
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

                                //文本显示：素材音频的标题
                                Loader{
                                    active: model.mediaType === "audio"
                                    anchors {
                                        rightMargin: 10
                                        verticalCenter: parent.verticalCenter // 垂直居中
                                        horizontalCenter: parent.horizontalCenter // 水平居中
                                    }
                                    sourceComponent: Component{
                                        Text{
                                            id:audioText
                                            text:model.title
                                            color:"green"
                                            font.bold: true
                                            horizontalAlignment: Text.AlignHCenter
                                        }
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
                                        oneplayer.mplay.play()
                                        rightRect.showSelectButton = false // 隐藏select按钮
                                        dialog.close() // 关闭对话框
                                        inputPath1 = model.filePath.toString().replace("file://", "") // 视频路径传给后端C++函数实现预览
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

        VideoCutter {
            id: cutter
            onFinished: (success, error) => {
                console.log("剪切结果:", success, error)
                noti.text = success ? "剪切成功!" : "失败: " + error
                noti.notification.show(noti.text)
                //这里需要优化，剪切0秒时提示错误❌
                //剪切视频提示，调用Notification.qml
            }
        }

        //整体时间轴以及视频处理窗口
        Rectangle{
            id:bottomRect
            Layout.fillWidth: true
            Layout.preferredHeight: parent.height * 0.5 // 下半部分占50%高度
            color:"pink"
            border.color:"pink"

            //与预览窗口结合的时间轴 Slider2
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

            //剪切操作按钮
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

                Button{
                    id:button4
                    text:qsTr("预览")
                    visible: currentButton === 4
                    onClicked: {
                        cutter.previewCut(inputPath1,cutter.returnStartSec(),cutter.returnEndSec())
                        currentButton = 5
                    }
                }

                Button {
                    id: button5
                    text:qsTr("保存？单击保存 | 双击取消")
                    //在双击操作时，会先触发一次单击事件，然后再触发双击事件
                    //所以这里采用计时器clickTimer
                    visible: currentButton === 5

                    property bool isDoubleClicked: false

                    onDoubleClicked: {
                        isDoubleClicked=true
                        resultText.text = "已取消"
                        resultText.color = "blue"
                        messageTimer.start()
                        currentButton = 1
                    }
                    onClicked: {
                        isDoubleClicked=false
                        clickTimer.start()
                    }
                    Timer{
                        id:clickTimer
                        interval: 300 // 300毫秒是双击检测的合理时间
                        onTriggered:{
                            if(button5.isDoubleClicked==false){
                                oneplayer.savefile.open()
                                resultText.text = "处理中..."
                                resultText.color = "blue"
                                messageTimer.start()
                                currentButton = 1
                            }
                        }
                    }
                    //resultText提示维持1秒
                    Timer {
                        id: messageTimer
                        interval: 1000
                        onTriggered: resultText.text = ""
                    }
                }

                Text {
                    id: resultText
                    font.pixelSize: 14
                    width: 300
                }
            }
            //处理按钮
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
        }
    }

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
