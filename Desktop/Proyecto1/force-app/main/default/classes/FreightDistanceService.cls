public with sharing class FreightDistanceService {
    public FreightDistanceService() {

    }

    /*
     * Method shared in the package, it is responsible for generating the address concatenation in order to be used as a part of external id 
     */
    public static String generateExternalIdAddressPart(String street, String postalCode, String city, String stateCode, String countryCode) {
        String fullAddress = countryCode + stateCode + postalCode + city + street;
        return fullAddress;
    }

    public static String buildExternalId(Freight_Distance__c record) {
        String freightHaulingMode = record.Freight_Hauling_Mode__c ?? '';
        return FreightDistanceService.buildExternalId(
                                            freightHaulingMode, 
                                            FreightDistanceService.loadAddressFieldToString(record), 
                                            FreightDistanceService.unloadAddressFieldToString(record)
                                        );
    }

    public static String buildExternalId(String freightHaulingMode, Address loadAddress, Address unloadAddress) {
        return FreightDistanceService.buildExternalId(
                                            freightHaulingMode, 
                                            FreightDistanceService.addressToExternalIdString(loadAddress), 
                                            FreightDistanceService.addressToExternalIdString(unloadAddress)
                                        );
    }

    /**
     * changes in this method require rebuilding the whole cache, as it is used to generate the external id for the records
     * 
     * delete all the Freight_Distance__c records and run the batch FreightDistanceOneTimeCreateBatch again
     */
    public static String buildExternalId(String freightHaulingMode, String loadAddress, String unloadAddress) {
        if (freightHaulingMode == null) {
            freightHaulingMode = '';
        }
        if (loadAddress == null) {
            loadAddress = '';
        }
        if (unloadAddress == null) {
            unloadAddress = '';
        }

        String externalId = freightHaulingMode + loadAddress + unloadAddress;
        return externalId.deleteWhitespace().toLowerCase();
    }

    public static Freight_Distance__c freightDistanceFromFrgtHaulingEnrgyUse(FrgtHaulingEnrgyUse frghHaulingEnergyUse) {
        Freight_Distance__c freightDistance = new Freight_Distance__c(
                Distance__c = frghHaulingEnergyUse.Distance,
                Freight_Hauling_Mode__c = frghHaulingEnergyUse.FreightHaulingMode,

                Load_Address__CountryCode__s = frghHaulingEnergyUse.Load_Address__CountryCode__s,
                Load_Address__StateCode__s = frghHaulingEnergyUse.Load_Address__StateCode__s,
                Load_Address__PostalCode__s = frghHaulingEnergyUse.Load_Address__PostalCode__s,
                Load_Address__City__s = frghHaulingEnergyUse.Load_Address__City__s,
                Load_Address__Street__s = frghHaulingEnergyUse.Load_Address__Street__s,

                Unload_Address__CountryCode__s = frghHaulingEnergyUse.Unload_Address__CountryCode__s,
                Unload_Address__StateCode__s = frghHaulingEnergyUse.Unload_Address__StateCode__s,
                Unload_Address__PostalCode__s = frghHaulingEnergyUse.Unload_Address__PostalCode__s,
                Unload_Address__City__s = frghHaulingEnergyUse.Unload_Address__City__s,
                Unload_Address__Street__s = frghHaulingEnergyUse.Unload_Address__Street__s
            );
        return freightDistance;
    }

    public static Freight_Distance__c freightDistanceFromDistanceModeAndAddresses(Decimal distance, String freightHaulingMode, Address loadAddress, Address unloadAddress) {
        return new Freight_Distance__c(
            Distance__c = distance,
            Freight_Hauling_Mode__c = freightHaulingMode,

            Load_Address__CountryCode__s = loadAddress.CountryCode,
            Load_Address__StateCode__s = loadAddress.StateCode,
            Load_Address__PostalCode__s = loadAddress.PostalCode,
            Load_Address__City__s = loadAddress.City,
            Load_Address__Street__s = loadAddress.Street,

            Unload_Address__CountryCode__s = unloadAddress.CountryCode,
            Unload_Address__StateCode__s = unloadAddress.StateCode,
            Unload_Address__PostalCode__s = unloadAddress.PostalCode,
            Unload_Address__City__s = unloadAddress.City,
            Unload_Address__Street__s = unloadAddress.Street
        );
    }

    private static String addressToExternalIdString(Address addresField) {
        AddressInfo addressInfo = new AddressInfo(addresField);
        return addressInfo.addressToExternalIdString();
    }

    private static String loadAddressFieldToString(Freight_Distance__c record) {
        if (record == null) {
            return '';
        }

        String street = String.isBlank(record.Load_Address__Street__s) ? '' : record.Load_Address__Street__s;
        String postalCode = String.isBlank(record.Load_Address__PostalCode__s) ? '' : record.Load_Address__PostalCode__s;
        String city = String.isBlank(record.Load_Address__City__s) ? '' : record.Load_Address__City__s;
        String stateCode = String.isBlank(record.Load_Address__StateCode__s) ? '' : record.Load_Address__StateCode__s;
        String countryCode = String.isBlank(record.Load_Address__CountryCode__s) ? '' : record.Load_Address__CountryCode__s;

        return FreightDistanceService.generateExternalIdAddressPart(street, postalCode, city, stateCode, countryCode);
    }

    private static String unloadAddressFieldToString(Freight_Distance__c record) {
        if (record == null) {
            return '';
        }

        String street = String.isBlank(record.Unload_Address__Street__s) ? '' : record.Unload_Address__Street__s;
        String postalCode = String.isBlank(record.Unload_Address__PostalCode__s) ? '' : record.Unload_Address__PostalCode__s;
        String city = String.isBlank(record.Unload_Address__City__s) ? '' : record.Unload_Address__City__s;
        String stateCode = String.isBlank(record.Unload_Address__StateCode__s) ? '' : record.Unload_Address__StateCode__s;
        String countryCode = String.isBlank(record.Unload_Address__CountryCode__s) ? '' : record.Unload_Address__CountryCode__s;

        return FreightDistanceService.generateExternalIdAddressPart(street, postalCode, city, stateCode, countryCode);
    }
}