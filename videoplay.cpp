#include "videoplay.h"
#include <QFile>
#include <QProcess>
#include <QDir>
#include <QCoreApplication>
#include <QStandardPaths>

VideoPlay::VideoPlay(QObject *parent) : QObject{parent} {}

bool VideoPlay::play(const QString &filePath)
{
    m_process = new QProcess(this);
    QString playerPath = findFFplay();
    if (playerPath.isEmpty()) {
        emit error("FFplay not found");
        return false;
    }

    if (!QFile::exists(filePath)) {
        emit error("Video file not found");
        return false;
    }

    if (m_process) {
        m_process->kill();
        m_process->deleteLater();
    }

    connect(m_process,
            QOverload<int, QProcess::ExitStatus>::of(&QProcess::finished),
            this,
            &VideoPlay::onPlaybackFinished);

    QStringList args;
    args << "-i" << QDir::toNativeSeparators(filePath) << "-autoexit"
         << "-loglevel" << "quiet";

    m_process->start(playerPath, args);

    if (!m_process->waitForStarted(3000)) {
        emit error("Failed to start player: " + m_process->errorString());
        return false;
    }

    m_process->waitForFinished();
    return true;
}

void VideoPlay::stop()
{
    if (m_process) { m_process->kill(); }
}

void VideoPlay::onPlaybackFinished(int exitCode, QProcess::ExitStatus exitStatus)
{
    Q_UNUSED(exitCode)
    Q_UNUSED(exitStatus)
    emit playbackFinished();
}

QString VideoPlay::findFFplay()
{
    // 检查应用程序目录
    QString appDir = QCoreApplication::applicationDirPath();

    // 检查系统PATH
    return QStandardPaths::findExecutable("ffplay");
}
