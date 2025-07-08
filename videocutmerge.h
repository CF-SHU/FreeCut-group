#pragma once

#include <QCoreApplication>
#include <QTemporaryDir>
#include <QTemporaryFile>
#include <QFile>
#include <QTextStream>
#include <QDebug>
#include <QProcess>
#include <QDir>
#include <QObject>
#include <qqmlintegration.h>

class VideoCutMerge : public QObject
{
    Q_OBJECT
    QML_ELEMENT

public:
    explicit VideoCutMerge(QObject* parent = nullptr);
    Q_INVOKABLE bool creadtefile();
    Q_INVOKABLE QString returndirpath();
    Q_INVOKABLE QString returnfilepath();
    Q_INVOKABLE bool writepath(const QString& content);
    Q_INVOKABLE bool mergeVideos(const QString& outputPath);

    ~VideoCutMerge()
    {
        // 析构时删除临时文件
        // tempFile.remove();
        // 3. 确保程序退出时删除目录（即使发生异常）
        auto cleanup = qScopeGuard([&] {
            QDir dir(tempDirPath);
            if (dir.exists()) {
                dir.removeRecursively();
                qDebug() << "已清理临时目录";
            }
        });
    }

private:
    QString tempFilePath;
    QString tempDirPath;
    QFile file;
    int i = 0;
    int a = 0;
    QString path;
    QString path1;
};
