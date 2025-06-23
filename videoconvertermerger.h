#pragma once

#include <QObject>
#include <QProcess>
#include <QtQml/qqmlregistration.h>

class VideoConverterMerger : public QObject
{
    Q_OBJECT
    QML_ELEMENT
public:
    explicit VideoConverterMerger(QObject* parent = nullptr);

    Q_INVOKABLE void mergeDifferentFormatVideos(const QString& inputPath1,
                                                const QString& inputPath2,
                                                const QString& outputPath);

signals:
    void progressChanged(int percent);
    void finished(bool success, const QString& message);

private:
    QProcess* m_process;
    void setupConnections();
};
