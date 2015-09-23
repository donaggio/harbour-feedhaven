#ifndef SHARING_H
#define SHARING_H

#include <QObject>
#include <QDBusInterface>
#include <QDBusReply>

class Sharing : public QObject
{
    Q_OBJECT
public:
    explicit Sharing(QObject *parent = 0);
    Q_INVOKABLE void email(QString subject = "", QString body = "");
    Q_INVOKABLE void sms(QString body = "");

signals:

public slots:

};

#endif // SHARING_H
