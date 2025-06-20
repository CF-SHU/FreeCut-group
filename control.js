function processCut(inputPath1,outputPth1) {
    // console.log("test cut path: ",oneplayer.inputPath)
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

function deletefile(filepath)
{
    cutter.deletefile(filepath)
}

function savefile()
{

   cutter.savefile("/root/wawawawawa/ccc.mp4",outputPath)
}
function movefile()
{
    cutter.movefile("/root/wawawawawa/ccc.mp4",outputPath)
}
