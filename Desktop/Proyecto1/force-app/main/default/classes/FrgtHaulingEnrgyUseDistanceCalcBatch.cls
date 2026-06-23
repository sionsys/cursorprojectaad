public class FrgtHaulingEnrgyUseDistanceCalcBatch implements Database.Batchable<SObject>, Database.AllowsCallouts {

    public Database.QueryLocator start(Database.BatchableContext context) {
        // Check if the user has the required custom permission, this should help us to avoid the scenario 
        // when a not authorized user starts the batch job and consumes the API calls from costly services
        if (!FeatureManagement.checkPermission('Can_View_Freight_Hauling_Energy_Use_Distance_Processing_LWC')
                && Test.isRunningTest() == false) {
            throw new AsyncException('You do not have permission to start this batch job.');
        }

        return Database.getQueryLocator(
                [SELECT Id, Load_Address__c, Unload_Address__c, FreightHaulingMode
                FROM FrgtHaulingEnrgyUse 
                WHERE Distance = 0 
                    AND Failed_Distance_Calculation__c != true
                ORDER BY CarbonFootprintReportDate ASC]
            );
    }

    public void execute(Database.BatchableContext context, List<FrgtHaulingEnrgyUse> energyUseRecordsList) {
        this.processRecords(energyUseRecordsList);
    }

    @TestVisible
    private void processRecords(List<FrgtHaulingEnrgyUse> energyUseRecordsList) {
        List<FrgtHaulingEnrgyUse> recordsToUpdate = new List<FrgtHaulingEnrgyUse>();
        Map<String,Freight_Distance__c> freightDistanceToInsert = new Map<String,Freight_Distance__c>();

        for (FrgtHaulingEnrgyUse frgtHaulingEnrgyUseRecord : energyUseRecordsList) {       
            AddressInfo loadAddressInfo = new AddressInfo(frgtHaulingEnrgyUseRecord.Load_Address__c);
            AddressInfo unloadAddressInfo = new AddressInfo(frgtHaulingEnrgyUseRecord.Unload_Address__c);

            String loadAddressString = loadAddressInfo.toAddressString();
            String unloadAddressString = unloadAddressInfo.toAddressString();

            LogEntryEventBuilder logEntryBuilder = null;

            // the test data shown, that sometimes the addressess are the same, no need to pay for the API call to give us distance = 0
            if ( (loadAddressString != unloadAddressString) && loadAddressInfo.isBlank() == false && unloadAddressInfo.isBlank() == false ) {
                try {
                    Decimal distanceCalculated = 0;

                    FreightDistanceSelector frDistSelector = FreightDistanceSelector.newInstance();
                    Freight_Distance__c freightDistance = frDistSelector.selectOneFreightDistanceByAddressesAndFreightHaulingMode(
                                                                            frgtHaulingEnrgyUseRecord.FreightHaulingMode,
                                                                            frgtHaulingEnrgyUseRecord.Load_Address__c, 
                                                                            frgtHaulingEnrgyUseRecord.Unload_Address__c
                                                                        );

                    if (freightDistance != null) {
                        distanceCalculated = freightDistance.Distance__c;
                    } else {
                        String externalId = FreightDistanceService.buildExternalId(frgtHaulingEnrgyUseRecord.FreightHaulingMode, frgtHaulingEnrgyUseRecord.Load_Address__c, frgtHaulingEnrgyUseRecord.Unload_Address__c);
                        freightDistance = freightDistanceToInsert.get(externalId);

                        if(freightDistance != null) {
                            distanceCalculated = freightDistance.Distance__c;
                        } else {
                            distanceCalculated = this.pickAndRunDistanceCalculationService(frgtHaulingEnrgyUseRecord, loadAddressInfo, unloadAddressInfo);
                        }
                    }
                
                    frgtHaulingEnrgyUseRecord.Distance = distanceCalculated;
                    frgtHaulingEnrgyUseRecord.DistanceUnit = 'Kilometers';

                    if (freightDistance == null && distanceCalculated > 0) {
                        // the distance comes from the API call
                        frgtHaulingEnrgyUseRecord.Distance_From_API_Call__c = true;

                        // there was no Freight_Distance__c record in the DB, so we need to create it for future use
                        freightDistance = FreightDistanceService.freightDistanceFromDistanceModeAndAddresses(
                            distanceCalculated, 
                            frgtHaulingEnrgyUseRecord.FreightHaulingMode, 
                            frgtHaulingEnrgyUseRecord.Load_Address__c, 
                            frgtHaulingEnrgyUseRecord.Unload_Address__c
                        );
                        String externalId = FreightDistanceService.buildExternalId(freightDistance);

                        freightDistanceToInsert.put(externalId, freightDistance);
                    }
                } catch (GoogleMapsDistanceMatrixAPI.DistanceCalculationException err) {
                    logEntryBuilder = Logger.warn('Error while getting the distance: ' + err.getMessage(), frgtHaulingEnrgyUseRecord);

                    frgtHaulingEnrgyUseRecord.Failed_Distance_Calculation__c = true;
                } catch (DistanceToAPI.DistanceCalculationException err) {
                    logEntryBuilder = Logger.warn('Error while getting the distance: ' + err.getMessage(), frgtHaulingEnrgyUseRecord);

                    frgtHaulingEnrgyUseRecord.Failed_Distance_Calculation__c = true;
                } catch (SearatesDistanceAndTimeAPI.DistanceCalculationException err) {
                    logEntryBuilder = Logger.warn('Error while getting the distance: ' + err.getMessage(), frgtHaulingEnrgyUseRecord);

                    frgtHaulingEnrgyUseRecord.Failed_Distance_Calculation__c = true;
                } catch (DistanceCalculationException err) {
                    logEntryBuilder = Logger.warn('Distance calculated via API call is 0: ' + err.getMessage(), frgtHaulingEnrgyUseRecord);

                    frgtHaulingEnrgyUseRecord.Failed_Distance_Calculation__c = true;
                } catch (Exception err) {
                    logEntryBuilder = Logger.warn('Error while getting the distance: ' + err.getMessage(), frgtHaulingEnrgyUseRecord);

                    frgtHaulingEnrgyUseRecord.Failed_Distance_Calculation__c = true;
                }  finally {
                    recordsToUpdate.add(frgtHaulingEnrgyUseRecord);

                    if (logEntryBuilder != null) {
                        logEntryBuilder.addTag('FrgtHaulingEnrgyUseDistanceCalcBatch');
                    }
                }
            } else {
                // Load address and unload address are the same or blank No need to call the API.
                frgtHaulingEnrgyUseRecord.Failed_Distance_Calculation__c = true;
                recordsToUpdate.add(frgtHaulingEnrgyUseRecord);
            }
        }

        List<Freight_Distance__c> freightDistanceList = freightDistanceToInsert.values();
        this.saveFreigtDistanceRecords(freightDistanceList);

        this.updateFrgtHaulingEnrgyUseRecords(recordsToUpdate);

        // the line below DMLs the logs registered in the for loop above
        Logger.saveLog();
    }

    public void finish(Database.BatchableContext context) {
        // nothing to do here
    }

    @TestVisible
    private String translateFreightHaulingMode(String freightHaulingMode) {
        if (freightHaulingMode == 'Water') {
            return 'SEA';
        } 
            
        // AIR, RAIL, and ROAD are the same, just uppercase
        return freightHaulingMode.toUpperCase();
    }

    @TestVisible
    private Decimal pickAndRunDistanceCalculationService(FrgtHaulingEnrgyUse frgtHaulingEnrgyUseRecord, AddressInfo loadAddressInfo, AddressInfo unloadAddressInfo) {
        Decimal distanceCalculated = 0;

        Boolean isGoogleMapsEnabled = FeatureFlag__c.getInstance().NetZero_Enable_Google_Integration__c;
        Boolean isDistanceToEnabled = FeatureFlag__c.getInstance().NetZero_Enable_DistanceTo_Integration__c;
        Boolean isSearatesEnabled = FeatureFlag__c.getInstance().NetZero_Enable_Searates_Integration__c;

        String loadAddressString = loadAddressInfo.toAddressString();
        String unloadAddressString = unloadAddressInfo.toAddressString();

        if (frgtHaulingEnrgyUseRecord.FreightHaulingMode == 'Road' && isGoogleMapsEnabled == true) {
            // Google used for Road transport type
            distanceCalculated = GoogleMapsDistanceMatrixAPI.getDistanceInMeters(loadAddressString, unloadAddressString);

            if (distanceCalculated == 0) {
                throw new DistanceCalculationException('Distance calculated is 0');
            }

            distanceCalculated = distanceCalculated / 1000;

        } else if (frgtHaulingEnrgyUseRecord.FreightHaulingMode == 'Air' && isDistanceToEnabled == true) {
            // DistanceTo used for Air
            distanceCalculated = DistanceToAPI.getDistanceInMeters(
                                                    loadAddressInfo.getCity(),
                                                    loadAddressInfo.getCountryCode(),
                                                    unloadAddressInfo.getCity(),
                                                    unloadAddressInfo.getCountryCode()
                                                );
            if (distanceCalculated == 0) {
                throw new DistanceCalculationException('Distance calculated is 0');
            }

            distanceCalculated = distanceCalculated / 1000;

        } else if (isSearatesEnabled == true &&
                        (frgtHaulingEnrgyUseRecord.FreightHaulingMode == 'Rail' 
                            || frgtHaulingEnrgyUseRecord.FreightHaulingMode == 'Water')
                    ) {

            // for Rail and Water we use  different integration
            distanceCalculated = SearatesDistanceAndTimeAPI.getDistanceInMeters(
                                                loadAddressString, 
                                                unloadAddressString, 
                                                this.translateFreightHaulingMode(frgtHaulingEnrgyUseRecord.FreightHaulingMode)+',ROAD'
                                            );

            if (distanceCalculated == 0) {
                throw new DistanceCalculationException('Distance calculated is 0');
            }

            distanceCalculated = distanceCalculated / 1000;
        }

        return distanceCalculated;
    }
    
    private void saveFreigtDistanceRecords(List<Freight_Distance__c> freightDistanceList) {
        List<String> errorList = new List<String>();

        if (freightDistanceList.isEmpty() == true) {
            return;
        }

        Database.SaveResult[] fdsrList = Database.insert(freightDistanceList, false);

        // Iterate through each returned result
        for (Database.SaveResult sr : fdsrList) {
            if (!sr.isSuccess()) {
                // Operation failed, so get all errors                
                for(Database.Error err : sr.getErrors()) {
                    String error = err.getStatusCode() + ': ' + err.getMessage();
                    Logger.warn('Error while updating records: '+err.getMessage(), sr)
                        .addTag('FrgtHaulingEnrgyUseDistanceCalcBatch Freight_Distance__c');
                }
            }
        }
    }

    private void updateFrgtHaulingEnrgyUseRecords(List<FrgtHaulingEnrgyUse> recordsToUpdate) {
        List<String> errorList =  new List<String>();
        Database.SaveResult[] srList = Database.update(recordsToUpdate, false);

        if (recordsToUpdate.isEmpty() == true) {
            return;
        }

        // Iterate through each returned result
        for (Database.SaveResult sr : srList) {
            if (!sr.isSuccess()) {
                // Operation failed, so get all errors                
                for(Database.Error err : sr.getErrors()) {
                    String error = err.getStatusCode() + ': ' + err.getMessage();
                    Logger.warn('Error while updating records: '+err.getMessage(), sr)
                        .addTag('FrgtHaulingEnrgyUseDistanceCalcBatch FrgtHaulingEnrgyUse');
                }
            }
        }
    }

    public class DistanceCalculationException extends Exception {}
        
}