/**
 * Class AccessPermissionOnProfiles
 *
 * Used to Provide access or restrict access based on permission on profiles to all sobjects and fields.
 */

public with sharing class AccessPermissionOnProfiles {
	/*  This method will first specify the object name and then match it with the custom 
	 *  setting ‘SpecialProfilePermissionForEditObjects’ object name,
	 *	if matched then proceed to next step.*/
	 
	public static Map<Id,Sobject> EditAccessOnFields(string pSObjectName,Map<Id,Sobject> pNewMap,Map<Id,Sobject> pOldMap){
		profile loggedProfileName;
		Map<Id,SObject> updatedRecordsMap = new Map<Id,SObject>();
		list<SpecialProfilePermissionForEditObjects__c> Objprofile = new list<SpecialProfilePermissionForEditObjects__c>();
		loggedProfileName = [Select Name From Profile where Id =: UserInfo.getProfileId()];
		
		Objprofile = [select Name__c,AllowedProfilesforEdit__c,EditAllFields__c,RestrictedfieldsforEdit__c 
					  from SpecialProfilePermissionForEditObjects__c 
					  where Name__c =: pSObjectName 
					  and AllowedProfilesforEdit__c =: loggedProfileName.Name];
					   
		if(Objprofile.size()>0 ){
			//If "edit all fields" is checked on custom setting
			if(Objprofile[0].EditAllFields__c){
				return Null;
			}
			else{
				//If "Restricted fields for Edit" is null or blank.
				if(Objprofile[0].RestrictedfieldsforEdit__c == null || 
					Objprofile[0].RestrictedfieldsforEdit__c == ''&& 
					Objprofile[0].EditAllFields__c == false){
					 return null;
				}
				//If fields are mentioned in "Restricted fields for Edit" on which edit operation is fire.
				else{
					List<String> restrictedFieldsLst = String.valueOf(Objprofile[0].RestrictedfieldsforEdit__c).split(',');
					for(Sobject newMapItr :pNewMap.Values()){
						
						Sobject oldMapValue = pOldMap.get(newMapItr.Id);
						Sobject newMapvalue =  pNewMap.get(newMapItr.Id);
						
						for(String fieldItr : restrictedFieldsLst) 
						if(oldmapValue.get(fieldItr) != newMapvalue.get(fieldItr)){
							updatedRecordsMap.put(newMapItr.Id,newMapItr);
							break;
						}
					}
					for(Sobject errorRecordsItr :updatedRecordsMap.values()){
						errorRecordsItr.addError(system.label.Error_Message_On_Access_Restricted_Fields+' '+ restrictedFieldsLst);
					}
					return updatedRecordsMap;
				}
			}//else ends
		}//if ends
		else{
			for(Sobject newMapRecItr : pNewMap.values()){
				newMapRecItr.addError(system.label.Error_Message_On_No_Profile_Matched);
			}
			return pNewMap;
		}
	}//EditAccessOnFields ends
}//AccessPermissionOnProfiles ends