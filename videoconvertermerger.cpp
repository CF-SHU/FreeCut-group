#include "videoconvertermerger.h"
#include <QFileInfo>
#include <qregularexpression.h>

VideoConverterMerger::VideoConverterMerger(QObject *parent) : QObject{parent}
{
    m_process = new QProcess(this);
    //setupConnections();
}

void VideoConverterMerger::mergeDifferentFormatVideos(const QString &inputPath1,
                                                      const QString &inputPath2,
                                                      const QString &outputPath)
{
    // 验证输入文件
    if (!QFileInfo::exists(inputPath1)) {
        emit finished(false, "视频1文件不存在");
        return;
    }
    if (!QFileInfo::exists(inputPath2)) {
        emit finished(false, "视频2文件不存在");
        return;
    }

    // 构建FFmpeg命令（自动转码为mp4格式，然后保存到指定文件）
    QStringList args;
    args << "-y" // 覆盖输出文件
         << "-i" << inputPath1 << "-i" << inputPath2
         << "-filter_complex"
            "[0:v]scale=1280:720:force_original_aspect_ratio=decrease[v0];"                // 统一分辨率
            "[0:a]aformat=sample_fmts=fltp:sample_rates=44100:channel_layouts=stereo[a0];" // 统一音频格式
            "[1:v]scale=1280:720:force_original_aspect_ratio=decrease[v1];"
            "[1:a]aformat=sample_fmts=fltp:sample_rates=44100:channel_layouts=stereo[a1];"
            "[v0][a0][v1][a1]concat=n=2:v=1:a=1[outv][outa]"
         << "-map" << "[outv]"
         << "-map" << "[outa]"
         << "-c:v" << "libx264"
         << "-preset" << "fast"
         << "-crf" << "23" // 视频质量参数
         << "-c:a" << "aac"
         << "-b:a" << "192k" // 音频比特率
         << "-f" << "mp4"    // 指定输出容器格式
         << outputPath;

    //qDebug() << "执行命令: ffmpeg" << args;
    m_process->start("ffmpeg", args);
}

// void VideoConverterMerger::setupConnections()
// {
//     connect(m_process, &QProcess::readyReadStandardError, [this]() {
//         QString output = QString::fromLocal8Bit(m_process->readAllStandardError());

//         // 解析进度信息
//         static QRegularExpression re("time=(\\d+):(\\d+):(\\d+).(\\d+)");
//         auto match = re.match(output);
//         if (match.hasMatch()) {
//             int h = match.captured(1).toInt();
//             int m = match.captured(2).toInt();
//             int s = match.captured(3).toInt();
//             emit progressChanged((h * 3600 + m * 60 + s) % 100); // 简单示例
//         }
//         qDebug() << "[FFmpeg]" << output;
//     });

//     connect(m_process,
//             QOverload<int, QProcess::ExitStatus>::of(&QProcess::finished),
//             [this](int exitCode, QProcess::ExitStatus) {
//                 emit finished(exitCode == 0, exitCode == 0 ? "合并成功" : m_process->errorString());
//             });
// }
