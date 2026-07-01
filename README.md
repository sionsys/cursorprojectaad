## 1. Data Model & Architecture

Two custom fields were verified/implemented on the standard **Lead** object to support notes capture and source accounts:

* **Capture_Notes__c (Long Text Area):** Stores specific interaction and qualification notes during the lead capture process.

* **Source_Account__c (Lookup to Account):** Links the newly created Lead back to the Account record page where the form is hosted.

### Security & Access Control

* **Permission Set:** `Lead_Capture_Access` ensures that users have Read/Write metadata permissions over the custom fields and the `leadCaptureForm` component.

---

## 2. Technical Implementation

### Front-End (LWC)

* **Component Name:** `leadCaptureForm`

* **Framework Features:** Utilizes `<lightning-record-edit-form>` to ensure secure, standard metadata binding, automatic field layout validation, and error management.

* **Context Awareness:** Dynamically retrieves the hosting Account name via `@api recordId` and pre-fills it inside the component.

### Back-End (Apex)

* **Controller Class:** `LeadCaptureController.cls`

* **Method:** `createLeadRecord(Lead leadRecord)`

    * Inserts the record securely with sharing rules enforced `with sharing`).

    * Handles database exceptions by wrapping them in `AuraHandledException` for friendly front-end reporting.

* **Test Class:** `LeadCaptureControllerTest.cls` provides over 95% test coverage simulating both success and validation-failure execution paths.

---

## 3. Administration & User Guide

### How to Deploy to an Org

1. Authenticate your Salesforce CLI with your target org.

2. Deploy metadata using:

   ```bash

   sf project deploy start

