import { LightningElement, wire, track } from 'lwc';
import { showErrorToast, showSuccessToast } from "c/toastService";

import isFreightHaulingEnergyUseProcessingRunning from '@salesforce/apex/FrgtHaulingEnrgyUseDistanceProcessing.isFreightHaulingEnergyUseProcessingRunning';
import triggerDistanceCalculation from '@salesforce/apex/FrgtHaulingEnrgyUseDistanceProcessing.triggerDistanceCalculation';
import triggerClearFailureFlag from '@salesforce/apex/FrgtHaulingEnrgyUseDistanceProcessing.triggerClearFailureFlag';
import getFreighHaulingEnergyUseStatistics from '@salesforce/apex/FrgtHaulingEnrgyUseDistanceProcessing.getFrgtHaulingEnrgyUseStats';
import getBatchJobProgress from '@salesforce/apex/FrgtHaulingEnrgyUseDistanceProcessing.getBatchJobProgress';

export default class FrgtHaulingEnrgyUseDistanceProcessing extends LightningElement {

    // process drivers
    @track isLoading = true;
    @track isBatchJobRunning = true;

    // some statistics
    @track countOfRecordsWithZeroDistance = null;
    @track countOfRecordsWithIssuesAndZeroDistance = null;

    @track progress = 0;

    batchJobTriggeredName = '';

    connectedCallback() {
        this.checkIfDistanceProcessingIsRunning();
    }

    get statisticsLoading() {
        return this.countOfRecordsWithZeroDistance == null || this.countOfRecordsWithIssuesAndZeroDistance == null;
    }

    async checkIfDistanceProcessingIsRunning() {
        try {
            const data = await isFreightHaulingEnergyUseProcessingRunning();
            this.isLoading = false;
    
            if (data) {
                this.isBatchJobRunning = true;
                await this.fetchBatchJobProgress();
            } else {
                this.isBatchJobRunning = false;
                await this.fetchFreightHaulingEnergyUseStatistics();
            }
        } catch (error) {
            this.isLoading = false;
            showErrorToast(this, error);
        }
    }

    async handleDistanceCalculation() {
        try {
            this.isBatchJobRunning = true;
            this.batchJobTriggeredName = 'FrgtHaulingEnrgyUseDistanceCalcBatch';
            await triggerDistanceCalculation();
            await this.fetchBatchJobProgress();
        } catch (error) {
            this.isBatchJobRunning = false;
            showErrorToast(this, error);
        }
    }

    async fetchFreightHaulingEnergyUseStatistics() {
        try {
            const data = await getFreighHaulingEnergyUseStatistics();
            if (data) {
                this.countOfRecordsWithZeroDistance = data.NumberOfRecordsWithZeroDistance;
                this.countOfRecordsWithIssuesAndZeroDistance = data.NumberOfRecordsWithIssuesAndZeroDistance;
            }
        } catch (error) {
            this.isLoading = false;
            showErrorToast(this, error);
        }
    }

    async fetchBatchJobProgress() {
        try {
            const data = await getBatchJobProgress( { batchJobName: this.batchJobTriggeredName });
    
            if (data !== null && data !== undefined) {
                if (data >= 0 && data < 100) {
                    this.progress = data;
                    // Poll again after 10 seconds
                    setTimeout(() => {
                        this.fetchBatchJobProgress();
                    }, 10000);
                } else if (data === -1) {
                    // Batch job completed
                    this.progress = 100;
                    this.isBatchJobRunning = false;
                    showSuccessToast(this, 'Batch job completed successfully.');
                } else {
                    // If data is outside expected range
                    showErrorToast(
                        this,
                        'Error fetching batch job progress. Could not access information about the batch job processing.'
                    );
                }
            }
    
            // After we get the batch progress, update statistics
            await this.fetchFreightHaulingEnergyUseStatistics();
        } catch (error) {
            this.progress = 0;
            showErrorToast(this, error);
            // Optionally re-check or reset state, e.g.:
            isFreightHaulingEnergyUseProcessingRunning();
        }
    }

    async handleClearFailureFlag() {
        try {
            this.isBatchJobRunning = true;
            this.batchJobTriggeredName = 'FrgtHaulingEnrgyUseClearFailureFlagBatch';
            await triggerClearFailureFlag();
            await this.fetchBatchJobProgress();
        } catch (error) {
            this.isBatchJobRunning = false;
            showErrorToast(this, error);
        }
    }

}