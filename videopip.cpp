#include "videopip.h"
#include <QDir>
#include <QDebug>
#include <QProcessEnvironment>

VideoPip::VideoPip(QObject *parent) : QObject{parent}, m_process(nullptr) {}

void VideoPip::videoInsertPip(const QString &backVideoPath,
                              const QString &pipVideoPath,
                              const QString &outputPath,
                              double pipDuration,
                              double pipX,
                              double pipY)
{
    if (m_process) {
        m_process->kill();
        m_process->deleteLater();
        m_process = nullptr;
    }

    m_process = new QProcess(this);

    // 设置环境变量
    QProcessEnvironment env = QProcessEnvironment::systemEnvironment();
    env.insert("PATH", "/usr/local/bin:/usr/bin:/bin");
    env.insert("LD_LIBRARY_PATH", "/usr/local/lib:/usr/lib");
    if (!env.contains("DISPLAY")) { env.insert("DISPLAY", ":0"); }
    m_process->setProcessEnvironment(env);

    //构建FFmpeg命令
    QStringList args;
    args << "-hwaccel" << "none" // 禁用硬件加速（分为两个参数）
         << "-y"
         << "-i" << backVideoPath << "-i" << pipVideoPath << "-filter_complex";

    //滤镜
    QString filter = QString("[1:v]scale=iw/4:-1:force_original_aspect_ratio=decrease,"
                             "pad=ceil(iw/2)*2:ceil(ih/2)*2:color=black [pip];"
                             "[0:v][pip]overlay=%1:%2:enable='lte(t,%3)'[v]")
                         .arg(pipX)
                         .arg(pipY)
                         .arg(pipDuration);

    args << filter << "-map" << "[v]" // 映射处理后的视频流
         << "-map" << "0:a?"          // 映射背景音频（如果存在）
         << "-c:v" << "libx264"
         << "-pix_fmt" << "yuv420p" << outputPath;

    m_process->start("ffmpeg", args);

    // 使用超时等待而不是无限等待
    if (!m_process->waitForFinished(30000)) { // 30秒超时
        qDebug() << "处理超时，终止进程";
        m_process->terminate();
        if (!m_process->waitForFinished(5000)) { m_process->kill(); }
    }

    connect(m_process, &QProcess::finished, this, [=, this](int exitCode, QProcess::ExitStatus) {
        QString result = (exitCode == 0) ? "成功" : "失败";
        qDebug() << "FFmpeg进程结束:" << result << "，退出码:" << exitCode;
        emit processingFinished(result);
    });

    // 检查执行结果
    if (m_process->exitStatus() == QProcess::NormalExit && m_process->exitCode() == 0) {
        qDebug() << "视频处理成功，输出文件:" << outputPath;
    } else {
        qDebug() << "处理失败，退出代码:" << m_process->exitCode();
        qDebug() << "错误信息:" << m_process->readAllStandardError();
    }
}
