import { LightningElement, track } from 'lwc';
import { isEmpty, isNotEmpty, cloneObject, parseError, waitAsync, wait } from 'c/utilities';

// Apex;
import markAccountAsOptInApex from '@salesforce/apex/DigExOptInController.markAccountAsOptIn';

// Constants;
const ACCOUNT_ID_PARAM = 'accountId';
const SIGNATURE_PARAM = 'sig';

export default class DigExEmailOptInForm extends LightningElement {
    @track loading = false;
    @track isSuccessfulUpdate = false;
    @track error = null;

    get hasError() {
        return isNotEmpty(this.error);
    }

    get isProcessing() {
        return !this.hasError && this.loading;
    }

    get hasProcessed() {
        return !this.isProcessing && this.isSuccessfulUpdate === true;
    }

    get errorMessage() {
        return parseError(this.error)['message'];
    }

    get message() {
        if (this.hasError) {
            return this.errorMessage;
        } else if (this.hasProcessed) {
            return 'Thanks for confirming opt-in!';
        } else {
            return 'Processing opt-in..';
        }
    }

    get accountId() {
        return this.urlParameters.get(ACCOUNT_ID_PARAM);
    }

    get signature() {
        return this.urlParameters.get(SIGNATURE_PARAM);
    }

    get urlParameters() {
        return new URLSearchParams(document.location.search);
    }

    async connectedCallback() {
        this.loading = true;
        try {
            debugger;
            console.log('Account ID', this.accountId);
            console.log('Signature', this.signature);
            if (isEmpty(this.accountId)) {
                this.error = { message: 'Account not found!' };
                return;
            }
            if (isEmpty(this.signature)) {
                this.error = { message: 'Signature missing!' };
                return;
            }
            await waitAsync(2000);
            debugger;
            const saveResult = await markAccountAsOptInApex({ accountId: this.accountId, signature: this.signature });
            console.log('SaveResult', saveResult);
            debugger;
            const { success, errorMessage } = JSON.parse(saveResult);
            debugger;
            this.isSuccessfulUpdate = success === 'true';
            if (this.isSuccessfulUpdate) {
                wait(() => {
                    // this.handleClosePage();
                }, 10000);
            } else {
                this.error = { message: errorMessage };
            }
        } catch (error) {
            debugger;
            this.error = cloneObject(error);
        } finally {
            debugger;
            this.loading = false;
        }
    }

    handleClosePage() {
        // TODO - open the link properly!
        console.log('Closing page...');
        window.close();
    }
}
