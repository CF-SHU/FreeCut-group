#include "videomerger.h"
#include <qdebug.h>

VideoMerger::VideoMerger(QObject *parent) : QObject{parent}
{
    m_process = new QProcess(this);
}

void VideoMerger::mergeVideos(const QString &inputPath1, const QString &inputPath2, const QString &outputPath)
{
    // 验证输入文件
    //if (!validateInputFile(inputPath1) || !validateInputFile(inputPath2)) { return; }

    // 构建FFmpeg命令
    QStringList args;
    args = {"-y",
            "-i",
            inputPath1,
            "-i",
            inputPath2,
            "-filter_complex",
            "[0:v:0][0:a:0][1:v:0][1:a:0]concat=n=2:v=1:a=1[outv][outa]",
            "-map",
            "[outv]",
            "-map",
            "[outa]",
            outputPath};

    qDebug() << "inputPath1:" << inputPath1;
    qDebug() << "inputPath2:" << inputPath2;
    qDebug() << "outputPath:" << outputPath;
    qDebug() << "执行FFmpeg命令:" << "ffmpeg" << args;
    m_process->start("ffmpeg", args);
}
