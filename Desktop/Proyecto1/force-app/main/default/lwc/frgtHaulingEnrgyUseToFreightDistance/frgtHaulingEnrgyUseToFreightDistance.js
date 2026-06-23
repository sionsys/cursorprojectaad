import { LightningElement, track, api } from 'lwc';
import { showErrorToast } from "c/toastService";
import getFreightData from '@salesforce/apex/FrgtHaulingEnrgyUseToFreightDistCtrl.getFreightDistanceData';

export default class FrgtHaulingEnrgyUseToFreightDistance extends LightningElement {
    @track isLoading = true;
    @track externalId;
    @track linkToFreightDistance;
    @track freightDistanceName;
    @track distanceValue;
    @track createdDate;
    @api recordId;

    connectedCallback() {
        this.fetchData();
    }

    async fetchData() {
        try {
            const result = await getFreightData({ recordId: this.recordId });
            this.externalId = result.externalId;
            this.linkToFreightDistance = result.linkToFreightDistance;
            this.freightDistanceName = result.freightDistanceName;
            this.distanceValue = result.distanceValue;
            this.createdDate = result.createdDate;
            this.isLoading = false;
        } catch (error) {
            console.error('Error fetching data', error);
            this.isLoading = false;
            showErrorToast(this, error);
        }
    }
}