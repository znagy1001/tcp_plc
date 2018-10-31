#pragma once

#include <QObject>
#include <QThread>
#include <QTcpSocket>
#include <functional>
using namespace std;

class CommThread : public QThread
{
    Q_OBJECT
public:
    explicit CommThread(QObject *parent = nullptr);
    void initialize();
    void run();
    void close();

signals:
    void signalConnect();
    void signalDataArrived(char x, char y);
    void signalSend(QByteArray c);
    void signalClose();

public slots:
    void connect();
    void onConnect();
    void send(QByteArray c);
    void onSend(QByteArray c);
    void onConnected();
    void onReadyRead();
    void disconnect();
    void onDisconnected();
    void onClose();

protected:
    QTcpSocket *socket = nullptr;
};
