//Controller.js

function processCut(inputPath1,outputPth1) {
    console.log("test cut path JS input | output: ",inputPath1,outputPth1)
    // console.log("test save Path: ",oneplayer.outputPath)
    // cutter.cutVideo(inputPath1,oneplayer.outputPath,cutter.returnStartSec(),
    //                 cutter.returnEndSec()-cutter.returnStartSec())
    cutter.cutVideo(inputPath1,outputPth1,cutter.returnStartSec(),cutter.returnEndSec()-cutter.returnStartSec())
}

// 格式化时间为 mm:ss
function formatTime(milliseconds) {
    var seconds = milliseconds / 1000;
    var minutes = Math.floor(seconds / 60);
    seconds = Math.floor(seconds % 60);
    return minutes + ":" + (seconds < 10 ? "0" : "") + seconds;
}

//区分添加的素材是音频还是视频
function detectMediaType(path) {
        var splitPath = path.toString().split('.').pop().toLowerCase();

        var videoExts = ["mp4", "mov", "avi", "mkv"]; // 视频类型
        var audioExts = ["mp3", "wav", "flac", "ogg"]; // 音频类型

        if (videoExts.includes(splitPath)) return "video";
        if (audioExts.includes(splitPath)) return "audio";

        return "other";
}

// //add转换尺寸
// function convertPosition(previewItem, videoItem, x, y) {
//     // 获取预览区域尺寸
//     const previewWidth = previewItem.width
//     const previewHeight = previewItem.height

//     // 获取视频原始分辨率
//     const videoWidth = videoItem.videoWidth
//     const videoHeight = videoItem.videoHeight

//     // 计算实际显示区域（考虑宽高比）
//     let displayWidth, displayHeight, offsetX, offsetY

//     const videoAspect = videoWidth / videoHeight
//     const previewAspect = previewWidth / previewHeight

//     if (videoAspect > previewAspect) {
//         // 视频宽屏，左右无黑边
//         displayWidth = previewWidth
//         displayHeight = previewWidth / videoAspect
//         offsetX = 0
//         offsetY = (previewHeight - displayHeight) / 2
//     } else {
//         // 视频高屏，上下无黑边
//         displayHeight = previewHeight
//         displayWidth = previewHeight * videoAspect
//         offsetX = (previewWidth - displayWidth) / 2
//         offsetY = 0
//     }

//     // 转换坐标
//     const convertedX = ((x - offsetX) / displayWidth) * videoWidth
//     const convertedY = ((y - offsetY) / displayHeight) * videoHeight

//     return {x: Math.round(convertedX), y: Math.round(convertedY)}
// }

// // 在转换函数中添加尺寸转换
// function convertSize(previewItem, videoItem, width, height) {
//     const {
//             displayWidth,
//             displayHeight
//         } = convertPosition(previewItem,videoItem,x, y);

//     const convertedWidth = (width / displayWidth) * videoItem.videoWidth
//     const convertedHeight = (height / displayHeight) *videoItem.videoHeight
//     return {width: Math.round(convertedWidth), height: Math.round(convertedHeight)}
// }

function deletefile(filepath)
{
    cutter.deletedir(filepath)
}

// function savefile()
// {
//    cutter.savefile("/root/wawawawawa/ccc.mp4",outputPath)
// }
// function movefile()
// {
//     cutter.movefile("/root/wawawawawa/ccc.mp4",outputPath)
// }
