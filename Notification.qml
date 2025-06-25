//Notification.qml
import QtQuick

Item {
    property alias notification: notification
    property alias text: notificationText.text

    Rectangle {
        id: notification
        width: 200
        height: 50
        radius: 5
        color: "#333"
        opacity: 0  // 初始透明
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 50

        Text {
            id: notificationText
            text: ""
            color: "white"
            font.pixelSize: 20
            anchors.centerIn: parent
        }

        // 渐隐动画序列
        SequentialAnimation {
            id: fadeAnimation
            // 显示动画
            PropertyAnimation {
                target: notification
                property: "opacity"
                to: 0.9  // 显示时的不透明度
                duration: 300
            }
            // 停留3秒
            PauseAnimation {
                duration: 3000
            }
            // 渐隐动画
            PropertyAnimation {
                target: notification
                property: "opacity"
                to: 0    // 完全透明
                duration: 500
            }
        }

        // 显示提示的方法
        function show(msg) {
            text = msg
            fadeAnimation.stop()
            opacity = 0
            fadeAnimation.start()
        }
    }

}
