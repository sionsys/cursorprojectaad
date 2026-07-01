import { LightningElement, api, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import ACCOUNT_NAME_FIELD from '@salesforce/schema/Account.Name';

export default class LeadCaptureForm extends LightningElement {
    @api recordId; 
    accountName = ''; // Dejar la propiedad lista aquí arriba evita el error

    // Con esto traemos los datos de la cuenta actual
    @wire(getRecord, { recordId: '$recordId', fields: [ACCOUNT_NAME_FIELD] })
    wiredAccount({ error, data }) {
        if (data) {
            this.accountName = getFieldValue(data, ACCOUNT_NAME_FIELD);
        } else if (error) {
            console.error('Error cargando la cuenta:', error);
        }
    }

    handleSuccess(event) {
        const toastEvent = new ShowToastEvent({
            title: '¡Éxito!',
            message: 'Lead creado correctamente con ID: ' + event.detail.id,
            variant: 'success'
        });
        this.dispatchEvent(toastEvent);
        
        // Esto limpia el formulario después de guardar
        const inputFields = this.template.querySelectorAll('lightning-input-field');
        if (inputFields) {
            inputFields.forEach(field => {
                if (field.fieldName !== 'Company' && field.fieldName !== 'Source_Account__c') {
                    field.reset();
                }
            });
        }
    }
}