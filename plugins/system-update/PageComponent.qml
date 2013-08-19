/*
 * This file is part of system-settings
 *
 * Copyright (C) 2013 Canonical Ltd.
 *
 * Contact: Didier Roche <didier.roches@canonical.com>
 *
 * This program is free software: you can redistribute it and/or modify it
 * under the terms of the GNU General Public License version 3, as published
 * by the Free Software Foundation.
 *
 * This program is distributed in the hope that it will be useful, but
 * WITHOUT ANY WARRANTY; without even the implied warranties of
 * MERCHANTABILITY, SATISFACTORY QUALITY, or FITNESS FOR A PARTICULAR
 * PURPOSE.  See the GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License along
 * with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

import QtQuick 2.0
import SystemSettings 1.0
import Ubuntu.Components 0.1
import Ubuntu.Components.ListItems 0.1 as ListItem
import Ubuntu.SystemSettings.Update 1.0


ItemPage {
    id: root

    title: i18n.tr("Update")
    flickable: scrollWidget // maybe remove

    UbuntuUpdatePanel {
        id: updateBackend


        property bool updateInProgress: false
        property bool updateReady: false
        property bool updateCanceled: false

        // FIXME: those should be taken from the backend
        property string lastUpdateDate: "1983-09-13"
        property string downloadRemainingTime: "40 seconds"
        property variant updateDescriptions: ["Enables a 200x improvment on Ubuntu Edge phone",
                                              "Makes you a sandwich",
                                              "Makes Steve and Loic happy"]

        // REMOVEME: fake update available
        updateAvailable: 1


        function startUpdate() {
            updateInProgress= true;
            updateReady = false;
            updateCanceled = false;
            TriggerUpdate();
        }

        onReadyToReboot: {
            updateInProgress = true;
            updateReady = true;
            updateCanceled = false;
        }
        onUpdateFailed: {
            PopupUtils.open(updateFailedDialog)
            updateInProgress = false;
            updateReady = false;
            updateCanceled = false;
            updateAvailable = -1;
        }
        onUpdateCanceled: {
            updateInProgress = false;
            updateReady = false;
            updateCanceled = true;
            updateAvailable = 1;
        }

        onUpdateAvailableChanged: {
            if (updateBackend.updateAvailable === 1) {
                //statusDetails.opacity = 1.0;
                //actionbuttons.text = actionbuttons.default_text;
            }
            else
                statusDetails.opacity = 0.0;
        }

    }

    Flickable {
        id: scrollWidget
        anchors.fill: parent
        contentHeight: contentItem.childrenRect.height
        boundsBehavior: (contentHeight > root.height) ? Flickable.DragAndOvershootBounds : Flickable.StopAtBounds

        Column {
            width: parent.width
            ListItem.Base {
                height: {
                    if (updateBackend.updateAvailable === 1)
                        return updateContentDisplay.height+ units.gu(4);
                    else
                        return updateStatusbar.height + checkUpdateIndicator.height + units.gu(6);
                }

                Column {
                    anchors.centerIn: parent
                    width: parent.width
                    spacing: units.gu(2)

                    ActivityIndicator {
                        id: checkUpdateIndicator
                        anchors.horizontalCenter: parent.horizontalCenter
                        running: updateBackend.updateAvailable < 0
                        visible: running
                    }
                    Label {
                        id: updateStatusbar
                        //FIXME: doesn't center because of width (but activity indicator is centered)
                        // but we need a width or something to have the wrapMode working
                        width: parent.width
                        anchors.horizontalCenter: parent.horizontalCenter

                        text: { if (updateBackend.updateAvailable === 0)
                                  return i18n.tr("No software update available\nLast updated %1").arg(updateBackend.lastUpdateDate);
                                return i18n.tr("Checking for updates"); }
                        visible: updateBackend.updateAvailable < 1
                        wrapMode: Text.WordWrap
                    }

                    Column {
                        id: updateContentDisplay
                        visible: updateBackend.updateAvailable === 1
                        width: parent.width
                        spacing: units.gu(2)

                        Icon {
                            id: distribLogo
                            anchors.horizontalCenter: parent.horizontalCenter
                            width: units.gu(6)
                            height: width
                            name: "distributor-logo"
                        }

                        Row {
                            width: parent.width

                            Label {
                                width: parent.width/2
                                text: i18n.tr("Ubuntu Phone")
                            }

                            Label {
                                horizontalAlignment: Text.AlignRight
                                width: parent.width/2
                                text: updateBackend.updateSize;
                            }
                        }

                        // FIXME: use the right widget then
                        ListItem.ValueSelector {
                            text: i18n.tr("Version %1").arg(updateBackend.updateVersion)
                            values: updateBackend.updateDescriptions
                            selectedIndex: -1
                        }

                        Column {
                            id: updateDownloading
                            spacing: units.gu(1)
                            width: parent.width

                            ProgressBar {
                                id: updateProgress
                                maximumValue : 100
                                minimumValue : 0
                                value : 70
                                width: parent.width
                                visible: true // updateBackend.updateInProgress && !updateBackend.updateReady
                            }

                            Label {
                                text: i18n.tr("About %1 remaining").arg(updateBackend.downloadRemainingTime)
                            }

                            Button {
                                id: pauseDownloadButton
                                text: i18n.tr("Pause downloading")
                                width: parent.width
                                onClicked: updateBackend.startUpdate()
                                visible: !updateBackend.updateInProgress
                            }

                            Button {
                                text: i18n.tr("Resume downloading")
                                width: parent.width
                                onClicked: updateBackend.startUpdate()
                                visible: !pauseDownloadButton.visible
                            }

                        }

                        Column {
                            id: updateStopped
                            spacing: units.gu(1)
                            width: parent.width

                            Button {
                                text: i18n.tr("Download")
                                width: parent.width
                                onClicked: updateBackend.startUpdate()
                                visible: !updateBackend.updateInProgress
                            }

                            Label {
                                text: i18n.tr("<b>Download is failing:</b><br/>%1").arg("The update server is not responding. Try again later.")
                                wrapMode: Text.WordWrap
                                textFormat: Text.RichText
                                visible: true
                            }

                            Button {
                                text: i18n.tr("Retry")
                                width: parent.width
                                onClicked: updateBackend.startUpdate()
                                visible: !updateBackend.updateInProgress
                            }

                            Button {
                                text: i18n.tr("Install & Restart")
                                width: parent.width
                                onClicked: updateBackend.startUpdate()
                                visible: !updateBackend.updateInProgress
                            }

                        }



                    }

                    /*ProgressBar {
                        id: indeterminateBar
                        anchors.left: parent.left
                        anchors.right: parent.right

                        indeterminate: true
                        visible: updateBackend.updateInProgress && !updateBackend.updateReady
                    }*/
                }

            }

            ListItem.ValueSelector {
                id: upgradePolicySelector
                expanded: true
                // TODO: There is no way to have a ValueSelector always expanded
                onExpandedChanged: expanded = true
                text: i18n.tr("Download future updates automatically:")
                values: [i18n.tr("Never"),
                    i18n.tr("When on wi-fi"),
                    // TODO: Data charges may apply needs to be smaller
                    i18n.tr("On any data connection\nData charges may apply.")]
                // FIXME
                selectedIndex: 0
                //FIXME
                /*onSelectedIndexChanged: {
                    if (selectedIndex == 0)
                        connMan.powered = false;
                    else
                        connMan.powered = true;
                }*/
            }


            /*ListItem.Standard {
                id: statusDetails

                Column {

                    ListItem.Standard {
                        id: actionbuttons
                        property string default_text: i18n.tr("Apply?")
                        text: default_text
                        control: Row {
                            spacing: units.gu(1)
                            Button {
                                text: i18n.tr("Update your phone")
                                width: units.gu(19)
                                onClicked: updateBackend.startUpdate()
                                visible: !updateBackend.updateInProgress
                            }
                            Button {
                                text: i18n.tr("Cancel update")
                                width: units.gu(19)
                                onClicked: updateBackend.CancelUpdate()
                                visible: updateBackend.updateInProgress
                            }
                            Button {
                                text: i18n.tr("Reboot your phone now")
                                width: units.gu(25)
                                onClicked: updateBackend.Reboot()
                                visible: updateBackend.updateInProgress && updateBackend.updateReady
                            }
                        }
                    }
                }
            }
        }
    }
        }*/
        }
    }
}
