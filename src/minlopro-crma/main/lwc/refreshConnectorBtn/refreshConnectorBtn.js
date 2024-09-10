import { LightningElement, track, wire } from 'lwc';
import { getDataConnectors, ingestDataConnector } from 'lightning/analyticsWaveApi';
import LightningConfirm from 'lightning/confirm';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class RefreshConnectorBtn extends LightningElement {
    @track loading = false;

    get doDisableBtn() {
        return this.loading || !Boolean(this.sfdcLocalConnectorId);
    }

    get sfdcLocalConnectorId() {
        return this.wiredConnectors?.data?.dataConnectors[0].id;
    }

    get helpText() {
        return "By clicking on this button you will trigger the whole data sync for the SFDC_LOCAL connection. Please, click on this button once you've completed updates of the records in the table(s) below.";
    }

    get connectorError() {
        return JSON.stringify(this.wiredConnectors?.error);
    }

    @wire(getDataConnectors, { connectorType: ['SfdcLocal'] })
    wiredConnectors = {};

    async handleClick(event) {
        console.log(`Refreshing data connector with ID = ${this.sfdcLocalConnectorId} ...`);
        try {
            const hasConfirmed = await LightningConfirm.open({
                label: 'Run Data Sync',
                message: this.helpText,
                variant: 'header',
                theme: 'warning'
            });
            if (!hasConfirmed) {
                return;
            }
            this.loading = true;
            const result = await ingestDataConnector({ connectorIdOrApiName: this.sfdcLocalConnectorId });
            console.log('Connector Ingestion Response', JSON.stringify(result));
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Success',
                    message: result.message,
                    variant: 'warning'
                })
            );
        } catch (error) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error ingesting data connector',
                    message: error?.message || error?.body?.message || 'Unknown Error Occurred',
                    variant: 'error'
                })
            );
        } finally {
            this.loading = false;
        }
    }
}
