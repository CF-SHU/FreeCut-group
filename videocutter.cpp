#include "videocutter.h"
#include <iostream>
#include <qdir.h>
using std::cin;
using std::endl;

#include <QRegularExpression>
#include <QDebug>
#include <QStandardPaths> // 添加标准路径支持
#include <cstdio>

VideoCutter::VideoCutter(QObject *parent) : QObject(parent), m_process(nullptr) {}

void VideoCutter::cutVideo(const QString &inputPath, const QString &outputPath, qint64 startSec, qint64 durationSec)
{
    // 确保输出目录存在
    QDir outputDir = QFileInfo(outputPath).dir();
    if (!outputDir.exists()) {
        if (!outputDir.mkpath(".")) {
            qDebug() << "Failed to create output directory:" << outputDir.path();
            // return false;
        }
    }

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
    qDebug() << "input : " << inputPath;
    qDebug() << "自定义输出路径:" << outputPath;

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
    connect(m_process, &QProcess::errorOccurred, this, [=, this](QProcess::ProcessError error) {
        QString errorMsg = QString("进程错误[%1]: %2").arg(error).arg(m_process->errorString());
        qWarning() << errorMsg;
        emit finished(false, errorMsg);
    });

    // 捕获标准错误输出
    connect(m_process, &QProcess::readyReadStandardError, this, [=, this]() {
        QString errorLog = m_process->readAllStandardError();
        qWarning() << "FFmpeg错误输出:" << errorLog;
        if (errorLog.contains("Error") || errorLog.contains("Invalid")) {
            emit finished(false, "FFmpeg错误: " + errorLog.section('\n', 0, 0));
        }
    });

    connect(m_process, &QProcess::finished, this, [=, this](int exitCode, QProcess::ExitStatus) {
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
bool VideoCutter::deletedir(const QString &dirpath)
{
    // if (std::remove(filepath.toLocal8Bit().constData()) == 0) {
    //     qDebug() << "File deleted successfully:" << filepath;
    //     return true;
    // } else {
    //     perror("Error deleting file"); // 输出错误信息
    //     qDebug() << "Failed to delete file:" << filepath;
    //     return false;
    // }
    QDir dir(dirpath);

    // 检查目录是否存在
    if (!dir.exists()) {
        qDebug() << "Directory does not exist:" << dirpath;
        return false;
    }

    // 删除目录及其所有内容
    if (dir.removeRecursively()) {
        qDebug() << "Directory deleted successfully:" << dirpath;
        return true;
    } else {
        qDebug() << "Failed to delete directory:" << dirpath;
        return false;
    }
}
bool VideoCutter::savefile(const QString &inputPath, const QString &outputPath)
{
    std::string inputStdString = inputPath.toStdString();
    std::string outputStdString = outputPath.toStdString();
    // 构建 ffmpeg 命令
    QString command = "ffmpeg -i " + inputPath + " -c copy " + outputPath;
    std::string commandStdString = command.toStdString();
    // 执行命令
    int returnCode = system(commandStdString.c_str());

    // 检查命令执行是否成功
    if (returnCode != 0) {
        std::cerr << "Error: Failed to execute ffmpeg command. Return code: " << returnCode << std::endl;
        return false;
    }

    // 删除源文件
    QFile sourceFile(inputPath);
    if (!sourceFile.remove()) {
        qWarning() << "Warning: Failed to delete source file:" << inputPath;
        return false; // 返回 false 表示删除失败
    }

    qDebug() << "Video saved successfully and source file deleted:" << outputPath;

    return true;
}
bool VideoCutter::movefile(const QString &sourcePath, const QString &destinationDir)
{
    QFile sourceFile(sourcePath);
    QDir destinationDirectory(destinationDir);

    // 检查源文件是否存在
    if (!sourceFile.exists()) {
        qWarning() << "Error: Source file does not exist.";
        return false;
    }

    // 检查目标目录是否存在，如果不存在则创建
    if (!destinationDirectory.exists()) {
        if (!destinationDirectory.mkpath(".")) {
            qWarning() << "Error: Failed to create destination directory.";
            return false;
        }
    }

    // 获取源文件的文件名
    QString filename = QFileInfo(sourceFile).fileName();

    // 构建目标文件路径
    QString destinationPath = destinationDirectory.filePath(filename);

    // 移动文件
    if (!sourceFile.rename(destinationPath)) {
        qWarning() << "Error: Failed to move file:" << sourceFile.errorString();
        return false;
    }

    qDebug() << "Video moved successfully to:" << destinationPath;
    return true;
}
