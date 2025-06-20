function processCut() {
    // console.log("test cut path: ",oneplayer.inputPath)
    // console.log("test save Path: ",oneplayer.outputPath)
    cutter.cutVideo(inputPath1,oneplayer.outputPath,cutter.returnStartSec(),
                    cutter.returnEndSec()-cutter.returnStartSec())
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
