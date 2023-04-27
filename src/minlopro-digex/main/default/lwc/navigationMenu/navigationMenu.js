import { LightningElement, api, track, wire } from 'lwc';
import { CurrentPageReference, NavigationMixin } from 'lightning/navigation';
import { isNotEmpty, parseError } from 'c/utilities';
import toastify from 'c/toastify';

// Apex;
import getNavigationMenuItemsApex from '@salesforce/apex/NavigationMenuItemsController.getNavigationMenuItems';

// Constants;
import $IsGuestUser from '@salesforce/user/isGuest';
import $BasePath from '@salesforce/community/basePath';
import basePath from '@salesforce/community/basePath';

export default class NavigationMenu extends NavigationMixin(LightningElement) {
    @api menuApiName;

    @track siteState = 'Draft';
    @track navigationItems = undefined;

    get hasLoaded() {
        return this.navigationItems !== undefined;
    }

    get visibleNavigationItems() {
        if (!this.hasLoaded) {
            return [];
        }
        return this.navigationItems
            .filter(({ accessRestriction = '' }) => {
                if (accessRestriction === 'None') {
                    return true;
                } else if (accessRestriction === 'LoginRequired' && !$IsGuestUser) {
                    return true;
                }
                return false;
            })
            .map((_) => {
                let selected = false;
                if (_.target === '/' && window.location.pathname === $BasePath) {
                    selected = true;
                } else {
                    selected = window.location.pathname.includes(_.target);
                }
                return { ..._, selected };
            });
    }

    @wire(CurrentPageReference)
    wireCurrentPageReference(currentPageReference) {
        const app =
            currentPageReference && currentPageReference.state && currentPageReference.state.app;
        if (app === 'commeditor') {
            this.siteState = 'Draft';
        } else {
            this.siteState = 'Live';
        }
    }

    @wire(getNavigationMenuItemsApex, {
        menuApiName: '$menuApiName',
        siteState: '$siteState'
    })
    wireMenuItems({ error, data }) {
        if (isNotEmpty(error)) {
            const { message } = parseError(error);
            toastify.error({ message });
            return;
        }
        this.navigationItems = (data || []).map((_) => ({
            id: `${_.Target}:${_.Type}`,
            label: _.Label,
            target: _.Target,
            type: _.Type,
            accessRestriction: _.AccessRestriction,
            defaultListViewId: _.DefaultListViewId,
            status: _.Status,
            parentId: _.ParentId,
            targetPrefs: _.TargetPrefs
        }));
    }

    handleNavigate(event) {
        event.preventDefault();
        const navigationItemId = event.target.dataset.id;
        const navigationItem = this.navigationItems.find(({ id }) => id === navigationItemId);
        const { type, target, defaultListViewId } = navigationItem;
        // Get the correct PageReference object for the menu item type
        if (type === 'SalesforceObject') {
            // aka "Salesforce Object" menu item
            this.pageReference = {
                type: 'standard__objectPage',
                attributes: {
                    objectApiName: target
                },
                state: {
                    filterName: defaultListViewId
                }
            };
        } else if (type === 'InternalLink') {
            // aka "Site Page" menu item
            // WARNING: Normally you shouldn't use 'standard__webPage' for internal relative targets, but
            // we don't have a way of identifying the Page Reference type of an InternalLink URL
            this.pageReference = {
                type: 'standard__webPage',
                attributes: {
                    url: basePath + target
                }
            };
        } else if (type === 'ExternalLink') {
            // aka "External URL" menu item
            this.pageReference = {
                type: 'standard__webPage',
                attributes: {
                    url: target
                }
            };
        }
        if (this.pageReference) {
            this[NavigationMixin.Navigate](this.pageReference);
        } else {
            toastify.error({
                message: `Navigation menu type "${type}" is not implemented for item ${JSON.stringify(
                    navigationItem
                )}`
            });
        }
    }
}