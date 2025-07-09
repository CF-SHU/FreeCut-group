//watermark.cpp
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
                                        const QString &color,
                                        const int &size,
                                        const double &alpha)
{
    QProcess ffmpeg;
    QStringList args;

    // 设置环境变量
    QProcessEnvironment env = QProcessEnvironment::systemEnvironment();
    env.insert("PATH", "/usr/local/bin:/usr/bin:/bin");
    env.insert("LD_LIBRARY_PATH", "/usr/local/lib:/usr/lib");

    // 设置DISPLAY变量（Linux必需）
    if (!env.contains("DISPLAY")) { env.insert("DISPLAY", ":0"); }
    ffmpeg.setProcessEnvironment(env);

    args << "-i" << inputFile;
    args << "-vf"
         << QString("drawtext=text='%1':x=mod(n\\, w)/2:y=mod(n\\, h)/10:fontsize=%2:fontcolor=%3:alpha=%4")
                .arg(watermarkText)
                .arg(size)
                .arg(color)
                .arg(alpha, 0, 'f', 1); // 浮点数，保留一位小数

    args << outputFile;

    // 打印完整的命令
    qDebug() << "FFmpeg command: ffmpeg" << args.join(" ");

    ffmpeg.start("ffmpeg", args);
    ffmpeg.waitForFinished(); // 等待FFmpeg完成

    // 发出信号，通知水印添加完成
    emit watermarkAdded();
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

QString Watermark::color() const
{
    return m_color;
}

void Watermark::setColor(const QString &color)
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
double Watermark::alpha() const
{
    return m_alpha;
}

void Watermark::setAlpha(double alpha)
{
    if (m_alpha != alpha) {
        m_alpha = alpha;
        emit alphaChanged();
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

    // 绘制文本
    painter->drawText(m_position, m_text); //在m_position位置绘制m_text文本
}
