#pragma once

#include <QObject>
#include <iostream>

class VideoMerge : public QObject
{
    Q_OBJECT
public:
    explicit VideoMerge(QObject *parent = nullptr);

signals:
private:
};
