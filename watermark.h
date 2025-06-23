// Watermark.h
#include <QQuickPaintedItem>
#include <QPainter>
#include <QTimer>
#include <QProcess>

class Watermark : public QQuickPaintedItem
{
    Q_OBJECT
    QML_ELEMENT
    Q_PROPERTY(QString text READ text WRITE setText NOTIFY textChanged)
    Q_PROPERTY(QColor color READ color WRITE setColor NOTIFY colorChanged)
    Q_PROPERTY(int size READ size WRITE setSize NOTIFY sizeChanged)
    Q_PROPERTY(QPointF position READ position WRITE setPosition NOTIFY positionChanged)

public:
    explicit Watermark(QQuickItem *parent = nullptr);
    ~Watermark();

    Q_INVOKABLE QString text() const;
    Q_INVOKABLE QColor color() const;
    Q_INVOKABLE void setText(const QString &text);
    Q_INVOKABLE int size() const;
    Q_INVOKABLE void setColor(const QColor &color);
    Q_INVOKABLE void setSize(int size);

    Q_INVOKABLE QPointF position() const;
    Q_INVOKABLE void setPosition(const QPointF &position);
    Q_INVOKABLE void addTextWatermarkToVideo(const QString &inputFile,
                                             const QString &outputFile,
                                             const QString &watermarkText,
                                             const QColor &color,
                                             const int &size);
signals:
    void textChanged();
    void colorChanged();
    void sizeChanged();
    void positionChanged();

protected:
    void paint(QPainter *painter) override;

private:
    QString m_text;
    QColor m_color;
    int m_size;
    QPointF m_position;
    QTimer m_timer;
    int m_direction = 1;  // 用于控制移动方向
    int m_directionX = 1; // 控制x方向的移动
    int m_directionY = 1; // 控制y方向的移动
};
