import QtQuick 2.6
import QtQuick.Templates 2.2 as T

import "../Shaders" as Shaders

T.Button { // TODO: clickable
    id: control

    property bool round: false // TODO: remove round
    property bool pressedImpl: false
    property string tipText

    property alias iconSource: content.iconSource
    property alias iconColor: content.iconColor
    property alias textColor: content.textColor
    property alias hasMenu: menuIndicator.visible
    property alias menuOpened: menuIndicator.opened
    property alias contentWidth: content.width
    property alias backgroundColor: backgroundItem.color

    font.pixelSize: controlSize.fontSize
    implicitWidth: Math.max(controlSize.baseSize, content.implicitWidth + control.padding * 2)
    implicitHeight: controlSize.baseSize
    hoverEnabled: true
    padding: controlSize.padding

    background: Rectangle {
        id: backgroundItem
        radius: round ? Math.min(width, height) / 2 : controlSize.rounding
        color: {
            if ((control.round && !control.flat && control.activeFocus) ||
                    control.pressed || control.pressedImpl)
                return customPalette.highlightColor;
            if (control.highlighted || control.checked)
                return customPalette.selectionColor;
            return control.flat ? "transparent" : customPalette.buttonColor;
        }

        MenuIndicator {
            id: menuIndicator
            x: parent.width - width
            y: parent.height - height
            visible: false
            focused: control.activeFocus
        }

        Rectangle {
            anchors.bottom: parent.bottom
            width: parent.width
            height: backgroundItem.radius
            color: control.activeFocus && !control.round ? customPalette.highlightColor :
                                                           backgroundItem.color
        }

        Rectangle {
            anchors.fill: parent
            color: customPalette.textColor
            radius: parent.radius
            opacity: 0.1
            visible: control.hovered
        }

        Shaders.Hatch {
            anchors.fill: parent
            color: customPalette.sunkenColor
            visible: !control.enabled && !control.flat
        }

        Shadow {
            visible: !control.flat
            source: parent
        }
    }

    contentItem: ContentItem {
        id: content
        anchors.fill: parent
        anchors.margins: control.padding
        text: control.text
        font: control.font
        textColor: (control.round && control.activeFocus) ||
                   control.pressed || control.pressedImpl ?
                       customPalette.selectedTextColor : customPalette.textColor
    }

    ToolTip {
        visible: (control.hovered || control.down) && tipText
        text: tipText
        delay: 1000
    }
}
