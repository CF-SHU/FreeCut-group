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
function deletefile(filepath)
{
    cutter.deletedir(filepath)
}

/**转换尺寸，暂时不需要
//add画中画尺寸处理
function convertPip(previewItem,videoItem,x,y){
    //获取预览尺寸
    const preWidth = previewItem.width
    const preHeight = previewItem.height
    //获取画中画视频的尺寸
    const viWidth = videoItem.videoWidth
    const viHeight = videoItem.videoHeight
    console.log("viWidth, viHeight, preWidth, preHeight: ",viWidth,viHeight,preWidth,preHeight)

    //画中画显示的长宽，以及偏移量
    var displayWidth,displayHeight,offX,offY

    //画中画宽高比vi+预览宽高比pre
    var viAspect = viWidth/viHeight
    var preAspect = preWidth/preHeight
    //vi宽高比>pre,即显示效果是横屏
    if(viAspect>preAspect){
        displayHeight = preHeight/viAspect
        displayWidth = preWidth
        offX = 0
        offY = (preHeight - displayHeight)/2
    }
    //vi<pre,显示效果是竖屏
    else if(viAspect<preAspect){
        displayHeight = preHeight
        displayWidth = preWidth*viAspect
        offY = 0
        offX = (preWidth-displayWidth)/2
    }
    //尺寸完全符合，偏移量为0
    else{
        offY = 0;
        offX = 0
    }
    //视频实际所在的位置
    const converX = ((x-offX)/displayWidth)*viWidth
    const convetY = ((y-offY)/displayHeight)*viHeight

    return {x:converX,y:convetY}
}
//处理画中画预览视频中，视频的实际长宽
function convetPreVideo(RectItem,videoItem){
    const rectWidth = RectItem.width
    const rectHeight = RectItem.height

    //获取画中画视频的尺寸
    const viWidth = videoItem.videoWidth
    const viHeight = videoItem.videoHeight
    console.log("1234, rectWidth, rectHeight, viWidth, viHeight",rectWidth,rectHeight,viWidth,viHeight)

    var trueWidth,trueHeight

    var viAspect = viWidth/viHeight
    var rectAspect = rectWidth/rectHeight
    console.log("viAspect, rectAspect, viWidth, viHeight",viAspect,rectAspect,viWidth,viHeight)

    //横屏
    if(viAspect>rectAspect){
        trueHeight = rectHeight/viAspect
        trueWidth = rectWidth
        console.log("viAspect, trueHeight, trueWidth",viAspect,trueHeight,trueWidth)
    }
    //竖屏
    else if(viAspect<rectAspect){
        trueHeight = rectHeight
        trueWidth = rectWidth*viAspect
    }
    //符合尺寸
    else{
        trueHeight = rectHeight
        trueWidth = rectWidth
    }

    return {trueWidth,trueHeight}
}
*/

// function savefile()
// {
//    cutter.savefile("/root/wawawawawa/ccc.mp4",outputPath)
// }
// function movefile()
// {
//     cutter.movefile("/root/wawawawawa/ccc.mp4",outputPath)
// }
