#ifdef QT_QML_DEBUG
#include <QtQuick>
#endif

#ifndef VERSION
#define VERSION "0.0"
#endif

#include <QScopedPointer>
#include <QVariant>
#include <QLocale>
#include <QTranslator>
#include <QGuiApplication>
#include <QQuickView>
//#include <QQmlContext>
#include <sailfishapp.h>


int main(int argc, char *argv[])
{
    // SailfishApp::main() will display "qml/template.qml", if you need more
    // control over initialization, you can use:
    //
    //   - SailfishApp::application(int, char *[]) to get the QGuiApplication *
    //   - SailfishApp::createView() to get a new QQuickView * instance
    //   - SailfishApp::pathTo(QString) to get a QUrl to a resource file
    //
    // To display the view, call "show()" (will show fullscreen on device).

//    return SailfishApp::main(argc, argv);

    QScopedPointer<QGuiApplication> app(SailfishApp::application(argc, argv));
    QScopedPointer<QQuickView> view(SailfishApp::createView());
    QTranslator translator;

    translator.load(QLocale::system().name(), SailfishApp::pathTo(QString("l10n")).toLocalFile());
    app->installTranslator(&translator);

//    app->setOrganizationName("");
//    app->setOrganizationDomain("");
//    app->setApplicationName("harbour-feedhaven");
    app->setApplicationVersion(QString(VERSION));

    view->rootContext()->setContextProperty(QString("version"), QVariant(VERSION));
    view->setSource(SailfishApp::pathTo(QString("qml/harbour-feedhaven.qml")));
    view->show();
    return app->exec();
}

