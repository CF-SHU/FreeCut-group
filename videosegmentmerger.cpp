#include "videosegmentmerger.h"
#include <QDebug>
#include <QStandardPaths>
#include <QFile>

VideoSegmentMerger::VideoSegmentMerger(QObject* parent) : QObject(parent)
{
    m_process = new QProcess(this);

    connect(m_process, &QProcess::readyReadStandardError, this, [this]() {
        QString output = QString::fromLocal8Bit(m_process->readAllStandardError());
        QRegularExpression re("time=(\\d+):(\\d+):(\\d+).(\\d+)");
        auto match = re.match(output);
        if (match.hasMatch()) {
            int h = match.captured(1).toInt();
            int m = match.captured(2).toInt();
            int s = match.captured(3).toInt();
            int totalSecs = h * 3600 + m * 60 + s;
            emit progressChanged(totalSecs * 10);
        }
    });
}
void VideoSegmentMerger::mergeTwoSegments(const QString& video1Path,
                                          double video1Start,
                                          double video1End,
                                          const QString& video2Path,
                                          double video2Start,
                                          double video2End,
                                          const QString& outputPath)
{
    if (!QFile::exists(video1Path) || !QFile::exists(video2Path)) {
        emit finished(false, "输入视频文件不存在");
        return;
    }

    QStringList args;
    args << "-y"
         << "-ss" << QString::number(video1Start) << "-i" << video1Path << "-ss" << QString::number(video2Start) << "-i"
         << video2Path << "-filter_complex"
         << QString("[0:v]trim=start=%1:end=%2,setpts=PTS-STARTPTS[v1];"
                    "[0:a]atrim=start=%1:end=%2,asetpts=PTS-STARTPTS[a1];"
                    "[1:v]trim=start=%3:end=%4,setpts=PTS-STARTPTS[v2];"
                    "[1:a]atrim=start=%3:end=%4,asetpts=PTS-STARTPTS[a2];"
                    "[v1][a1][v2][a2]concat=n=2:v=1:a=1[outv][outa]")
                .arg(video1Start)
                .arg(video1End)
                .arg(video2Start)
                .arg(video2End)
         << "-map" << "[outv]"
         << "-map" << "[outa]"
         << "-c:v" << "libx264"
         << "-preset" << "fast"
         << "-c:a" << "aac" << outputPath;

    qDebug() << "FFmpeg命令:" << "ffmpeg" << args;

    connect(m_process, &QProcess::finished, this, [=, this](int exitCode, QProcess::ExitStatus) {
        bool success = (exitCode == 0);
        QString resultMsg = success ? "成功" : "失败";
        qDebug() << "FFmpeg剪切完成:" << resultMsg;
        emit segmentFinished(success, outputPath); // 发射信号包含输出路径
    });
    m_process->start("ffmpeg", args);
}
