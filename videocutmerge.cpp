#include "videocutmerge.h"
#include <QCoreApplication>
#include <QTemporaryDir>
#include <QTemporaryFile>
#include <QFile>
#include <QTextStream>
#include <QDebug>
#include <QProcess>
#include <QDir>

VideoCutMerge::VideoCutMerge(QObject *parent) : QObject{parent}
{
    tempDirPath = "tempdir";
    //  创建目录
    if (!QDir().mkdir(tempDirPath)) {
        qCritical() << "无法创建目录";
        return;
    }
    qDebug() << "已创建目录:" << tempDirPath;
}

bool VideoCutMerge::creadtefile()
{
    QString str = QString::number(a);
    tempFilePath = tempDirPath + "/tempfile" + str + ".txt";
    a++;
    QFile file(tempFilePath);
    if (!file.open(QIODevice::WriteOnly | QIODevice::Text)) {
        qCritical() << "无法创建文件";
        return 1;
    }
    file.close();
    qDebug() << "文件创建成功:" << tempFilePath;
    return true;
}

QString VideoCutMerge::returndirpath()
{
    QString str = QString::number(i);
    path = tempDirPath + "/" + str + ".mp4";
    path1 = str + ".mp4";
    i++;
    qDebug() << "临时目录中保存的视频文件路径：" << path;
    return path1;
}

QString VideoCutMerge::returnfilepath()
{
    return path;
}

bool VideoCutMerge::writepath(const QString &content)
{
    QFile file(tempFilePath);
    if (!file.open(QIODevice::Append | QIODevice::Text)) {
        qCritical() << "无法打开文件:" << tempFilePath;
        return false;
    }
    QTextStream out(&file);
    out << "file '" << QDir::toNativeSeparators(content) << "'\n";
    file.close();
    qDebug() << "路径写入成功:" << "file '" << QDir::toNativeSeparators(content) << "'\n";
    return true;
}

bool VideoCutMerge::mergeVideos(const QString &outputPath)
{
    qDebug() << "合并视频路径666666:" << tempFilePath;
    QFile file(tempFilePath);
    //if (!file.isOpen()) return false;
    if (!QFile::exists(tempFilePath)) {
        qCritical() << "列表文件不存在";
        return false;
    }

    // 确保文件内容已写入磁盘
    file.close();

    qDebug() << "合并视频路径1:" << tempFilePath;
    // FFmpeg 命令
    QStringList args;
    args << "-f" << "concat"
         << "-safe" << "0"
         << "-i" << tempFilePath << "-c" << "copy" << outputPath;

    qDebug() << "合并视频路径2:" << tempFilePath;
    QProcess ffmpeg;
    ffmpeg.start("ffmpeg", args);

    qDebug() << "合并视频路径3:" << tempFilePath;
    if (!ffmpeg.waitForStarted()) {
        qCritical() << "无法启动 FFmpeg";
        return false;
    }

    ffmpeg.waitForFinished(-1);

    if (ffmpeg.exitCode() != 0) {
        qCritical() << "FFmpeg 错误:" << ffmpeg.readAllStandardError();
        return false;
    }

    qDebug() << "视频合并完成，保存到:" << outputPath;
    return true;
}
