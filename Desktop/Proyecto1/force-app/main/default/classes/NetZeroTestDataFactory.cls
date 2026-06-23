@IsTest
public class NetZeroTestDataFactory {

    public static void createFreightHaulingEnergyUseRecordsForBatch() {
        createFreightHaulingEnergyUseRecordsForBatch(false);
    }
    
    public static void createFreightHaulingEnergyUseRecordsForBatch(Boolean allRecordsFailedDistanceCalculation) {
        Scope3EmssnSrc scope3emSource = new Scope3EmssnSrc();
        scope3emSource.Name = 'Test Record';
        insert scope3emSource;

        List<Map<String, String>> loadAddressList = new List<Map<String, String>> {
            new Map<String, String>{'Load_Address__City__s' => 'EINDHOVEN', 'Load_Address__PostalCode__s' => '5651GH', 'Load_Address__CountryCode__s' => 'NL'},
            new Map<String, String>{'Load_Address__City__s' => 'Paulsboro', 'Load_Address__PostalCode__s' => '08066', 'Load_Address__CountryCode__s' => 'US'}
        };
        List<Map<String, String>> unloadAddressList = new List<Map<String, String>> {
            new Map<String, String>{'Unload_Address__City__s' => 'DRESDEN', 'Unload_Address__PostalCode__s' => '1109', 'Unload_Address__CountryCode__s' => 'DE'},
            new Map<String, String>{'Unload_Address__City__s' => 'ANGERS', 'Unload_Address__PostalCode__s' => '49100', 'Unload_Address__CountryCode__s' => 'FR'},
            new Map<String, String>{'Unload_Address__City__s' => 'HIGH POINT', 'Unload_Address__PostalCode__s' => '272624318', 'Unload_Address__CountryCode__s' => 'US'}
        };

        // Create test data
        List<FrgtHaulingEnrgyUse> frgtHaulingEnrgyUseList = new List<FrgtHaulingEnrgyUse>();
        for (Integer i = 0; i < 10; i++) {
            FrgtHaulingEnrgyUse frgtHaulingEnrgyUse = new FrgtHaulingEnrgyUse();
            
            if (i<7) {
                // load address
                Map<String, String> loadAddress = getRandomValue(loadAddressList);
                frgtHaulingEnrgyUse.Load_Address__City__s = loadAddress.get('Load_Address__City__s');
                frgtHaulingEnrgyUse.Load_Address__PostalCode__s = loadAddress.get('Load_Address__PostalCode__s');
                frgtHaulingEnrgyUse.Load_Address__CountryCode__s = loadAddress.get('Load_Address__CountryCode__s');
                
                // unload address
                Map<String, String> unloadAddress = getRandomValue(unloadAddressList);
                frgtHaulingEnrgyUse.Unload_Address__City__s = unloadAddress.get('Unload_Address__City__s');
                frgtHaulingEnrgyUse.Unload_Address__PostalCode__s = unloadAddress.get('Unload_Address__PostalCode__s');
                frgtHaulingEnrgyUse.Unload_Address__CountryCode__s = unloadAddress.get('Unload_Address__CountryCode__s');
            }

            // Set other standard fields
            frgtHaulingEnrgyUse.Name = 'Test Record ' + i;
            frgtHaulingEnrgyUse.Transport_Type__c = 'Outbound';
            frgtHaulingEnrgyUse.Scope3EmssnSrcId = scope3emSource.Id;
            frgtHaulingEnrgyUse.Distance = 0;
            frgtHaulingEnrgyUse.FreightHaulingMode = 'Road';

            if (allRecordsFailedDistanceCalculation) {
                frgtHaulingEnrgyUse.Failed_Distance_Calculation__c = true;
            }
            
            // Add the record to the list
            frgtHaulingEnrgyUseList.add(frgtHaulingEnrgyUse);
        }
        insert frgtHaulingEnrgyUseList;

        // Disable all feature flags
        FeatureFlag__c featureFlags = FeatureFlag__c.getInstance();
        featureFlags.NetZero_Enable_Google_Integration__c = true;
        featureFlags.NetZero_Enable_DistanceTo_Integration__c = true;
        featureFlags.NetZero_Enable_Searates_Integration__c = true;
        upsert featureFlags;
    }

    private static Map<String, String> getRandomValue(List<Map<String, String>> values) {
        Integer randomIndex = Math.mod(Math.abs(Crypto.getRandomInteger()), values.size());
        return values[randomIndex];
    }
}