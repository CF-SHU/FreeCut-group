#include "videocutter.h"
#include <QTimer>
#include <qdatetime.h>
#include <qfile.h>
#include <QRegularExpression>
#include <QDebug>
#include <QStandardPaths> // 添加标准路径支持
#include <QProcess>
#include <QProcessEnvironment>
#include <QDateTime>
#include <qdir.h>
#include <cstdio>

VideoCutter::VideoCutter(QObject *parent) : QObject(parent), m_process(nullptr) {}

void VideoCutter::cutVideo(const QString &inputPath, const QString &outputPath, qint64 startSec, qint64 durationSec)
{
    // 确保输出目录存在
    QDir outputDir = QFileInfo(outputPath).dir();
    if (!outputDir.exists()) {
        if (!outputDir.mkpath(".")) {
            qDebug() << "Failed to create output directory:" << outputDir.path();
        }
    }

    if (m_process) {
        m_process->kill();
        m_process->deleteLater();
        m_process = nullptr; // 重置指针
    }

    m_process = new QProcess(this);
    m_durationSec = durationSec;

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

    //m_process->setProcessChannelMode(QProcess::MergedChannels);
    //connect(m_process, &QProcess::readyReadStandardOutput, this, &VideoCutter::handleProcessOutput);

    // // 添加错误处理
    // connect(m_process, &QProcess::errorOccurred, this, [=, this](QProcess::ProcessError error) {
    //     QString errorMsg = QString("进程错误[%1]: %2").arg(error).arg(m_process->errorString());
    //     qWarning() << errorMsg;
    //     emit finished(false, errorMsg);
    // });
    // // 捕获标准错误输出
    // connect(m_process, &QProcess::readyReadStandardError, this, [=, this]() {
    //     QString errorLog = m_process->readAllStandardError();
    //     qWarning() << "FFmpeg错误输出:" << errorLog;
    //     if (errorLog.contains("Error") || errorLog.contains("Invalid")) {
    //         emit finished(false, "FFmpeg错误: " + errorLog.section('\n', 0, 0));
    //     }
    // });

    connect(m_process, &QProcess::finished, this, [=, this](int exitCode, QProcess::ExitStatus) {
        QString result = (exitCode == 0) ? "成功" : "失败";
        qDebug() << "FFmpeg进程结束:" << result << "，退出码:" << exitCode;
        emit finished(exitCode == 0, m_process->errorString());
    });

    connect(m_process, &QProcess::finished, this, [=, this](int exitCode, QProcess::ExitStatus) {
        bool success = (exitCode == 0);
        QString resultMsg = success ? "成功" : "失败";
        qDebug() << "FFmpeg剪切完成:" << resultMsg;
        emit cutFinished(success, outputPath); // 发射信号包含输出路径
    });

    m_process->start("ffmpeg", args);
}

//管道：ffmplay & ffmpeg, 但不能循环播放
void VideoCutter::previewCut(const QString &inputPath, qint64 startSec, qint64 endSec)
{
    // 计算持续时间（秒）
    qint64 durationSec = endSec - startSec;
    // 创建播放进程
    QProcess *player = new QProcess();

    // 设置环境变量
    QProcessEnvironment env = QProcessEnvironment::systemEnvironment();
    env.insert("PATH", "/usr/local/bin:/usr/bin:/bin");
    env.insert("LD_LIBRARY_PATH", "/usr/local/lib:/usr/lib");

    // 设置DISPLAY变量（Linux必需）
    if (!env.contains("DISPLAY")) { env.insert("DISPLAY", ":0"); }
    player->setProcessEnvironment(env);

    // 构建FFmpeg命令
    QProcess *ffmpegProcess = new QProcess();
    QStringList ffmpegArgs;
    ffmpegArgs << "-ss" << QString::number(startSec) << "-to" << QString::number(endSec) << "-i" << inputPath << "-c"
               << "copy"
               << "-f" << "matroska"
               << "-"; // 输出到stdout

    // 构建FFplay命令
    QStringList ffplayArgs;
    ffplayArgs << "-autoexit"
               << "-window_title" << "视频预览"
               << "-i" << "pipe:0"; // 从stdin读取

    qDebug() << "FFmpeg命令: ffmpeg" << ffmpegArgs.join(" ");
    qDebug() << "FFplay命令: ffplay" << ffplayArgs.join(" ");

    // 设置环境并连接进程
    ffmpegProcess->setProcessEnvironment(env);
    player->setProcessEnvironment(env);

    // 关键修复：正确连接进程管道
    ffmpegProcess->setStandardOutputProcess(player); // 使用正确的函数名
    player->setProcessChannelMode(QProcess::ForwardedChannels);

    // 先启动播放器，再启动FFmpeg
    player->start("ffplay", ffplayArgs);
    ffmpegProcess->start("ffmpeg", ffmpegArgs);

    // 错误处理
    connect(player, &QProcess::errorOccurred, [](QProcess::ProcessError error) {
        qWarning() << "FFplay错误:" << error;
    });

    connect(player, &QProcess::readyReadStandardError, [player]() {
        qWarning() << "FFplay错误输出:" << player->readAllStandardError();
    });

    connect(ffmpegProcess, &QProcess::readyReadStandardError, [ffmpegProcess]() {
        qWarning() << "FFmpeg错误输出:" << ffmpegProcess->readAllStandardError();
    });

    // 进程结束自动清理
    connect(player,
            QOverload<int, QProcess::ExitStatus>::of(&QProcess::finished),
            [player, ffmpegProcess](int, QProcess::ExitStatus) {
                if (ffmpegProcess->state() == QProcess::Running) {
                    ffmpegProcess->terminate();
                    ffmpegProcess->waitForFinished();
                }
                ffmpegProcess->deleteLater();
                player->deleteLater();
            });
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

bool VideoCutter::deletedir(const QString &dirpath)
{
    QDir dir(dirpath);

    // 检查目录是否存在：检测
    if (!dir.exists()) {
        qDebug() << "Directory does not exist:" << dirpath;
        return false;
    }
    // 删除目录及其所有内容，if调用函数删除，并检查
    if (dir.removeRecursively()) {
        qDebug() << "Directory deleted successfully:" << dirpath;
        return true;
    } else {
        qDebug() << "Failed to delete directory:" << dirpath;
        return false;
    }
}

//FFmpeg进程处理跟踪
/*
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

                // //进度计算,0% ~ 100%
                // if (m_durationSec > 0) {
                //     double progressPercent = (currentSec / static_cast<double>(m_durationSec)) * 100;
                //     int progress = qBound(0, static_cast<int>(progressPercent), 100);
                //     emit progressChanged(progress);
                // }
            }
        }
    }
}
*/

//save：一个视频多次剪切
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
        qDebug() << "Error: Failed to execute ffmpeg command. Return code: " << returnCode;
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

//移动剪切好的文件到用户自定义路径
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
