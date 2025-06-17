#pragma once

#include <QObject>
#include <QProcess>
#include <QtQml/qqmlregistration.h>

class VideoPlay : public QObject
{
    Q_OBJECT
    QML_ELEMENT
public:
    explicit VideoPlay(QObject *parent = nullptr);
    Q_INVOKABLE bool play(const QString &filePath);
    void stop();

signals:
    void playbackStarted();
    void playbackFinished();
    void error(const QString &message);

private slots:
    void onPlaybackFinished(int exitCode, QProcess::ExitStatus exitStatus);

private:
    QString findFFplay();
    QProcess *m_process = nullptr;
};
