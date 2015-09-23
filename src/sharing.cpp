#include "sharing.h"

Sharing::Sharing(QObject *parent) :
    QObject(parent)
{
}

void Sharing::email(QString subject, QString body)
{
    QDBusInterface *emailService = new QDBusInterface("com.jolla.email.ui", "/com/jolla/email/ui", "com.jolla.email.ui");

    if (emailService->isValid())
    {
        emailService->call(QDBus::NoBlock, "compose", subject, "", "", "", body);
    }

    delete emailService;
}

void Sharing::sms(QString body)
{
    QDBusInterface *smsService = new QDBusInterface("org.nemomobile.qmlmessage", "/", "org.nemomobile.qmlmessage");

    if (smsService->isValid())
    {
        // WARNING! NOT READY YET: IT IS NOT POSSIBLE TO INVOKE SMS COMPOSER WITHOUT A RECIPIENT
        smsService->call(QDBus::NoBlock, "startSMS", (QStringList() << ""), body);
    }

    delete smsService;
}
