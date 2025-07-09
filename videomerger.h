//videomerger.h
#pragma once

#include <QObject>
#include <QProcess>
#include <QString>
#include <qqmlintegration.h>

class VideoMerger : public QObject
{
    Q_OBJECT
    QML_ELEMENT
public:
    explicit VideoMerger(QObject* parent = nullptr);

    Q_INVOKABLE void mergeVideos(const QString& inputPath1, const QString& inputPath2, const QString& outputPath);

signals:
    void progressChanged(int percent);
    void finished(bool success, const QString& message);

private:
    QProcess* m_process;
};
