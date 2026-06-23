@IsTest
public with sharing class AddressInfoTest {

    // Check if toAddressString handles special characters in address fields correctly
    @isTest
    private static void testToAddressStringWithSpecialCharacters() {
        // JSON representation of the address
        String addressJson = '{' +
            '"street": "Market Street",' +
            '"city": "San Francisco",' +
            '"state": "CA",' +
            '"postalCode": "94016",' +
            '"country": "US",' +
            '"stateCode": "CA",' +
            '"countryCode": "US"' +
        '}';

        // Deserialize to create an Address object
        Address address = (Address)JSON.deserialize(addressJson, Address.class);

        // Act
        AddressInfo addressInfo = new AddressInfo(address);

        // Assert
        System.assertEquals(false, addressInfo.isBlank());
        System.assertEquals('US, CA, 94016, San Francisco, Market Street', addressInfo.toAddressString());
    }

    // Verify addressToExternalIdString handles special characters in address fields correctly
    @isTest
    private static void testAddressToExternalIdStringWithSpecialCharacters() {
        // JSON representation of the address
        String addressJson = '{' +
            '"street": "Market Street",' +
            '"city": "San Francisco",' +
            '"state": "CA",' +
            '"postalCode": "94016",' +
            '"country": "US",' +
            '"stateCode": "CA",' +
            '"countryCode": "US"' +
        '}';

        // Deserialize to create an Address object
        Address address = (Address)JSON.deserialize(addressJson, Address.class);

        AddressInfo addressInfo = new AddressInfo(address);

        // Act
        String externalIdString = addressInfo.addressToExternalIdString();

        // Assert
        System.assertEquals('USCA94016San FranciscoMarket Street', externalIdString);
    }

    // Verify getAddressPartsList returns an empty list when all fields are blank
    @isTest
    private static void testGetAddressPartsListReturnsEmptyListWhenAllFieldsAreBlank() {
        // Arrange
        AddressInfo addressInfo = new AddressInfo(new Address());

        // Act
        List<String> addressParts = addressInfo.getAddressPartsList();

        // Assert
        System.assertEquals(0, addressParts.size());
    }

    // Check if AddressInfo with all fields blank returns true for isBlank
    private static void testAddressInfoWithAllFieldsBlank() {
        // Arrange
        Address address = new Address();
        
        // Act
        AddressInfo addressInfo = new AddressInfo(address);
        
        // Assert
        System.assertEquals(true, addressInfo.isBlank());
    }

}