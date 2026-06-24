# AGENTS.md - Contexto del Proyecto Salesforce (agenticProyecto1)

## 1. Descripción del Proyecto
Este es un proyecto de **Salesforce DX (SFDX)** (API 63.0). No es una aplicación web tradicional. La lógica de negocio corre en el backend con **Apex**, la interfaz de usuario (UI) está construida con **Lightning Web Components (LWC)** y el modelo de datos reside en objetos estándar y personalizados de Salesforce.
El repositorio actual es un *retrieve parcial* de la organización, enfocado en lógica y UI.

## 2. Arquitectura Base y Patrones (¡CRÍTICO!)
El código sigue estrictamente **Apex Enterprise Patterns (fflib)**. **NO escribir SOQL ni DML dispersos.** Toda la lógica debe organizarse en las siguientes capas:
- **Application:** Registro de factories (`NetZeroApplication`, `QD_Application`).
- **Selector:** Consultas SOQL centralizadas (ej. `FreightDistanceSelector`).
- **Domain:** Lógica de triggers (`fflib_SObjectDomain`). Los triggers delegan aquí.
- **Service:** Reglas de negocio reutilizables (ej. `QuoteDocumentService`).
- **Asíncrono:** Procesos pesados mediante `Batch` o `Queueable`.

## 3. Módulos Funcionales Principales

### A. Net Zero (Cálculo de Distancias)
- **Objetivo:** Calcula distancias para registros de Net Zero Cloud (`FrgtHaulingEnrgyUse`).
- **Componentes clave:** `FrgtHaulingEnrgyUseDistanceCalcBatch` (procesamiento asíncrono e integración con APIs externas como Google Maps/Searates) y `Freight_Distance__c` (objeto caché de distancias).
- **UI:** LWCs `frgtHaulingEnrgyUseDistanceProcessing` y `frgtHaulingEnrgyUseToFreightDistance`.

### B. Quote Documents (Cotizaciones CPQ + Conga)
- **Objetivo:** Generación de PDFs de cotizaciones integrando Salesforce CPQ (`SBQQ__Quote__c`) y Conga Composer.
- **Componentes clave:** Métodos `@InvocableMethod` expuestos para Flows, procesamiento vía `QuoteDocumentQueueable` -> `QuoteDocumentFinalizer`.
- **UI:** LWC `quoteDocumentSelectEmailRecipients`.

### C. Agent Force POC (Prueba de Concepto de IA)
- **Objetivo:** Clases con métodos `@InvocableMethod` diseñados específicamente para alimentar prompts de agentes conversacionales de Salesforce Agent Force.
- **Componentes clave:** Selectores de cuentas y oportunidades (`AgentForcePoc_AccountSelector`, `AgentForcePoc_OpportunitySelector`).

### D. DLRS y Comunidades
- Triggers auto-generados de rollups declarativos (`dlrs.RollupService`).
- Controladores estándar de scaffolding para portales de comunidad (Login/Registro).

## 4. Reglas de Naming y Estructura
Al crear nuevas clases o componentes, respeta los prefijos existentes:
- `FrgtHaulingEnrgyUse*` -> Módulo Net Zero
- `QuoteDocument*` o `QD_*` -> Módulo de Cotizaciones
- `AgentForcePoc_*` -> Módulo de IA Agent Force
- `*Test.cls` -> Cada clase de Apex DEBE llevar su clase de prueba correspondiente.
