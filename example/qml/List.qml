import QtQuick 2.6
import QtQuick.Layouts 1.3
import Industrial.Widgets 1.0
import Industrial.Controls 1.0

Pane {
    id: root

    property var itemSelected: null
    property real stepSizeTree: Theme.baseSize
    property var groupExpanded: []
    property bool dragEnabled: true

    padding: Theme.padding * 2

    function sumArray(array) {
        var sum = 0;
        array.forEach(function(value, index) {
            sum += value;
        });
        return sum;
    }

    RowLayout {
        anchors.fill: parent
        spacing: Theme.spacing

        Item { Layout.fillWidth: true }

        //Simple list
        ListWrapper {
            id: itemList

            Layout.fillWidth: true
            Layout.fillHeight: true

            model: itemModel

            delegate: Draggable {
                width: parent.width
                draggedItemParent: itemList

                onMoveItemRequested: itemModel.move(from, to, 1)

                Loader {
                    sourceComponent: itemComponent
                    property var _model: model
                    property string _text: model.text
                    property real _leftMargin: Theme.padding
                    width: parent.width
                }
            }
        }

        //Expanded list
        ListWrapper {
            id: groupList

            Layout.fillWidth: true
            Layout.fillHeight: true

            model: groupModel

            delegate: Draggable {
                width: parent.width
                color: "transparent"
                draggedItemParent: groupList
                dragEnabled: root.dragEnabled

                onMoveItemRequested: groupModel.move(from, to, 1);
                onDoubleClicked: {
                    root.itemSelected = groupList;
                    loader._expanded = !loader._expanded;
                }

                Loader {
                    id: loader
                    sourceComponent: groupComponent
                    property var _model: model
                    property string _text: model.text
                    property bool _expanded: false
                    width: parent.width
                }
            }
        }
    }

    ListModel{
        id: groupModel
        ListElement{ text: "Alpha" }
        ListElement{ text: "Beta" }
        ListElement{ text: "Gamma" }
        ListElement{ text: "Delta" }
        ListElement{ text: "Epsilon" }
        ListElement{ text: "Zeta" }
        ListElement{ text: "Eta" }
    }

    ListModel{
        id: itemModel
        ListElement{ text: "Apple" }
        ListElement{ text: "Banana" }
        ListElement{ text: "Cherry" }
        ListElement{ text: "Grapefruit" }
        ListElement{ text: "Lemon" }
        ListElement{ text: "Mango" }
        ListElement{ text: "Raspberry" }
    }

    Component {
        id: groupComponent

        Item {
            id: control

            property var groupContent: _model
            property bool expanded: _expanded
            height: !expanded ? Theme.baseSize : Theme.baseSize + itemList.implicitHeight

            ColumnLayout {
                id: column
                anchors.fill: parent
                spacing: 0

                ListButton {
                    id: listButton
                    Layout.fillWidth: true
                    rightPadding: visibilityButton.width + Theme.padding * 2
                    labelText: _text ? _text : ""
                    amount: itemList ? itemList.count : 0
                    amountVisible: true
                    expanded: control.expanded
                    selected: root.itemSelected === listButton

                    onClicked: root.itemSelected = listButton

                    Button {
                        id: visibilityButton
                        type: root.itemSelected === listButton ? Theme.LinkPrimary : Theme.LinkSecondary
                        checkedTextColor: root.itemSelected === listButton ?
                                              Theme.colors.text : Theme.colors.highlight
                        iconSource: checked ? "qrc:/icons/password_hide.svg" : "qrc:/icons/password_show.svg"
                        checkable: true
                        anchors.right: parent.right
                        anchors.rightMargin: Theme.padding
                    }
                }

                //Simple list
                ListWrapper {
                    id: itemList

                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    visible: expanded
                    color: listButton.selected ? Theme.colors.hover : "transparent"

                    onVisibleChanged: {
                        //Записываем все открытые группы в массив
                        root.groupExpanded[_model.index] = control.expanded;
                        //Если одна группа открытая, то dragEnabled запрещен на этом уровне
                        root.dragEnabled = !sumArray(root.groupExpanded);
                    }

                    model: itemModel

                    delegate: Draggable {
                        width: parent.width
                        draggedItemParent: itemList

                        onMoveItemRequested: itemModel.move(from, to, 1)

                        Loader {
                            sourceComponent: itemComponent
                            property var _model: model
                            property string _text: model.text
                            property real _leftMargin: root.stepSizeTree
                            width: parent.width
                        }
                    }
                }
            }
        }
    }

    Component {
        id: itemComponent

        Item {
            id: control
            property var itemContent: _model
            height: Theme.baseSize

            MouseArea {
                id: mouseArea
                anchors.fill: parent
                propagateComposedEvents: true

                onPressed: {
                    root.itemSelected = itemContent
                    mouse.accepted = false;
                }
            }

            Rectangle {
                id: backgraund
                anchors.fill: parent
                color: root.itemSelected === itemContent ? Theme.colors.selection : "transparent"
                radius: Theme.rounding

                RowLayout {
                    id: row
                    spacing: Theme.padding
                    anchors.fill: parent
                    anchors.leftMargin: _leftMargin
                    anchors.rightMargin: Theme.padding

                    ColoredIcon {
                        source: "qrc:/icons/image.svg"
                        color: root.itemSelected === itemContent ? Theme.colors.controlText : Theme.colors.description
                        implicitHeight: Theme.iconSize
                        implicitWidth: Theme.iconSize
                    }

                    Label {
                        type: Theme.Text
                        text: _text
                        Layout.fillWidth: true
                    }

                    Button {
                        id: visibilityButton2
                        type: root.itemSelected === itemContent ? Theme.LinkPrimary : Theme.LinkSecondary
                        checkedTextColor: root.itemSelected === itemContent ?
                                              Theme.colors.text : Theme.colors.highlight
                        iconSource: checked ? "qrc:/icons/password_hide.svg" : "qrc:/icons/password_show.svg"
                        checkable: true
                    }
                }
            }
        }
    }
}
