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
    args << "-y" // 覆盖输出文件
         << "-i" << inputPath1 << "-i" << inputPath2
         << "-filter_complex"
            "[0:v][0:a][1:v][1:a]concat=n=2:v=1:a=1[outv][outa]"
         << "-map" << "[outv]"
         << "-map" << "[outa]"
         << "-c:v" << "libx264"
         << "-preset" << "fast"
         << "-c:a" << "aac" << outputPath;

    qDebug() << "执行FFmpeg命令:" << "ffmpeg" << args;
    m_process->start("ffmpeg", args);
}
