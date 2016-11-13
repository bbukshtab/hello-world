/**********************************
* Name: AccountHandler
* Created Tech teamk
* Description: Manage AccountTrigger
* Modified Date   : 2015.11.30 | Modified By: Boris bukshtab | Modified for Story: SF-4450
************************************/

public with sharing class AccountHandler {
    static Set<Id> acctMasterIdSet = new Set<Id>();
    static boolean loanTypeAccountDone = FALSE;
    static final String loanProductLOC = 'LOC';

    public static void onAfterUpdate(List<Account> newAccountList, Map<Id,Account> oldMap){
        handleDnc(newAccountList, oldMap);

    //b.b SF-4450 Start reevaluate  all opportunities Loan Type on account when accounts merged using native SF.
        reEvaluateAccountOppLoanType(newAccountList, oldMap);
    }

    public static void onAfterDelete(List<Account> oldAccountList){
        for(Account acct : oldAccountList) {
            if(String.isNotBlank(acct.MasterRecordId)) {
                acctMasterIdSet.add(acct.MasterRecordId);
                System.debug('on deleted account MasterRecordId: ' + acct.MasterRecordId);
            }
        }
    }
    //b.b SF-4450 end

    public static void onAfterInsert(List<Account> newAccountList, Map<Id,Account> oldMap){
       addLocationId(newAccountList);
       handleDnc(newAccountList, oldMap);
    }

    static void handleDnc(List<Account> newAccountList, Map<Id, Account> oldMap){
    	Set<Id> dncAccountIds = new Set<Id>();
    	for(Account account: newAccountList){
    		if(account.Do_Not_Call__c){
    			if(oldMap.get(account.id)==null || !oldMap.get(account.id).Do_Not_Call__c){
    				dncAccountIds.add(account.id);
    			}
    		}
    	}
        if(!dncAccountIds.isEmpty())
    	   DialerService.handleAccounts(dncAccountIds);
    }

    static void addLocationId(List<Account> newAccountList){
    	List<Account> accounts = [SELECT Id, Location_ID__c FROM Account WHERE Id = :newAccountList];
        for(Account account: accounts)
        {
            account.Location_ID__c = Helper.randomUUID();
        }
        update accounts;
    }

    /*
    *SF-4450 b.b
    ********************************************/
    static void reEvaluateAccountOppLoanType(List<Account> newAccountList, Map<Id,Account> oldMap){

        Set<Id> accountIdsToReEvaluate = new Set<Id>();

        if(acctMasterIdSet != null && acctMasterIdSet.size() > 0)
        {
            for(Account acct: newAccountList)
            {

              if(acctMasterIdSet.contains(acct.Id))
                 accountIdsToReEvaluate.add(acct.Id);
            }
        }

        if (accountIdsToReEvaluate.size() == 0 || loanTypeAccountDone)
           return;
        else
        {
           System.debug('Accounts to be ReEvaluated: ' + accountIdsToReEvaluate);
           LoanTypeOnOpportunity.loanTypeOnAccountOppReEvaluate(accountIdsToReEvaluate);
           loanTypeAccountDone = TRUE;
        }

    }

}