@IsTest
private class FrgtHaulingEnrgyUseToFreightDistCtrlTest {
    @IsTest
    static void testGetFreightDistanceDataWithValidRecord() {
        // Arrange
        Scope3EmssnSrc scope3emSource = new Scope3EmssnSrc();
        scope3emSource.Name = 'Test Record';
        insert scope3emSource;

        FrgtHaulingEnrgyUse frgtHaulingEnrgyUseRecord = new FrgtHaulingEnrgyUse(
            Name = 'Test Record ',
            FreightHaulingMode = 'Road',
            Load_Address__City__s = 'New York',
            Load_Address__PostalCode__s = '10001',
            Load_Address__CountryCode__s = 'US',
            Unload_Address__City__s = 'San Francisco',
            Unload_Address__PostalCode__s = '94105',
            Unload_Address__CountryCode__s = 'US',
            Distance = 100,
            Scope3EmssnSrcId = scope3emSource.Id
        );
        insert frgtHaulingEnrgyUseRecord;

        Freight_Distance__c freightDistance = new Freight_Distance__c(
            Load_Address__City__s = 'New York',
            Load_Address__PostalCode__s = '10001',
            Load_Address__CountryCode__s = 'US',
            Unload_Address__City__s = 'San Francisco',
            Unload_Address__PostalCode__s = '94105',
            Unload_Address__CountryCode__s = 'US',
            Freight_Hauling_Mode__c = 'Road'
        );
        insert freightDistance;

        Test.startTest();
        // Act
        FrgtHaulingEnrgyUseToFreightDistCtrl.FreightDistanceData result = FrgtHaulingEnrgyUseToFreightDistCtrl.getFreightDistanceData(frgtHaulingEnrgyUseRecord.Id);
        Test.stopTest();

        // Assert
        System.assertNotEquals(null, result);
        System.assertNotEquals(null, result.linkToFreightDistance);
        System.assertNotEquals(null, result.externalId);
    }

    @IsTest
    static void testGetFreightDistanceDataWithInvalidRecord() {
        // Arrange
        Id invalidRecordId = '001000000000000';

        Test.startTest();
        // Act
        FrgtHaulingEnrgyUseToFreightDistCtrl.FreightDistanceData result = FrgtHaulingEnrgyUseToFreightDistCtrl.getFreightDistanceData(invalidRecordId);
        Test.stopTest();

        // Assert
        System.assertNotEquals(null, result);
        System.assertEquals(null, result.freightDistanceName);
        System.assertEquals(null, result.linkToFreightDistance);
        System.assertEquals(null, result.externalId);
    }
}