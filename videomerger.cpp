#include "videomerger.h"
#include <qdebug.h>

VideoMerger::VideoMerger(QObject *parent) : QObject{parent}{}

void VideoMerger::mergeVideos(const QString &inputPath1, const QString &inputPath2, const QString &outputPath)
{
    // 验证输入文件
    //if (!validateInputFile(inputPath1) || !validateInputFile(inputPath2)) { return; }

    if (m_process) {
        m_process->kill();
        m_process->deleteLater();
        m_process = nullptr; // 重置指针
    }
    m_process = new QProcess(this);

    // 设置环境变量
    QProcessEnvironment env = QProcessEnvironment::systemEnvironment();
    env.insert("PATH", "/usr/local/bin:/usr/bin:/bin");
    env.insert("LD_LIBRARY_PATH", "/usr/local/lib:/usr/lib");

    // 设置DISPLAY变量（Linux必需）
    if (!env.contains("DISPLAY")) { env.insert("DISPLAY", ":0"); }
    m_process->setProcessEnvironment(env);

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
    m_process->waitForFinished();
}
