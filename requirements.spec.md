# Functional Specification: Lead Capture Form Component

## Overview
This specification outlines the requirements and implementation details for the custom Lightning Web Component (LWC) designed to capture Lead records directly from the Account record page.

## Functional Requirements
* **Placement**: The component is embedded directly onto the Account Lightning Record Page (FlexiPage).
* **Data Mapping & Fields**:
  * `First Name` (FirstName) — Text, optional.
  * `Last Name` (LastName) — Text, required.
  * `Email` (Email) — Email format, required with automatic platform validation.
  * `Phone` (Phone) — Phone, optional.
  * `Company` (Company) — Text, required. Auto-populated using the parent Account's name via wire service.
  * `Lead Source` (LeadSource) — Picklist, required. Restricted to standard values: Web, Phone Inquiry, Partner Referral, Other.
  * `Capture Notes` (Capture_Notes__c) — Long Text Area, optional, maximum 500 characters.
  * `Source Account` (Source_Account__c) — Hidden Lookup field automatically mapping the current Account ID to relate the records.

## Technical Architecture
* **Framework**: Lightning Web Components (LWC).
* **Data Service**: Implemented using `lightning-record-edit-form` to handle standard automatic layouts, validations, and server-side operations natively.
* **Context**: Uses `@api recordId` to dynamically retrieve current account context and bind fields.