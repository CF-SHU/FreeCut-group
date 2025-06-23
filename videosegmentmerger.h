#pragma once

#include <QObject>
#include <QProcess>
#include <QString>
#include <QRegularExpression> // 添加正则表达式头文件
#include <QDebug>
#include <QtQml/qqmlregistration.h>

class VideoSegmentMerger : public QObject
{
    Q_OBJECT
    QML_ELEMENT
public:
    explicit VideoSegmentMerger(QObject* parent = nullptr);

    Q_INVOKABLE void mergeTwoSegments(const QString& video1Path,
                                      double video1Start,
                                      double video1End,
                                      const QString& video2Path,
                                      double video2Start,
                                      double video2End,
                                      const QString& outputPath);

signals:
    void progressChanged(int percent);
    void finished(bool success, const QString& message);
    void segmentFinished(bool success, const QString& outputPath); // 增加输出路径参数

private:
    QProcess* m_process;
};
