#pragma once

#include <QObject>
#include <QProcess>
#include <QtQml/qqmlregistration.h>

class VideoMusic : public QObject
{
    Q_OBJECT
    QML_ELEMENT
public:
    explicit VideoMusic(QObject* parent = nullptr);
    Q_INVOKABLE bool replaceAudio(const QString& videoPath, const QString& audioPath, const QString& outputPath);

    void replaceAudioAsync(const QString& videoPath,
                           const QString& audioPath,
                           const QString& outputPath,
                           std::function<void(bool)> callback);
};
