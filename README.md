# Lead Capture Project — Technical & Architectural Documentation

This repository contains the complete production-ready implementation of the custom Lead Capture solution inside Salesforce, using Lightning Web Components (LWC), Apex controllers, and robust security patterns.

---

## 1. Solution Architecture & Data Flow Diagram

The following diagram illustrates the end-to-end data flow, component interactions, and the boundaries between the User Interface, the Controller layer, and the Salesforce Database.

```mermaid

graph TD

    A[Account Record Page] -->|Hosts| B(LWC: leadCaptureForm)

    B -->|User Inputs Data| C{lightning-record-edit-form}

    C -->|Automatic Metadata Validation| D[JS Controller]

    D -->|Imperative Apex Call: createLeadRecord| E[Apex Class: LeadCaptureController]

    E -->|Security Enforcement: with sharing| F{Database DML Insert}

    F -->|Success Response| G[Show Toast Notification & Reset Form]

    F -->|DatabaseException| H[Wrap as AuraHandledException]

    H -->|Error Response| I[Show Error Toast to User]

    F -->|Commit| J[(Salesforce Database: Lead Object)]

