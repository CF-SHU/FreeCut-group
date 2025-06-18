#include "videocutter.h"
#include <iostream>
using std::cin;
using std::endl;

#include <QRegularExpression>
#include <QDebug>
#include <QStandardPaths> // 添加标准路径支持

VideoCutter::VideoCutter(QObject *parent) : QObject(parent), m_process(nullptr) {}

void VideoCutter::cutVideo(const QString &inputPath, const QString &outputPath, qint64 startSec, qint64 durationSec)
{
    if (m_process) {
        m_process->kill();
        m_process->deleteLater();
        m_process = nullptr; // 重置指针
    }

    m_process = new QProcess(this);
    m_durationSec = durationSec;

    // 用户可写目录
    //QString OutputPath = outputPath;
    //OutputPath = QStandardPaths::writableLocation(QStandardPaths::MoviesLocation) + "/output.mp4";
    //qDebug() << "自定义输出路径:" << OutputPath;

    QStringList args = {"-y",
                        "-ss",
                        QString::number(startSec),
                        "-i",
                        inputPath,
                        "-t",
                        QString::number(durationSec),
                        "-c",
                        "copy",
                        outputPath};

    qDebug() << "执行FFmpeg命令: ffmpeg" << args.join(" ");

    m_process->setProcessChannelMode(QProcess::MergedChannels);
    connect(m_process, &QProcess::readyReadStandardOutput, this, &VideoCutter::handleProcessOutput);

    // 添加错误处理
    connect(m_process, &QProcess::errorOccurred, this, [=](QProcess::ProcessError error) {
        QString errorMsg = QString("进程错误[%1]: %2").arg(error).arg(m_process->errorString());
        qWarning() << errorMsg;
        emit finished(false, errorMsg);
    });

    // 捕获标准错误输出
    connect(m_process, &QProcess::readyReadStandardError, this, [=]() {
        QString errorLog = m_process->readAllStandardError();
        qWarning() << "FFmpeg错误输出:" << errorLog;
        if (errorLog.contains("Error") || errorLog.contains("Invalid")) {
            emit finished(false, "FFmpeg错误: " + errorLog.section('\n', 0, 0));
        }
    });

    connect(m_process, &QProcess::finished, this, [=](int exitCode, QProcess::ExitStatus) {
        QString result = (exitCode == 0) ? "成功" : "失败";
        qDebug() << "FFmpeg进程结束:" << result << "，退出码:" << exitCode;
        emit finished(exitCode == 0, m_process->errorString());
    });

    m_process->start("ffmpeg", args);
}

void VideoCutter::getStartSec(qint64 startSec)
{
    this->startSec = startSec;
}

void VideoCutter::getEndSec(qint64 endSec)
{
    this->endSec = endSec;
}
qint64 VideoCutter::returnStartSec()
{
    return startSec;
}

qint64 VideoCutter::returnEndSec()
{
    return endSec;
}
void VideoCutter::handleProcessOutput()
{
    QString log = m_process->readAllStandardOutput();
    qDebug() << "FFmpeg输出:" << log;

    QStringList lines = log.split('\n');
    for (const QString &line : lines) {
        if (line.contains("time=")) {
            static QRegularExpression re(R"(time=(\d+):(\d+):(\d+\.\d+))");
            QRegularExpressionMatch match = re.match(line);

            if (match.hasMatch()) {
                qreal hours = match.captured(1).toDouble();
                qreal minutes = match.captured(2).toDouble();
                qreal seconds = match.captured(3).toDouble();
                qreal currentSec = hours * 3600 + minutes * 60 + seconds;

                //进度计算,0% ~ 100%
                if (m_durationSec > 0) {
                    double progressPercent = (currentSec / static_cast<double>(m_durationSec)) * 100;
                    int progress = qBound(0, static_cast<int>(progressPercent), 100);
                    emit progressChanged(progress);
                }
            }
        }
    }
}
