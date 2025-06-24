#include <QQuickPaintedItem>
#include <QPainter>
#include <QTimer>
#include <QProcess>

class Watermark : public QQuickPaintedItem
{
    Q_OBJECT
    QML_ELEMENT
    Q_PROPERTY(QString text READ text WRITE setText NOTIFY textChanged)
    Q_PROPERTY(QString color READ color WRITE setColor NOTIFY colorChanged)
    Q_PROPERTY(int size READ size WRITE setSize NOTIFY sizeChanged)
    Q_PROPERTY(double alpha READ alpha WRITE setAlpha NOTIFY alphaChanged)

    Q_PROPERTY(QPointF position READ position WRITE setPosition NOTIFY positionChanged)

public:
    explicit Watermark(QQuickItem *parent = nullptr);
    ~Watermark();

    Q_INVOKABLE QString text() const;
    Q_INVOKABLE QString color() const;
    Q_INVOKABLE int size() const;
    Q_INVOKABLE double alpha() const;

    Q_INVOKABLE void setText(const QString &text);
    Q_INVOKABLE void setColor(const QString &color);
    Q_INVOKABLE void setSize(int size);
    Q_INVOKABLE void setAlpha(double alpha);

    Q_INVOKABLE QPointF position() const;
    Q_INVOKABLE void setPosition(const QPointF &position);
    Q_INVOKABLE void addTextWatermarkToVideo(const QString &inputFile,
                                             const QString &outputFile,
                                             const QString &watermarkText,
                                             const QString &color,
                                             const int &size,
                                             const double &alpha);
signals:
    void textChanged();
    void colorChanged();
    void sizeChanged();
    void positionChanged();
    void alphaChanged();
    void watermarkAdded(); // 新增信号，用于通知水印添加完成

protected:
    void paint(QPainter *painter) override;

private:
    QString m_text;
    QString m_color;
    int m_size;
    double m_alpha;
    QPointF m_position;
    QTimer m_timer;
    int m_direction = 1;  // 用于控制移动方向
    int m_directionX = 1; // 控制x方向的移动
    int m_directionY = 1; // 控制y方向的移动
};
