set(QML_SOURCES PageComponent.qml Download.qml)
add_library(UbuntuUpdatePanel MODULE plugin.h update.h plugin.cpp update.cpp
${QML_SOURCES})
qt5_use_modules(UbuntuUpdatePanel Qml Quick DBus)

set(PLUG_DIR ${PLUGIN_PRIVATE_MODULE_DIR}/Ubuntu/SystemSettings/Update)
install(TARGETS UbuntuUpdatePanel DESTINATION ${PLUG_DIR})
install(FILES qmldir DESTINATION ${PLUG_DIR})
install(FILES ${QML_SOURCES} DESTINATION ${PLUGIN_QML_DIR}/system-update)

install(FILES system-update.settings DESTINATION ${PLUGIN_MANIFEST_DIR})
install(FILES settings-system-update.svg distributor-logo.png DESTINATION ${PLUGIN_MANIFEST_DIR}/icons)