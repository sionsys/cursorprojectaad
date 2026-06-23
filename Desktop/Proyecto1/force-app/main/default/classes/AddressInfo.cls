// Function to build address string
public with sharing class AddressInfo {
    private String countryCode;
    private String stateCode;
    private String postalCode;
    private String city;
    private String street;
    
    public AddressInfo(Address address) {
        if (address == null) {
            return; 
        }

        this.countryCode = address.CountryCode;
        this.stateCode = address.StateCode;
        this.postalCode = address.PostalCode;
        this.city = address.City;
        this.street = address.Street;
    }
    
    public String toAddressString() {
        List<String> addressParts = this.getAddressPartsList();

        return String.join(addressParts, ', ');
    }

    public String addressToExternalIdString() {
        List<String> addressParts = this.getAddressPartsList();

        return String.join(addressParts, '');
    }

    public Boolean isBlank() {
        return String.isBlank(countryCode) && String.isBlank(stateCode) && String.isBlank(postalCode) && String.isBlank(city) && String.isBlank(street);
    }

    public String getCity() {
        return this.city;
    }

    public String getCountryCode() {
        return this.countryCode;
    }

    @TestVisible
    private List<String> getAddressPartsList() {
        List<String> addressParts = new List<String>();

        if (String.isNotBlank(countryCode)) {
            addressParts.add(countryCode);
        }
        if (String.isNotBlank(stateCode)) {
            addressParts.add(stateCode);
        }
        if (String.isNotBlank(postalCode)) {
            addressParts.add(postalCode);
        }
        if (String.isNotBlank(city)) {
            addressParts.add(city);
        }
        if (String.isNotBlank(street)) {
            addressParts.add(street);
        }

        return addressParts;
    }
}