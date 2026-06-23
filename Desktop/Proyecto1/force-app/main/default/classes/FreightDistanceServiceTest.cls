@IsTest
public with sharing class FreightDistanceServiceTest {
    
    // Generate full address string from valid input fields
    @isTest
    private static void testGenerateExternalIdAddressPartWithValidInput() {
        // Arrange
        String street = '123 Main St';
        String postalCode = '12345';
        String city = 'Metropolis';
        String stateCode = 'NY';
        String countryCode = 'USA';
        
        // Act
        String result = FreightDistanceService.generateExternalIdAddressPart(street, postalCode, city, stateCode, countryCode);
        
        // Assert
        System.assertEquals('USANY12345Metropolis123 Main St', result);
    }

    // Handle empty strings for all address components
    @isTest
    private static void testGenerateExternalIdAddressPartWithEmptyStrings() {
        // Arrange
        String street = '';
        String postalCode = '';
        String city = '';
        String stateCode = '';
        String countryCode = '';
        
        // Act
        String result = FreightDistanceService.generateExternalIdAddressPart(street, postalCode, city, stateCode, countryCode);
        
        // Assert
        System.assertEquals('', result);
    }

    // Converts FrgtHaulingEnrgyUse to Freight_Distance__c accurately
    @isTest
    private static void convertFrgtHaulingEnergyUseToFreightDistance() {
        // Arrange
        FrgtHaulingEnrgyUse frghHaulingEnergyUse = new FrgtHaulingEnrgyUse(
            Distance = 100.0,
            FreightHaulingMode = 'Truck',
            Load_Address__CountryCode__s = 'US',
            Load_Address__StateCode__s = 'CA',
            Load_Address__PostalCode__s = '94016',
            Load_Address__City__s = 'San Francisco',
            Load_Address__Street__s = 'Market Street',
            Unload_Address__CountryCode__s = 'US',
            Unload_Address__StateCode__s = 'NV',
            Unload_Address__PostalCode__s = '89101',
            Unload_Address__City__s = 'Las Vegas',
            Unload_Address__Street__s = 'Fremont Street'
        );

        // Act
        Freight_Distance__c result = FreightDistanceService.freightDistanceFromFrgtHaulingEnrgyUse(frghHaulingEnergyUse);

        // Assert
        System.assertEquals(100.0, result.Distance__c);
        System.assertEquals('Truck', result.Freight_Hauling_Mode__c);
        System.assertEquals('US', result.Load_Address__CountryCode__s);
        System.assertEquals('CA', result.Load_Address__StateCode__s);
        System.assertEquals('94016', result.Load_Address__PostalCode__s);
        System.assertEquals('San Francisco', result.Load_Address__City__s);
        System.assertEquals('Market Street', result.Load_Address__Street__s);
        System.assertEquals('US', result.Unload_Address__CountryCode__s);
        System.assertEquals('NV', result.Unload_Address__StateCode__s);
        System.assertEquals('89101', result.Unload_Address__PostalCode__s);
        System.assertEquals('Las Vegas', result.Unload_Address__City__s);
        System.assertEquals('Fremont Street', result.Unload_Address__Street__s);
    }

    // Creates a Freight_Distance__c record with valid input parameters
    @isTest
    private static void createFreightDistanceWithValidParameters() {
        // Create test data
        Scope3EmssnSrc scope3emSource = new Scope3EmssnSrc();
        scope3emSource.Name = 'Test Record';
        insert scope3emSource;

        FrgtHaulingEnrgyUse record = new FrgtHaulingEnrgyUse(
            Name = 'Test Record',
            Distance = 100,
            FreightHaulingMode = 'Road',
            Load_Address__CountryCode__s = 'US',
            Load_Address__StateCode__s = 'CA',
            Load_Address__PostalCode__s = '90001',
            Load_Address__City__s = 'Los Angeles',
            Load_Address__Street__s = '123 Main St',
            Unload_Address__CountryCode__s = 'US',
            Unload_Address__StateCode__s = 'NV',
            Unload_Address__PostalCode__s = '89101',
            Unload_Address__City__s = 'Las Vegas',
            Unload_Address__Street__s = '456 Elm St',
            Transport_Type__c = 'Outbound',
            Scope3EmssnSrcId = scope3emSource.Id
        );
        insert record;

        FrgtHaulingEnrgyUse retrievedRecord = [SELECT Id, Distance, FreightHaulingMode, Load_Address__c, Unload_Address__c FROM FrgtHaulingEnrgyUse WHERE Id = :record.Id];

        // Act
        Freight_Distance__c result = FreightDistanceService.freightDistanceFromDistanceModeAndAddresses(retrievedRecord.Distance, retrievedRecord.FreightHaulingMode, retrievedRecord.Load_Address__c, retrievedRecord.Unload_Address__c);

        // Assert
        System.assertEquals(record.Distance, result.Distance__c, 'Distance does not match');
        System.assertEquals(record.FreightHaulingMode, result.Freight_Hauling_Mode__c, 'Freight Hauling Mode does not match');
        System.assertEquals(record.Load_Address__CountryCode__s, result.Load_Address__CountryCode__s, 'Load Address Country Code does not match');
        System.assertEquals(record.Load_Address__StateCode__s, result.Load_Address__StateCode__s, 'Load Address State Code does not match');
        System.assertEquals(record.Load_Address__PostalCode__s, result.Load_Address__PostalCode__s, 'Load Address Postal Code does not match');
        System.assertEquals(record.Load_Address__City__s, result.Load_Address__City__s, 'Load Address City does not match');
        System.assertEquals(record.Load_Address__Street__s, result.Load_Address__Street__s, 'Load Address Street does not match');
        System.assertEquals(record.Unload_Address__CountryCode__s, result.Unload_Address__CountryCode__s, 'Unload Address Country Code does not match');
        System.assertEquals(record.Unload_Address__StateCode__s, result.Unload_Address__StateCode__s, 'Unload Address State Code does not match');
        System.assertEquals(record.Unload_Address__PostalCode__s, result.Unload_Address__PostalCode__s, 'Unload Address Postal Code does not match');
        System.assertEquals(record.Unload_Address__City__s, result.Unload_Address__City__s, 'Unload Address City does not match');
        System.assertEquals(record.Unload_Address__Street__s, result.Unload_Address__Street__s, 'Unload Address Street does not match');
    }

    static void testBuildExternalIdPositive() {
        // Arrange
        String haulingMode = 'AirFreight';
        String loadAddress = 'USAFL33134Miami1234MainSt';
        String unloadAddress = 'USAFL33135Miami5678Broadway';

        // Act
        String result = FreightDistanceService.buildExternalId(haulingMode, loadAddress, unloadAddress);

        // Assert
        System.assertEquals('airfreightusafl33134miami1234mainstusafl33135miami5678broadway', result, 'The result should be in lowercase with no whitespaces.');
    }

    @isTest
    static void testBuildExternalIdNegative() {
        // Arrange
        String haulingMode = null;
        String loadAddress = 'USAFL33134Miami1234MainSt';
        String unloadAddress = '';

        // Act
        String result = FreightDistanceService.buildExternalId(haulingMode, loadAddress, unloadAddress);

        // Assert
        System.assertEquals('usafl33134miami1234mainst', result, 'The result should handle null and blank inputs and still convert to lowercase.');
    }

}