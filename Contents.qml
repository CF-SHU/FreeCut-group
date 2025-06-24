import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtMultimedia
import "control.js" as Controller
import QtQuick.Dialogs
import QtCore
import Videoclips 1.0

Item {
    property alias dialog:_dialog
    property int currentPlayingIndex: -1
    property int currentPlayingIndex1: -1 //?????????
    property alias mplay:_mplayer //素材视频/音频的播放
    property string inputPathPreview: ""
    property string outputPathPip:""//画中画输出路径（用户自定义
    property var videoCPath: [" ", " ", " "," "," "]
    property var videoQPath: [" ", " ", " "," "," "]
    property int a: 0
    property int timerValue: 0 //生成临时剪切文件的计数器
    property string mergePath1:""
    property string mergePath2:""

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
                    _mplayer.source = filePath
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

    VideoCutter {
        id: cutter
        onFinished: (success, error) => {
            console.log("剪切结果:", success, error)
            noti.text = success ? "剪切成功!" : "失败: " + error
            //noti.notification.show(noti.text)
            //这里需要优化，剪切0秒时提示错误❌
            //剪切视频提示，调用Notification.qml
        }
    }

    //画中画
    VideoPip{
        id:pipper
        onProcessingFinished: {
            console.log("视频处理完成:", outputPath)
            // 显示成功提示
            successText.text = "保存成功！"
            successText.color = "green"
            yes.successText.visible = true
            yes.successTimer.restart() // 启动定时器显示成功
        }

        onProcessingError: {
            console.error("处理错误:", errorMessage)
            // 显示错误提示
            yes.successText.text = "保存失败: " + errorMessage
            yes.successText.color = "red"
            yes.successText.visible = true
            yes.successTimer.restart()
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
                Layout.preferredWidth: parent.width * 0.12
                Layout.preferredHeight: parent.height - bottomRect.height
                //color: "black"
                gradient: Gradient {
                        GradientStop { position: 0.3; color: "black" }
                        GradientStop { position: 0.8; color: "#2a0132" }
                    }
                // gradient: Gradient {
                //         GradientStop { position: 0.2; color: "#520162" }
                //         GradientStop { position: 0.9; color: "#2a0132" }//#520162
                //     }

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
                                index % 2 === 0 ? "#302d2c" : "white"
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
                                _mplayer.source = model.filePath
                                _mplayer.play()
                            }
                            onDoubleTapped:{
                                if(content.currentPlayingIndex===index){
                                    if (_mplayer.playbackState === MediaPlayer.PlayingState) {
                                        _mplayer.pause()
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
                Layout.preferredWidth: parent.width * 0.38
                Layout.preferredHeight: left.height
                //color: "black"
                gradient: Gradient {
                        GradientStop { position: 0.3; color: "black" }
                        GradientStop { position: 0.8; color: "#2a0132" }
                    }
                // gradient: Gradient {
                //         GradientStop { position: 0.2; color: "#520162" }
                //         GradientStop { position: 0.9; color: "#2a0132" }//#520162
                //     }
                border.width: 1

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
                        //color: "black"
                        //opacity:0
                        gradient: Gradient {
                                GradientStop { position: 0.3; color: "black" }
                                GradientStop { position: 0.8; color: "#2a0132" }
                            }
                        border.width: 1
                        MediaPlayer{
                            id:_mplayer
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
                    id: slider5
                    anchors.bottom: parent.bottom
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: parent.width - 40 // 留出一些边距
                    from: 0
                    to: _mplayer.duration > 0 ? _mplayer.duration : 1000 // 默认值为 1000 毫秒（1 秒），避免为 0
                    value: _mplayer.position
                    stepSize: 1000 // 步长为 1 秒

                    // 当用户拖动 Slider 时，跳转到视频的相应位置
                    onValueChanged: {
                        if (pressed) { // 仅在用户拖动滑块时更新
                            console.log("Slider value changed to:", value); // 调试输出
                            _mplayer.position = value; // 使用 position 属性跳转
                        }
                    }
                }
                // 显示当前时间和总时长
                Row {
                    anchors.bottom: slider5.top
                    anchors.horizontalCenter: parent.horizontalCenter
                    spacing: 10
                    Text {
                        text: Controller.formatTime(_mplayer.position)+" / "
                                +Controller.formatTime(_mplayer.duration)
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
                clip: true // 确保子元素-addVideo矩形不会超出边界显示
                gradient: Gradient {
                        GradientStop { position: 0.3; color: "black" }
                        GradientStop { position: 0.8; color: "#2a0132" }
                    }
                // gradient: Gradient {
                //         GradientStop { position: 0.2; color: "#520162" }
                //         GradientStop { position: 0.9; color: "#2a0132" }//#520162
                //     }
                //border.color:"white"

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
                //打开素材列表按钮:添加素材
                Button
                {
                    id:select
                    height:rightRect.height /2
                    width:rightRect.width /2
                    anchors.centerIn: parent

                    background: Rectangle
                    {
                        color:"transparent"
                        border.color:"purple"
                        border.width:1
                        radius:5
                    }

                    Text
                    {
                        id:text
                        text:qsTr("添加素材")
                        color: "purple"
                        anchors.centerIn:select
                        font.pixelSize: 40
                        Behavior on color {
                            ColorAnimation {
                                from: "purple"
                                to: "blue"
                                duration: 1000
                                loops:Animation.Infinite
                            }
                        }
                    }

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
                        color: "#2b3d40"

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
                                        //console.log("Tapped filePath:", model.filePath); // 调试输出
                                        content.currentPlayingIndex = index
                                        //console.log("now music index & currentPlayingIndex is ",index,content.currentPlayingIndex)
                                        oneplayer.mplay.source = model.filePath
                                        oneplayer.mplay.play()
                                        rightRect.showSelectButton = false // 隐藏select按钮
                                        dialog.close() // 关闭对话框
                                        //预览功能的输入路径
                                        inputPathPreview = model.filePath.toString().replace("file://", "") // 视频路径传给后端C++函数实现预览
                                        mergePath2 = model.filePath.toString().replace("file://", "")//第二个要合并的视频的路径
                                        console.log(mergePath2)
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
                //add画中画窗口
                Rectangle {
                    id: addVideo
                    visible: false
                    width: parent.width / 4
                    height: parent.height / 4
                    x:100
                    y:100
                    color: "transparent"

                    MediaPlayer {
                        id: _twoPlay
                        videoOutput: addOut
                        onMediaStatusChanged: {
                            if (mediaStatus === MediaPlayer.EndOfMedia) {
                                addVideo.visible = false
                            }
                        }
                    }

                    VideoOutput {
                        id: addOut
                        anchors.fill: parent
                        fillMode: VideoOutput.PreserveAspectFit // 保持比例
                    }

                    DragHandler {
                        id: dragHandler
                        target: addVideo
                        onActiveChanged: {
                            if (!active) {
                                // 记录位置信息
                                console.log("x,y pg rightRec",rightRect.x,rightRect.y)
                                addVideo.x = Math.max(0,Math.min(addVideo.x, rightRect.width-addVideo.width))
                                addVideo.y = Math.max(0,Math.min(addVideo.y, rightRect.height-addVideo.height))
                                console.log("x,y 12345:",addVideo.x,addVideo.y)
                            }
                        }
                    }

                    // 拖动提示
                    Text {
                        anchors {
                            top: parent.top
                            horizontalCenter: parent.horizontalCenter
                            topMargin: 10
                        }
                        text: "可拖动!"
                        color: "white"
                        font.pixelSize: 12
                        font.italic: true
                        opacity: 0.8
                    }
                }

            }
        }


        //整体时间轴以及视频处理窗口
        Rectangle{
            id:bottomRect
            Layout.fillWidth: true
            Layout.preferredHeight: parent.height * 0.4 // 下半部分占50%高度
            //color:"#43074f"
            // gradient: Gradient {
            //         GradientStop { position: 0.2; color: "#2a0132" }
            //         GradientStop { position: 0.9; color: "#520162" }
            //     }
            gradient: Gradient {
                    GradientStop { position: 0.5; color: "#2a0132" }
                    GradientStop { position: 0.9; color: "black" }
                }

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

            //剪切等按钮
            Rectangle {
                id:pinkCut
                width:parent.width / 6
                height: parent.height / 8
                color: "white"
                border.color: "gray"
                border.width: 3
                radius: 5
                anchors.top: slider2.bottom
                anchors.topMargin: 5
                anchors.left: parent.left
                anchors.leftMargin: 10
                Column{
                    //anchors.centerIn:pinkCut
                    spacing: 20
                    anchors.left: parent.left
                    anchors.top: parent.top

                    //button1:剪辑开始
                    Button {
                        id: button1
                        highlighted: true
                        width: pinkCut.width
                        height: pinkCut.height
                        text:qsTr("剪辑开始")
                        visible: currentButton === 1
                        onClicked: {
                            currentButton = 2
                        }
                    }
                    //button2:剪辑的第一个节点
                    Button {
                        id: button2
                        width: button1.width
                        height: button1.height
                        visible: currentButton === 2
                        text:qsTr("选择该节点作为剪辑的第一个节点")
                        // 格式化时间为秒数
                        function formatTime(milliseconds) {
                            return Math.floor(milliseconds / 1000); // 返回秒数
                        }
                        onClicked: {
                            console.log("Current time 124352463574685796 button2剪切节点1:", formatTime(oneplayer.mplay.position)); // 打印当前时间
                            cutter.getStartSec(formatTime(oneplayer.mplay.position));
                            currentButton = 3
                        }
                    }
                    //button3:剪辑的第二个节点
                    Button {
                        id: button3
                        width: button1.width
                        height: button1.height
                        visible: currentButton === 3
                        text:qsTr("选择该节点作为剪辑的第二个节点")

                        // 格式化时间为秒数
                        function formatTime(milliseconds) {
                            return Math.floor(milliseconds / 1000); // 返回秒数
                        }
                        onClicked: {
                            console.log("Current time 213524678932435 button3剪切节点2:", formatTime(oneplayer.mplay.position)); // 打印当前时间
                            cutter.getEndSec(formatTime(oneplayer.mplay.position));
                            currentButton = 4
                        }
                    }
                    //button4:预览
                    Button{
                        id:button4
                        width: button1.width
                        height: button1.height
                        text:qsTr("预览")
                        visible: currentButton === 4
                        onClicked: {
                            console.log("current preview video inputPathPreview,cutter.returnStartSec(),cutter.returnEndSec() ：",inputPathPreview,cutter.returnStartSec(),cutter.returnEndSec())
                            cutter.previewCut(inputPathPreview,cutter.returnStartSec(),cutter.returnEndSec())
                            currentButton = 5
                        }
                    }
                    //button5:保存 | 继续剪切/退出
                    Button {
                        id: button5
                        width: button1.width
                        height: button1.height
                        text:qsTr("单击保存 | 双击在此基础上继续剪切或退出")
                        //在双击操作时，会先触发一次单击事件，然后再触发双击事件
                        //所以这里采用计时器clickTimer
                        visible: currentButton === 5
                        property bool isDoubleClicked: false

                        onDoubleClicked: {
                            isDoubleClicked=true
                            resultText.text = "继续剪切 | 退出"
                            resultText.color = "blue"
                            currentButton = 6
                        }
                        onClicked: {
                            isDoubleClicked=false
                            clickTimer.start()
                        }
                        //处理单击保存操作
                        Timer{
                            id:clickTimer
                            interval: 300 // 300毫秒是双击检测的合理时间
                            onTriggered:{
                                if(button5.isDoubleClicked==false){
                                    oneplayer.saveCut.open() // 剪切视频保存
                                    resultText.text = "处理中..."
                                    resultText.color = "blue"
                                    messageTimer.start()
                                    currentButton = 1
                                    timerValue = 0
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
                    //button6:继续剪切：确认 | 退出
                    Button {
                        id: button6
                        width: button1.width
                        height: button1.height
                        text:qsTr("单击确认 | 双击退出")
                        visible: currentButton === 6
                        property bool isDoubleClicked: false
                        onDoubleClicked: {
                            isDoubleClicked=true
                            resultText.text = "已退出剪切"
                            resultText.color = "blue"
                            messageTimer1.start()
                            currentButton = 1
                        }
                        onClicked: {
                            isDoubleClicked=false
                            clickTimer1.start()
                        }
                        //处理单击继续剪切操作
                        Timer{
                            id:clickTimer1
                            interval: 300 // 300毫秒是双击检测的合理时间
                            onTriggered:{
                                if(button6.isDoubleClicked===false){
                                    //保存到固定的的目录，保存剪切的视频并继续剪切
                                    var outputPath = "/root/wawawawawa/ccc"+timerValue+".mp4"
                                    Controller.processCut(inputPathPreview,outputPath)
                                    inputPathPreview = outputPath
                                    console.log("test QML input | output: ",inputPathPreview,outputPath)
                                    currentButton = 1
                                    timerValue++
                                }
                            }
                        }
                        //连接c++后端函数槽
                        Connections {
                            target: cutter
                            function onCutFinished(success, outputPath) {
                                if(success) {
                                    console.log("剪切完成，准备播放:", outputPath)
                                    // 添加延迟器确保播放器状态重置
                                    playTimer.outputPath = outputPath
                                    playTimer.start()
                                    resultText.text = ""
                                } else {
                                    resultText.text = "剪切失败"
                                    resultText.color = "red"
                                    messageTimer1.start()
                                }
                            }
                        }
                        // 播放定时器（解决立即播放问题）
                        Timer {
                            id: playTimer
                            property string outputPath: ""
                            interval: 100
                            onTriggered: {
                                oneplayer.mplay.stop()
                                oneplayer.mplay.source = ""
                                oneplayer.mplay.source = "file://" + outputPath
                                oneplayer.mplay.play()
                            }
                        }
                        //resultText提示维持1秒
                        Timer {
                            id: messageTimer1
                            interval: 1000
                            onTriggered: resultText.text = ""
                        }
                    }
                    //提示文本
                    Text {
                        id: resultText
                        font.pixelSize: 14
                        width: 300
                    }
                }
            }
            //音频等按钮
            Rectangle{
                id:musicCut
                width:parent.width / 4
                height: parent.height / 8
                anchors.top: pinkCut.top
                anchors.left: pinkCut.right
                anchors.leftMargin: 10
                color: "white"
                radius: 5
                //原声
                Row{
                    id:row
                    width: parent.width /2
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter
                    RadioButton{
                        id:cutaudio
                        text:"关闭原声"
                        height: parent.height
                        width: parent.width / 2
                        onClicked: {
                            oneplayer.mplay.audioOutput.muted = true
                            noti.notification.show("已关闭原声")
                        }
                    }
                    RadioButton{
                       id:openaudio
                       width: parent.width / 2
                       text:"打开原声"
                       onClicked: {
                           oneplayer.mplay.audioOutput.muted = false
                           noti.notification.show("已打开原声")
                       }
                    }
                }
                //插入音频
                RadioButton{
                    id:music
                    anchors.bottom: cutaudio.bottom
                    height:parent.height
                    width: parent.width / 4
                    anchors.left:row.right
                    text:"插入音频"
                    onClicked: {
                       oneplayer.openmusic.open()
                    }
                }
                //导出视频
                RadioButton{
                    id:ouput
                    anchors.bottom: cutaudio.bottom
                    height: parent.height
                    width: parent.width / 4
                    anchors.left:music.right
                    text:"导出视频"
                    onClicked: {
                        oneplayer.savevideofile.open()
                    }
                }
            }
            //合并视频按钮
            Rectangle {
                id:merge
                width:parent.width / 6
                height: parent.height / 8
                color: "white"
                border.color: "gray"
                border.width: 3
                radius: 5
                anchors.left: musicCut.right
                anchors.top: musicCut.top
                anchors.leftMargin: 10
                Button{
                    id:mer1
                    text:"选择要合并的视频"
                    anchors.left: parent.left
                    width: (parent.width / 3) * 2
                    height: parent.height
                    highlighted: true
                    onClicked: {
                        mergePath1 = oneplayer.mplay.source.toString().replace("file://", "")//第一个要合并的视频的路径
                        console.log(mergePath1)
                        dialog.open()
                    }
                }
                Button{
                    id:mer2
                    text:"确定"
                    anchors.left: mer1.right
                    width: parent.width / 3
                    height:parent.height
                    highlighted: true
                    onClicked: {
                        oneplayer.savemergerfile.open()
                    }
                }
            }
            //水印按钮
            Rectangle {
                id:addwatermark
                width:parent.width / 6
                height: parent.height / 8
                color: "white"
                border.color: "gray"
                border.width: 3
                radius: 5
                anchors.top: merge.top
                anchors.left: merge.right
                anchors.leftMargin: 10
                //button5:添加水印
                Button{
                    id:watermark
                    text:qsTr("添加水印")
                    width:addwatermark.width
                    height:addwatermark.height
                    highlighted: true
                   // anchors.top: openaudio.bottom
                    onClicked: {
                       inputDialog.open();
                    }
                }
                // 提示信息
                Text {
                    id: statusText
                    anchors.top: addwatermark.bottom  // 将提示信息定位在 addwatermark 的下方
                    anchors.horizontalCenter: addwatermark.horizontalCenter  // 水平居中
                    text: ""
                    color: "green"
                    font.pixelSize: 14
                    visible: false
                }
                // 用于隐藏提示信息的定时器
                Timer {
                    id: hideStatusTimer
                    interval: 3000 // 3秒
                    onTriggered: {
                        statusText.visible = false;
                    }
                }
                //用户点击“添加水印”按钮后，Popup对话框将打开。
               // 用户在TextField中输入水印文本。
               // 用户点击“确定”按钮后，输入的文本将传递给_watermark.text，对话框关闭。
                Popup {
                    id: inputDialog
                    width: 200
                    height: 100
                    modal: true
                    focus: true
                    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside
                    ScrollView {
                        anchors.fill: parent
                        contentWidth: parent.width
                        contentHeight: columnLayout.height

                        ColumnLayout {
                            anchors.fill: parent
                            spacing: 10

                            TextField {
                                id: textInput
                                placeholderText: qsTr("输入水印文本")
                                Layout.fillWidth: true
                                // 可选：自定义placeholderText的颜色
                                placeholderTextColor: "gray"

                                // 监听文本变化
                                onTextChanged: {
                                    if (text === "") {
                                        // 文本为空时，placeholderText会自动显示
                                    }
                                }
                            }

                            RowLayout {
                                spacing: 5
                                Layout.fillWidth: true

                                Text {
                                    text: qsTr("颜色:")
                                    font.pixelSize: 14
                                    anchors.verticalCenter: parent.verticalCenter
                                }

                                ComboBox
                                {
                                     id: colorInput
                                     model: ["white", "red", "green", "blue","black","purple","pink","yellow","orange"]
                                     Layout.fillWidth: true
                                 }
                            }
                            RowLayout {
                                spacing: 5
                                Layout.fillWidth: true

                                Text {
                                    text: qsTr("透明度:")
                                    font.pixelSize: 14
                                    anchors.verticalCenter: parent.verticalCenter
                                }
                                ComboBox
                                {
                                     id: alphaInput
                                     model: ["0", "0.1", "0.2", "0.3", "0.4", "0.5", "0.6", "0.7", "0.8", "0.9", "1"]
                                     Layout.fillWidth: true
                                 }
                            }
                            RowLayout {
                                spacing: 5
                                Layout.fillWidth: true

                                Text {
                                    text: qsTr("字体大小:")
                                    font.pixelSize: 14
                                    anchors.verticalCenter: parent.verticalCenter
                                }
                                 SpinBox
                                 {
                                     id: sizeInput
                                     from: 10
                                     to: 72
                                     value: 24
                                     Layout.fillWidth: true
                                 }
                            }
                            RowLayout {
                                   spacing: 5
                                   Layout.fillWidth: true

                                   Text {
                                       text: qsTr("移动模式:")
                                       font.pixelSize: 14
                                       anchors.verticalCenter: parent.verticalCenter
                                   }

                                   ComboBox {
                                       id: movementModeInput
                                       model: [
                                           qsTr("水平移动"),
                                           qsTr("上下移动"),
                                           qsTr("对角线移动"),
                                           qsTr("固定不变")
                                       ]
                                       currentIndex: 0  // 默认选择第一个选项
                                       Layout.fillWidth: true
                                   }
                             }
                            Button {
                                text: qsTr("确定")
                                Layout.alignment: Qt.AlignRight
                                onClicked: {
                                     var customText = textInput.text;
                                     var customColor = colorInput.currentText;
                                     var customSize = sizeInput.value;
                                    var customAlpha = parseFloat(alphaInput.currentText);

                                     // 将参数传递给 oneplayer.watermark
                                     oneplayer.watermark.text = customText;
                                     oneplayer.watermark.color = customColor;
                                     oneplayer.watermark.size = customSize;
                                    oneplayer.watermark.alpha = customAlpha;

                                     inputDialog.close();

                                    // 连接 watermarkAdded 信号
                                       oneplayer.watermark.watermarkAdded.connect(function() {
                                           statusText.text = qsTr("水印添加成功！");
                                           statusText.visible = true;
                                            hideStatusTimer.start(); // 启动定时器
                                       });

                                    //选择文件路径保存加上水印的视频
                                    //保存的时候将输出路径传给添加水印的函数，将水印添加到视频中
                                    oneplayer.savewater.open();
                                }
                            }
                        }
                    }

             }
            }
            //画中画按钮
            Rectangle{
                id:addVideoButton
                width:parent.width / 6
                height: parent.height / 8
                color: "white"
                border.color: "gray"
                border.width: 3
                radius: 5
                anchors.left: addwatermark.right
                anchors.top: addwatermark.top
                anchors.leftMargin: 10

                property int currentButton: 1

                //画中画按钮
                Button{
                    id:addV
                    visible: currentButton === 1
                    text:"添加画中画"
                    width: parent.width
                    height: parent.height
                    highlighted: true
                    onClicked: {
                        oneplayer.openAddV.open()
                        addVideo.visible = true
                        currentButton = 2
                    }
                }
                Button{
                    id:yes
                    visible: currentButton === 2
                    text:"确认画中画位置并保存"
                    width: parent.width
                    height: parent.height
                    //提示文本
                    Text {
                        id: successText
                        font.pixelSize: 14
                        anchors.bottom: parent.bottom
                        text:""
                        visible: false
                    }
                    //保存画中画视频
                    FileDialog{
                        id:_savepip
                        title: "Save your pip video"
                        currentFolder:StandardPaths.writableLocation(StandardPaths.DocumentsLocation)
                        fileMode:FileDialog.SaveFile
                        nameFilters:[ "Audio files (*.mp4 *.mov *.avi *.mkv *.wav)" ]
                        onAccepted: {
                            outputPathPip = selectedFile.toString().replace("file://", "")
                            console.log("输出文件路径:", outputPathPip)
                            let pipVideoPath = _twoPlay.source.toString().replace("file://", "")
                            let pipDuration = _twoPlay.duration/1000
                        //     // 转换位置和尺寸
                        //     const convertedPos = Controller.convertPosition(rightRect, _twoPlay, addVideo.x, addVideo.y)
                        //     const pipSize = Controller.convertSize(rightRect, _twoPlay, addVideo.width, addVideo.height)

                        //     pipper.videoInsertPip(
                        //         inputPathPreview,
                        //         pipVideoPath,
                        //         outputPathPip,
                        //         pipDuration,
                        //         convertedPos.x,
                        //         convertedPos.y,
                        //         pipSize.width,
                        //         pipSize.height
                        //     )
                        // }
                            pipper.videoInsertPip(inputPathPreview,pipVideoPath,outputPathPip,pipDuration,addVideo.x,addVideo.y)
                        }
                    }
                    Timer{
                        id:successTimer
                        interval:2000
                        onTriggered:{
                            successText.visible = false;
                            currentButton = 1
                        }
                    }
                    onClicked: {
                        _savepip.open()
                        successTimer.start()
                    }
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
