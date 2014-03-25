# The name of your app.
# NOTICE: name defined in TARGET has a corresponding QML filename.
#         If name defined in TARGET is changed, following needs to be
#         done to match new name:
#         - corresponding QML filename must be changed
#         - desktop icon filename must be changed
#         - desktop filename must be changed
#         - icon definition filename in desktop file must be changed
TARGET = harbour-feedhaven

CONFIG += sailfishapp

SOURCES += src/harbour-feedhaven.cpp

OTHER_FILES += qml/harbour-feedhaven.qml \
    qml/cover/CoverPage.qml \
    rpm/harbour-feedhaven.spec \
    rpm/harbour-feedhaven.yaml \
    harbour-feedhaven.desktop \
    qml/lib/feedly.js \
    qml/pages/SignInPage.qml \
    qml/pages/FeedsListPage.qml \
    qml/pages/ArticlesListPage.qml \
    qml/pages/ArticlePage.qml \
    qml/lib/dbmanager.js \
    qml/components/Feedly.qml \
    qml/components/StatusIndicator.qml \
    qml/pages/AboutPage.qml \
    feedly-api-config.pri

lupdate_only {
    SOURCES += qml/*.qml \
        qml/pages/*.qml \
        qml/components/*.qml \
        qml/cover/*.qml \
        qml/lib/*.js
}

TRANSLATIONS += harbour-feedhaven-it.ts

DEFINES += APP_VERSION=\"\\\"$$VERSION\\\"\"

include("feedly-api-config.pri")
