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

    //Q_INVOKABLE void cancel();

signals:
    void progressChanged(int percent);
    void finished(bool success, const QString& message);

private:
    QProcess* m_process;
    //void setupConnections();
    //bool validateInputFile(const QString& path);
};
