/***************************************************************************            *
 *   Copyright 2026 by Barnak Zlatko <zlatkobarnak@equilibriumos.com>             *
 *                                                                         *
 *   This program is free software; you can redistribute it and/or modify  *
 *   it under the terms of the GNU General Public License as published by  *
 *   the Free Software Foundation; either version 2 of the License, or     *
 *   (at your option) any later version.                                   *
 *                                                                         *
 *   This program is distributed in the hope that it will be useful,       *
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of        *
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the         *
 *   GNU General Public License for more details.                          *
 *                                                                         *
 *   You should have received a copy of the GNU General Public License     *
 *   along with this program; if not, write to the                         *
 *   Free Software Foundation, Inc.,                                       *
 *   51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA .        *
 ***************************************************************************/

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import QtQuick.Window
import QtWebEngine
import org.kde.plasma.plasmoid
import org.kde.plasma.components as PlasmaComponents
import org.kde.plasma.extras as PlasmaExtras

PlasmoidItem {
    id: root

    preferredRepresentation: compactRepresentation

    // 1. KOMPAKTAN PRIKAZ NA PANELU (Glavna ikona + "Minimize All" + velike ikone aplikacija bez margina)
    compactRepresentation: Item {
        id: compactContainer
        Layout.minimumWidth: compactLayout.implicitWidth > 0 ? compactLayout.implicitWidth : units.iconSizes.large
        Layout.minimumHeight: units.iconSizes.large
        Layout.preferredWidth: compactLayout.implicitWidth > 0 ? compactLayout.implicitWidth : units.iconSizes.large
        Layout.preferredHeight: units.iconSizes.large

        RowLayout {
            id: compactLayout
            anchors.centerIn: parent
            spacing: 2

            // Glavna ikona (eq-wal.svg) - velika, bez margina
            Item {
                Layout.preferredWidth: 40
                Layout.preferredHeight: 40
                Layout.minimumWidth: 40
                Layout.minimumHeight: 40

                Rectangle {
                    anchors.fill: parent
                    radius: 8
                    color: mainMouse.containsMouse ? Qt.rgba(1, 1, 1, 0.2) : "transparent"
                    border.color: mainMouse.containsMouse ? "#38BDF8" : "transparent"
                    border.width: 1

                    Image {
                        anchors.fill: parent
                        anchors.margins: 4
                        source: Qt.resolvedUrl("assets/eq-wal.svg")
                        fillMode: Image.PreserveAspectFit
                        smooth: true
                    }
                }

                MouseArea {
                    id: mainMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: root.expanded = !root.expanded
                }
            }

            // DUGME: Minimize All na panelu
            Item {
                visible: activeAppsModel.count > 0
                Layout.preferredWidth: visible ? 30 : 0
                Layout.preferredHeight: 40
                Layout.minimumWidth: visible ? 30 : 0
                Layout.minimumHeight: 40

                Rectangle {
                    anchors.fill: parent
                    radius: 8
                    color: minAllMouse.containsMouse ? Qt.rgba(1, 1, 1, 0.2) : Qt.rgba(1, 1, 1, 0.05)
                    border.color: minAllMouse.containsMouse ? "#38BDF8" : "transparent"
                    border.width: 1

                    PlasmaComponents.ToolButton {
                        anchors.centerIn: parent
                        width: 24
                        height: 24
                        icon.name: "window-minimize-panel"
                        ToolTip.text: "Minimize All Web Apps"
                        ToolTip.visible: minAllMouse.containsMouse
                        onClicked: {
                            for (var i = 0; i < activeAppsModel.count; i++) {
                                var win = activeAppsModel.get(i).windowRef;
                                if (win) {
                                    win.showMinimized();
                                }
                            }
                        }
                    }
                }

                MouseArea {
                    id: minAllMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    acceptedButtons: Qt.NoButton
                }
            }

            // Otvorene web aplikacije na panelu - maksimizovane bez margina
            Repeater {
                model: activeAppsModel

                delegate: Item {
                    Layout.preferredWidth: 40
                    Layout.preferredHeight: 40
                    Layout.minimumWidth: 40
                    Layout.minimumHeight: 40

                    Rectangle {
                        id: activeBtnRect
                        anchors.fill: parent
                        radius: 8
                        color: activeMouse.containsMouse ? Qt.rgba(1, 1, 1, 0.2) : Qt.rgba(1, 1, 1, 0.1)
                        border.color: activeMouse.containsMouse ? "#38BDF8" : "transparent"
                        border.width: 1

                        Image {
                            anchors.fill: parent
                            anchors.margins: 4
                            source: model.icon || ""
                            fillMode: Image.PreserveAspectFit
                            smooth: true
                        }
                    }

                    MouseArea {
                        id: activeMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: {
                            if (model.windowRef) {
                                if (model.windowRef.visibility === Window.Minimized) {
                                    model.windowRef.showNormal();
                                }
                                model.windowRef.requestActivate();
                                model.windowRef.raise();
                            }
                        }
                    }
                }
            }
        }
    }

    // 2. PROŠIRENI PRIKAZ (Meni sa levom trakom i desnom listom sačuvanih)
    fullRepresentation: PlasmaExtras.Representation {
        Layout.minimumWidth: 540
        Layout.minimumHeight: 580

        contentItem: RowLayout {
            spacing: 12

            // LEVA STRANA: Vertikalna traka sa aktivnim aplikacijama + Minimize All na dnu
            ColumnLayout {
                Layout.fillHeight: true
                Layout.preferredWidth: 48
                spacing: 6

                PlasmaComponents.Label {
                    text: "Active"
                    font.pointSize: 8
                    font.bold: true
                    Layout.alignment: Qt.AlignHCenter
                }

                ScrollView {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    clip: true

                    contentWidth: availableWidth

                    ColumnLayout {
                        width: parent.width
                        spacing: 8

                        Repeater {
                            model: activeAppsModel

                            delegate: Item {
                                width: 44
                                height: 44
                                Layout.alignment: Qt.AlignHCenter

                                Rectangle {
                                    id: menuActiveRect
                                    anchors.fill: parent
                                    radius: 8
                                    color: menuActiveMouse.containsMouse ? Qt.rgba(1, 1, 1, 0.2) : Qt.rgba(1, 1, 1, 0.1)
                                    border.color: menuActiveMouse.containsMouse ? "#38BDF8" : "transparent"
                                    border.width: 1

                                    Image {
                                        anchors.fill: parent
                                        anchors.margins: 4
                                        source: model.icon || ""
                                        fillMode: Image.PreserveAspectFit
                                    }

                                    ToolTip.text: model.name
                                    ToolTip.visible: menuActiveMouse.containsMouse
                                }

                                MouseArea {
                                    id: menuActiveMouse
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    onClicked: {
                                        if (model.windowRef) {
                                            if (model.windowRef.visibility === Window.Minimized) {
                                                model.windowRef.showNormal();
                                            }
                                            model.windowRef.requestActivate();
                                            model.windowRef.raise();
                                        }
                                    }
                                }
                            }
                        }
                    }
                }

                // DUGME: Minimize All na dnu leve strane u meniju
                Item {
                    visible: activeAppsModel.count > 0
                    Layout.alignment: Qt.AlignHCenter
                    Layout.preferredWidth: 44
                    Layout.preferredHeight: 44
                    Layout.bottomMargin: 4

                    Rectangle {
                        anchors.fill: parent
                        radius: 8
                        color: menuMinAllMouse.containsMouse ? Qt.rgba(1, 1, 1, 0.2) : Qt.rgba(1, 1, 1, 0.05)
                        border.color: menuMinAllMouse.containsMouse ? "#38BDF8" : "transparent"
                        border.width: 1

                        PlasmaComponents.ToolButton {
                            anchors.centerIn: parent
                            width: 28
                            height: 28
                            icon.name: "window-minimize-panel"
                            ToolTip.text: "Minimize All Web Apps"
                            ToolTip.visible: menuMinAllMouse.containsMouse
                            onClicked: {
                                for (var i = 0; i < activeAppsModel.count; i++) {
                                    var win = activeAppsModel.get(i).windowRef;
                                    if (win) {
                                        win.showMinimized();
                                    }
                                }
                            }
                        }
                    }

                    MouseArea {
                        id: menuMinAllMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        acceptedButtons: Qt.NoButton
                    }
                }
            }

            // Vertikalna linija razdvajanja
            Rectangle {
                Layout.fillHeight: true
                Layout.preferredWidth: 1
                color: PlasmaTheme.viewColor
                opacity: 0.3
            }

            // DESNA STRANA: Glavni sadržaj (Lista sačuvanih aplikacija + Forma za dodavanje)
            ColumnLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                spacing: 12

                PlasmaComponents.Label {
                    text: "Saved Applications:"
                    font.bold: true
                }

                ScrollView {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    clip: true

                    contentWidth: availableWidth

                    Flow {
                        id: flowLayout
                        width: parent.width
                        spacing: 10

                        Repeater {
                            model: webAppsModel

                            delegate: Item {
                                id: tileItem
                                width: Math.max(120, Math.min(200, (model.name.length * 10) + 75))
                                height: 100

                                Rectangle {
                                    id: tileRect
                                    anchors.fill: parent

                                    radius: 12
                                    border.color: Qt.lighter(getTileColor(model.name), 1.4)
                                    border.width: mouseArea.containsMouse ? 2 : 1

                                    gradient: Gradient {
                                        orientation: Gradient.Vertical
                                        GradientStop {
                                            position: 0.0;
                                            color: mouseArea.containsMouse ? Qt.lighter(getTileColor(model.name), 1.3) : getTileColor(model.name)
                                        }
                                        GradientStop {
                                            position: 1.0;
                                            color: mouseArea.containsMouse ? getTileColor(model.name) : Qt.darker(getTileColor(model.name), 1.25)
                                        }
                                    }

                                    opacity: mouseArea.containsMouse ? 0.95 : 0.85
                                    Behavior on opacity { NumberAnimation { duration: 150 } }
                                }

                                RowLayout {
                                    anchors.fill: parent
                                    anchors.margins: 12
                                    spacing: 10

                                    Image {
                                        source: model.icon || ""
                                        sourceSize.width: 44
                                        sourceSize.height: 44
                                        Layout.preferredWidth: 44
                                        Layout.preferredHeight: 44
                                        Layout.alignment: Qt.AlignVCenter
                                        fillMode: Image.PreserveAspectFit
                                    }

                                    PlasmaComponents.Label {
                                        text: model.name
                                        Layout.fillWidth: true
                                        Layout.fillHeight: true
                                        verticalAlignment: Text.AlignVCenter
                                        elide: Text.ElideRight
                                        font.bold: true
                                        font.pointSize: 10
                                        color: "white"
                                    }
                                }

                                MouseArea {
                                    id: mouseArea
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    acceptedButtons: Qt.LeftButton
                                    propagateComposedEvents: true

                                    onClicked: (mouse) => {
                                        var inDeleteArea = (mouse.x > parent.width - 35) && (mouse.y > parent.height - 35);
                                        if (!inDeleteArea) {
                                            openInWindow(model.url, model.name, model.icon);
                                        }
                                    }
                                }

                                PlasmaComponents.Button {
                                    id: deleteBtn
                                    width: 26
                                    height: 26
                                    anchors.right: parent.right
                                    anchors.bottom: parent.bottom
                                    anchors.margins: 4
                                    z: 10

                                    icon.name: "edit-delete"

                                    onClicked: {
                                        removeWebApp(model.url);
                                    }
                                }
                            }
                        }
                    }
                }

                Item {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 16

                    Rectangle {
                        anchors.centerIn: parent
                        width: parent.width - 32
                        height: 1
                        color: PlasmaTheme.viewColor
                        opacity: 0.4
                    }
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 8

                    PlasmaComponents.Label {
                        text: "Add Web Apps:"
                        font.bold: true
                    }

                    PlasmaComponents.TextField {
                        id: urlInput
                        placeholderText: "Web address (e.g., https://gemini.google.com)"
                        Layout.fillWidth: true

                        onTextChanged: {
                            if (nameInput.text.trim() === "" && text.trim() !== "") {
                                nameInput.text = extractAppName(text.trim());
                            }
                        }
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 8

                        PlasmaComponents.TextField {
                            id: nameInput
                            placeholderText: "Application name"
                            Layout.fillWidth: true
                        }

                        PlasmaComponents.Button {
                            text: "Add & Save"
                            icon.name: "list-add"
                            onClicked: {
                                if (urlInput.text.trim() !== "") {
                                    var finalUrl = urlInput.text.trim();
                                    if (!finalUrl.startsWith("http://") && !finalUrl.startsWith("https://")) {
                                        finalUrl = "https://" + finalUrl;
                                    }

                                    var finalName = nameInput.text.trim() !== "" ? nameInput.text.trim() : extractAppName(finalUrl);

                                    addWebApp(finalName, finalUrl);

                                    urlInput.text = "";
                                    nameInput.text = "";
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    ListModel {
        id: webAppsModel
    }

    ListModel {
        id: activeAppsModel
    }

    WebEngineProfile {
        id: sharedWebProfile
        storageName: "WebLauncher_GlobalProfile"
        offTheRecord: false
    }

    Component {
        id: webWindowComponent
        Window {
            id: webWin
            width: 1024
            height: 768
            title: windowTitle

            property string targetUrl: ""
            property string windowTitle: "Web App"
            property string windowIcon: ""

            objectName: windowTitle
            flags: Qt.Window | Qt.CustomizeWindowHint | Qt.WindowTitleHint | Qt.WindowSystemMenuHint | Qt.WindowMinMaxButtonsHint | Qt.WindowCloseButtonHint

            onClosing: function(close) {
                for (var i = 0; i < activeAppsModel.count; i++) {
                    if (activeAppsModel.get(i).windowRef === webWin) {
                        activeAppsModel.remove(i);
                        break;
                    }
                }
                webEngineView.url = "about:blank";
                webWin.destroy();
            }

            WebEngineView {
                id: webEngineView
                anchors.fill: parent
                url: webWin.targetUrl

                profile: sharedWebProfile

                settings.accelerated2dCanvasEnabled: true
                settings.webGLEnabled: true
                settings.localStorageEnabled: true
                settings.javascriptEnabled: true

                // Automatsko hvatanje linkova koji se otvaraju u novom prozoru/tabu
                onNewWindowRequested: function(request) {
                    openInWindow(request.requestedUrl.toString(), windowTitle + " (Pop-up)", windowIcon);
                    request.openIn(null);
                }
            }

            Component.onCompleted: {
                webWin.show();
                activeAppsModel.append({
                    "name": windowTitle,
                    "icon": windowIcon,
                    "windowRef": webWin
                });
            }
        }
    }

    function getTileColor(name) {
        var hash = 0;
        for (var i = 0; i < name.length; i++) {
            hash = name.charCodeAt(i) + ((hash << 5) - hash);
        }

        var colors = [
            "#005FB8", "#107C41", "#D83B01", "#881798",
            "#00188F", "#E81123", "#00B7C3", "#498205", "#5C2D91"
        ];

        var index = Math.abs(hash) % colors.length;
        return colors[index];
    }

    function extractAppName(urlStr) {
        try {
            var clean = urlStr.replace(/^(https?:\/\/)?(www\.)?/i, "");
            var domain = clean.split('/')[0];
            var parts = domain.split('.');

            if (parts.length > 0) {
                var name = parts[0];
                return name.charAt(0).toUpperCase() + name.slice(1);
            }
        } catch (e) {
            console.error("Error parsing name:", e);
        }
        return "Web App";
    }

    function openInWindow(url, title, icon) {
        webWindowComponent.createObject(root, {
            targetUrl: url,
            windowTitle: title,
            windowIcon: icon
        });
    }

    function addWebApp(name, url) {
        var faviconUrl = "https://www.google.com/s2/favicons?domain=" + url + "&sz=128";

        webAppsModel.append({
            "name": name,
            "url": url,
            "icon": faviconUrl
        });
        sortAlphabetically();
        saveConfiguration();
    }

    function removeWebApp(url) {
        for (var i = 0; i < webAppsModel.count; i++) {
            if (webAppsModel.get(i).url === url) {
                webAppsModel.remove(i);
                break;
            }
        }
        saveConfiguration();
    }

    function sortAlphabetically() {
        var items = [];
        for (var i = 0; i < webAppsModel.count; i++) {
            items.push({
                "name": webAppsModel.get(i).name,
                "url": webAppsModel.get(i).url,
                "icon": webAppsModel.get(i).icon
            });
        }

        items.sort(function(a, b) {
            return a.name.localeCompare(b.name);
        });

        webAppsModel.clear();
        for (var j = 0; j < items.length; j++) {
            webAppsModel.append(items[j]);
        }
    }

    function saveConfiguration() {
        var listData = [];
        for (var i = 0; i < webAppsModel.count; i++) {
            listData.push({
                "name": webAppsModel.get(i).name,
                "url": webAppsModel.get(i).url,
                "icon": webAppsModel.get(i).icon
            });
        }
        plasmoid.configuration.webAppsJson = JSON.stringify(listData);
    }

    Component.onCompleted: {
        var storedData = plasmoid.configuration.webAppsJson;
        if (storedData && storedData.length > 0) {
            try {
                var parsed = JSON.parse(storedData);
                webAppsModel.clear();
                for (var i = 0; i < parsed.length; i++) {
                    var iconUrl = parsed[i].icon ? parsed[i].icon : ("https://www.google.com/s2/favicons?domain=" + parsed[i].url + "&sz=128");
                    webAppsModel.append({
                        "name": parsed[i].name,
                        "url": parsed[i].url,
                        "icon": iconUrl
                    });
                }
                sortAlphabetically();
            } catch (e) {
                console.error("Error parsing configuration:", e);
            }
        }
    }
}
