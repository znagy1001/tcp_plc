#pragma once

#include <QObject>
#include <QTcpSocket>

class Comm : public QObject
{
    Q_OBJECT
    Q_PROPERTY(bool android READ getAndroid WRITE setAndroid)

public:
    explicit Comm(QObject *parent = nullptr);
    void initialize();

signals:
    void signalDataArrived(char x, char y);

public slots:
    void connect();
    void send();
    void disconnect();
    void receive();

    bool getAndroid()
    {
        #ifdef ANDROID
            return true;
        #else
            return false;
        #endif
    }
    void setAndroid(bool android) { Q_UNUSED(android); }

protected:
    bool android;
    QTcpSocket *socket = nullptr;
};
