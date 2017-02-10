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

QT += dbus

SOURCES += src/harbour-feedhaven.cpp \
    src/sharing.cpp

HEADERS += \
    src/sharing.h

OTHER_FILES += \
    rpm/harbour-feedhaven.spec \
    rpm/harbour-feedhaven.yaml \
    rpm/harbour-feedhaven.changes \
    translations/*.ts \
    harbour-feedhaven.desktop \
    feedly-api-config.pri \
    qml/harbour-feedhaven.qml \
    qml/lib/feedly.js \
    qml/lib/dbmanager.js \
    qml/components/Feedly.qml \
    qml/components/Settings.qml \
    qml/components/StatusIndicator.qml \
    qml/components/Field.qml \
    qml/components/ErrorIndicator.qml \
    qml/cover/DefaultCover.qml \
    qml/pages/SignInPage.qml \
    qml/pages/FeedsListPage.qml \
    qml/pages/ArticlesListPage.qml \
    qml/pages/ArticlePage.qml \
    qml/pages/AboutPage.qml \
    qml/pages/ArticleInfoPage.qml \
    qml/pages/FeedSearchPage.qml \
    qml/pages/ArticleSharePage.qml \
    qml/pages/SettingsPage.qml \
    qml/dialogs/SelectCategoriesDialog.qml \
    qml/dialogs/UpdateFeedDialog.qml

SAILFISHAPP_ICONS = 86x86 108x108 128x128 256x256

# to disable building translations every time, comment out the
# following CONFIG line
CONFIG += sailfishapp_i18n

# If you aren't planning to localize your app, remember to
# comment out the following TRANSLATIONS line. And also do
# not forget to modify the localized app name in the .desktop file.
TRANSLATIONS += \
    translations/harbour-feedhaven-it.ts \
    translations/harbour-feedhaven-es.ts

# Custom icons and images
images.files = assets/icons
images.path = /usr/share/$${TARGET}
INSTALLS += images

# App version
DEFINES += APP_VERSION=\"\\\"$${VERSION}\\\"\"

# Feedly API keys
FEEDLY_API_CONFIG = feedly-api-config.pri
exists($${FEEDLY_API_CONFIG}) include($${FEEDLY_API_CONFIG})

