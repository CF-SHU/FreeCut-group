// Watermark.cpp

#include "watermark.h"

Watermark::Watermark(QQuickItem *parent) : QQuickPaintedItem(parent)
{
    // connect(&m_timer, &QTimer::timeout, this, [this]() {
    //     // 更新水印位置
    //     m_position.setX(m_position.x() + 1 * m_direction);
    //     if (m_position.x() > width() || m_position.x() < 0) {
    //         m_direction *= -1; // 反转方向
    //     }
    connect(&m_timer, &QTimer::timeout, this, [this]() {
        // 更新水印位置
        m_position.setX(m_position.x() + m_directionX);
        m_position.setY(m_position.y() + m_directionY);

        // 边界检查
        if (m_position.x() >= width() || m_position.x() <= 0) {
            m_directionX *= -1; // 反转x方向
        }
        if (m_position.y() >= height() || m_position.y() <= 0) {
            m_directionY *= -1; // 反转y方向
        }

        update(); // 触发重绘
    });
    m_timer.start(50); // 每50毫秒更新一次
}

Watermark::~Watermark() {}

//将水印添加到视频中
void Watermark::addTextWatermarkToVideo(const QString &inputFile,
                                        const QString &outputFile,
                                        const QString &watermarkText,
                                        const QColor &color,
                                        const int &size)
{
    QProcess ffmpeg;
    QStringList args;

    // 将QColor转换为FFmpeg可接受的颜色格式（例如：白色为white，红色为red等）
    QString colorString
        = QString("%1,%2,%3,%4").arg(color.redF()).arg(color.greenF()).arg(color.blueF()).arg(color.alphaF());

    args << "-i" << inputFile;
    args << "-vf"
         << QString("drawtext=text='%1':x=mod(n\\, w)/2:y=mod(n\\, h)/10:fontsize=%2:fontcolor=%3:alpha=0.5")
                .arg(watermarkText)
                .arg(size)
                .arg(colorString);

    //args << "-vf" << QString("drawtext=text='%1':x=10:y=10:fontsize=24:fontcolor=white:alpha=0.7").arg(watermarkText);
    // args << "-c:v" << "libx264"; // 使用H.264编解码器
    // args << "-c:a" << "aac";     // 使用AAC音频编解码器
    // args << "-preset" << "fast"; // 编码速度和压缩率的平衡
    // args << "-crf" << "23";      // 控制视频质量
    args << outputFile;

    ffmpeg.start("ffmpeg", args);
    ffmpeg.waitForFinished(); // 等待FFmpeg完成
}

QString Watermark::text() const
{
    return m_text;
}
//设置水印的文本内容，并通知QML进行更新。
void Watermark::setText(const QString &text)
{
    if (m_text != text) {
        m_text = text;
        emit textChanged();
        update();
    }
}

QColor Watermark::color() const
{
    return m_color;
}

void Watermark::setColor(const QColor &color)
{
    if (m_color != color) {
        m_color = color;
        emit colorChanged();
        update();
    }
}

int Watermark::size() const
{
    return m_size;
}

void Watermark::setSize(int size)
{
    if (m_size != size) {
        m_size = size;
        emit sizeChanged();
        update();
    }
}
//返回当前水印的位置。
QPointF Watermark::position() const
{
    return m_position;
}
//设置水印的位置，并通知QML进行更新
void Watermark::setPosition(const QPointF &position)
{
    if (m_position != position) {
        m_position = position;
        emit positionChanged();
        update();
    }
}
//使用QPainter在指定的位置绘制水印文本。
void Watermark::paint(QPainter *painter)
{
    //设置颜色
    painter->setPen(m_color);
    // 设置字体和大小
    QFont font = painter->font();
    font.setPointSize(m_size);
    painter->setFont(font);
    //painter->setPen(Qt::red);              //设置文本颜色为红色
    //painter->setFont(QFont("Arial", 20));  //设置文本字体为Arial，字号为20
    // 绘制文本
    painter->drawText(m_position, m_text); //在m_position位置绘制m_text文本
}
