/**
 * @description Two-level tree filter value selection component
 * @author Karen Reardon, Traction on Demand
 * @date 2019-09-12
 */

import { LightningElement, track, api } from 'lwc';

export default class TracFilterList extends LightningElement {

    @track itemList;
    @api label =''
    @api name = '';
    @api selectedCount = 0;
    @api selectedItems;
    @api items;
    /** The following is an example of the expected format of the items:
    [
         {
            Id: 'Id1',
            Name : 'Name1',
            Items : [
                    {
                        Id: 'Id2',
                        Name : 'Name2'
                    },
                    {
                        Id: 'Id3',
                       Name : 'Name3'
                     },
            ]
        },
        {
            Id: 'Id4',
            Name : 'Name4'
        },
        {
            Id: 'Id5',
            Name : 'Name5'
        },
     ];
     */

    /**
     * @description utility to check for a defined and non-empty variable
     */
    isEmpty(someVariable) {
        return ((typeof someVariable === 'undefined') || (!someVariable));
    }

    /**
     * @description formats the given items into the format required by the component to implement the tree and selection interations
     */
    formatItems() {
        if (!this.isEmpty(this.itemList) || this.isEmpty(this.items)) {return;}
        let returnItems = [];
        let i = 0;      
        this.items.forEach(item => {   
            let isSelected = (!this.isEmpty(this.selectedItems) && this.selectedItems.includes(item.Id));
            let listItem = {label: item.Name, value: item.Id, name: i, expanded: false, selected: isSelected, visible: true, parent: false, parentname: 10000, child:false, grandchild:false, grandparentname: 10000};
            returnItems[i] = listItem;        
            if (!(this.isEmpty(item.Items))) {
                returnItems[i].parent = true;
                returnItems[i].expanded = false;
                let parenti = i;    
                item.Items.forEach(child => {           
                    i++
                    isSelected = (!this.isEmpty(this.selectedItems) && this.selectedItems.includes(child.Id));
                    let childItem = {label: child.Name, value: child.Id, name: i, expanded: false, selected: isSelected, visible: returnItems[parenti].expanded, parentname: parenti, grandparentname:10000};
                    childItem.parent = ( child.Items != null && child.Items.length > 0 );
                    childItem.child = true; //!childItem.parent;
                    childItem.grandchild = false;
                    returnItems[i] = childItem;

                    let middlechildi = i;        
                    child.Items.forEach(grandchild => {             
                        i++
                        isSelected = (!this.isEmpty(this.selectedItems) && this.selectedItems.includes(grandchild.Id));
                        let grandchildItem = {label: grandchild.Name, value: grandchild.Id, name: i, expanded: false, selected: isSelected, visible: returnItems[middlechildi].expanded, parent: false, parentname: middlechildi,child:false, grandparentname:parenti};
                        grandchildItem.grandchild = true;
                        returnItems[i] = grandchildItem;
                    })
                })
            }
            i++;
        });
        this.itemList = returnItems; 
    }

    /**
     * @description returns the list of formatted items to the HTML
     */
    get getitems() {
        this.formatItems();
        return this.itemList;
    }

    /**
     * @description retrieves the tracFilterItem controls in order to retrieve the current selections
     */
    getFilterItemControls () {
        let controlList = this.template.querySelectorAll('c-trac-filter-item');
        let returnList = [];

        if (controlList) {
            controlList.forEach(control => {returnList[control.name] = control;});
        }
        return returnList;
    }

    /**
     * @description handles the [un]select user action. If the item is a parent, it [un]selects the children
     */
    handleSelect(event) {
        let itemname = event.detail.name;
        let isSelected = event.detail.selected;
        this.itemList[itemname].selected = isSelected;
        if (this.itemList[itemname].parent) {
            this.selectChildren(itemname, isSelected);
        }
    }

    /**
     * @description Sets the [un]selected status of children items based on the selection state of the parent
     */
    selectChildren(parentname, isSelected) {
        let controls = this.getFilterItemControls();

        for (let i=parentname+1; i < this.itemList.length; i++) {
            if (this.itemList[i].parentname === parentname) {
                this.itemList[i].selected = isSelected;
                if (controls[i]) {
                    (controls[i]).refreshSelected(isSelected);
                }
            }
            else {
                break;
            }
        }
    }

    /**
     * @description handles the expand/contract user action on a parent item
     */
    handleToggle(event) {
        let parentname = event.target.value;
        let isExpanded = !(this.itemList[parentname].expanded);
        this.itemList[parentname].expanded = isExpanded;
        for (let i=parentname+1; i < this.itemList.length; i++) {              
            if ( this.itemList[i].parentname === parentname || ( !isExpanded && this.itemList[i].grandparentname == parentname ) ) {               
                this.itemList[i].visible = isExpanded;
                if ( !isExpanded ) { this.itemList[i].expanded = isExpanded; }
            }
            // else {
            //     break;
            // }
        }
    }

    /**
     * @description method for the parent component to retrieve the list of selected filter items
     * This is used instead of an event with the intent that the selections will be queried when an Apply Filter button is clicked.
     */
    @api
    getSelectedItems() {
        let selectedItems = [];
        if(this.itemList != null && this.itemList.length > 0) {
            this.itemList.forEach(item => {
                if (item.selected) {
                    selectedItems.push(item.value);
                }
            });
        }
        return selectedItems;
    }

    /**
     * @description method to force the update of the list of selected filter items
     * This is used instead of relying on the render event intentionally.
     */
    @api
    setSelectedItems(selectedItems, isSelected) {
        this.selectedItems = selectedItems;
        let controls = this.getFilterItemControls();

        for (let i = 0; i < this.itemList.length; i++) {
            this.itemList[i].selected = isSelected;
            if (controls[i]) {
                (controls[i]).refreshSelected(isSelected);
            }
        }
    }
}