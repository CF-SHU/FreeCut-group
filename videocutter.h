#pragma once

#include <QProcess>
#include <QObject>
#include <qqmlintegration.h>

class VideoCutter : public QObject
{
    Q_OBJECT
    QML_ELEMENT
public:
    explicit VideoCutter(QObject *parent = nullptr);
    Q_INVOKABLE void cutVideo(const QString &inputPath, const QString &outputPath, qint64 startSec, qint64 durationSec);
    Q_INVOKABLE void previewCut(const QString &inputPath, qint64 startSec, qint64 endSec);
    Q_INVOKABLE void getStartSec(qint64 startSec);
    Q_INVOKABLE void getEndSec(qint64 endSec);
    Q_INVOKABLE qint64 returnStartSec();
    Q_INVOKABLE qint64 returnEndSec();
    Q_INVOKABLE bool deletedir(const QString &dirpath);
    Q_INVOKABLE bool savefile(const QString &inputPath, const QString &outputPath);
    Q_INVOKABLE bool movefile(const QString &sourcePath, const QString &destinationDir);

signals:
    void progressChanged(int percent);                 // 进度更新信号
    void finished(bool success, const QString &error); // 完成信号

private slots:
    void handleProcessOutput(); // 处理FFmpeg日志

private:
    QProcess *m_process;
    qint64 startSec = 0;
    qint64 endSec = 0;
    qint64 m_durationSec = 0; // 存储持续时间用于进度计算
};
