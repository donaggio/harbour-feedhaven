# NOTICE:
#
# Application name defined in TARGET has a corresponding QML filename.
# If name defined in TARGET is changed, the following needs to be done
# to match new name:
#   - corresponding QML filename must be changed
#   - desktop icon filename must be changed
#   - desktop filename must be changed
#   - icon definition filename in desktop file must be changed
#   - translation filenames have to be changed
TARGET = harbour-feedhaven

CONFIG += sailfishapp

SOURCES += src/harbour-feedhaven.cpp

OTHER_FILES += qml/harbour-feedhaven.qml \
    rpm/harbour-feedhaven.spec \
    rpm/harbour-feedhaven.yaml \
    translations/*.ts \
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
    feedly-api-config.pri \
    qml/pages/ArticleInfoPage.qml \
    qml/cover/DefaultCover.qml \
    qml/cover/ArticlesListCover.qml \
    qml/cover/ArticleContentCover.qml

# to disable building translations every time, comment out the
# following CONFIG line
CONFIG += sailfishapp_i18n
TRANSLATIONS += translations/harbour-feedhaven-it.ts

DEFINES += APP_VERSION=\"\\\"$$VERSION\\\"\"

FEEDLY_API_CONFIG = feedly-api-config.pri
exists($$FEEDLY_API_CONFIG) include($$FEEDLY_API_CONFIG)
