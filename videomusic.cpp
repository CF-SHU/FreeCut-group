//videomusic.cpp
#include "videomusic.h"

#include <QProcess>
#include <QDebug>
#include <QFileInfo>
#include <QCoreApplication>

VideoMusic::VideoMusic(QObject* parent) : QObject{parent} {}

// 替换视频中的音频
bool VideoMusic::replaceAudio(const QString& videoPath, const QString& audioPath, const QString& outputPath)
{
    ffmpeg = new QProcess(this);
    ffmpeg->start("ffmpeg",
                  {"-y",
                   "-i",
                   videoPath,
                   "-i",
                   audioPath,
                   "-c:v",
                   "copy",
                   "-map",
                   "0:v:0",
                   "-map",
                   "1:a:0",
                   "-shortest",
                   outputPath});
    return ffmpeg->waitForFinished() && ffmpeg->exitCode() == 0;
}
