import { LightningElement, api } from 'lwc';
import getEmailRecipients from '@salesforce/apex/QuoteDocEmailRecipientsController.getEmailRecipients'

const columns = [
    { label: 'Name', fieldName: 'contactName' },
    { label: 'Email', fieldName: 'emailAddress' }
];

export default class QuoteDocumentSelectEmailRecipients extends LightningElement {
    // FLOW INPUTS
    @api recordId;
    @api accountId;
    
    // FLOW OUTPUTS
    @api userSelectedEmailAddresses = ''; //string of email addresses separated by semicolon (;)
    
    // OTHER PROPERTIES
    _recipients;
    _preselectedRows = [];
    _columns = columns;

    _isDataLoaded = false;

    get _isNothingSelected() {
        if (!this._recipients || this._recipients.length === 0) return true;
    }

    connectedCallback() {
        getEmailRecipients({accountId: this.accountId})
        .then(emailRecipients => {
            this._recipients = emailRecipients;
            let preselectedRows = [];
            for (let er of emailRecipients) {
                if (er.isDefaultNotificationRecipient === true) {
                    preselectedRows.push(er.contactId);
                }
            }    
            this._preselectedRows = preselectedRows;
            this._isDataLoaded = true;
        })
        .catch(err => {
            console.error(err);
        })
    }

    renderedCallback() {
        this.assignOutputForFlow();
    }

    assignOutputForFlow() {
        let datatableElement = this.refs.recipientTable;
        let selectedRows;
        if (datatableElement) {
            selectedRows = datatableElement.getSelectedRows();
            let output = JSON.stringify(selectedRows);
            this.userSelectedEmailAddresses = output;
        }
    }
}