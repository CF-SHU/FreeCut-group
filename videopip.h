//videopip.h
#pragma once

#include <QObject>
#include <QProcess>
#include <QString>
#include <QtQml/qqmlregistration.h>

class VideoPip : public QObject
{
    Q_OBJECT
    QML_ELEMENT
public:
    explicit VideoPip(QObject* parent = nullptr);
    Q_INVOKABLE void videoInsertPip(const QString& backVideoPath,
                                    const QString& pipVideoPath,
                                    const QString& outputPath,
                                    double pipDuration,
                                    double pipX,
                                    double pipY);
signals:
    void processingFinished(const QString& outputPath);
    void processingError(const QString& errorMessage);
    void ffmpegError(const QString& errorOutput);

private:
    QProcess* m_process;
};
