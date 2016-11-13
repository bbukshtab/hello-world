/**********************************
* Name: AccountHandlerTest
* Created Tech teamk
* Description: Manage AccountHandlerTest
* Modified Date   : 2015.11.30 | Modified By: Boris bukshtab | Modified for Story: SF-4450
************************************/
@isTest
public class AccountHandlerTest {

//b.b start SF-4450
@TestSetup static void setUpData()
     {
        Account account1 = TestObjectCreationUtil.createTestAccnts(1,true)[0];
        System.debug('Account1: ' + account1.id);
        List<Opportunity> newOppA = TestObjectCreationUtil.createClosedWonOpptys(2, account1, false);

        newOppA[0].Product_Family__c = 'LOC';
        newOppA[0].Net_Funded_Amount__c = 1200;

        newOppA[1].Product_Family__c = 'LOC';
        newOppA[1].Net_Funded_Amount__c = 2200;


        newOppA[0].Name = 'Test Opp Account1 Closed Won#1';
        newOppA[0].Type = 'Loan - New Customer';
        newOppA[1].Name = 'Test Opp Account1 Closed Won#2';
        newOppA[1].Type = 'Loan - New Customer';


        Application__c app = new Application__c();
        app.Business_Inception_Date__c = System.today();
        insert app;

        newOppA[0].Application__c = app.Id;
        newOppA[1].Application__c = app.Id;

        insert newOppA;

        newOppA[0].Loan_id__c = 'loan #1';
        newOppA[0].CloseDate = Date.today();
        newOppA[0].stagename = 'Closed Won';
        newOppA[1].Loan_id__c = 'loan #2';
        newOppA[1].CloseDate = Date.today();
        newOppA[1].stagename = 'Closed Won';

        Test.StartTest();
           update newOppA;

           newOppA[1].CloseDate = Date.today().AddDays(-1);

           update newOppA;
        Test.StopTest();

    }

    static testMethod void testAccountsMergeLoanTypeOnOpp(){

        Account account1 = TestObjectCreationUtil.createTestAccnts(1,true)[0];
        System.debug('Account1: ' + account1.id);
        List<Opportunity> newOppA = TestObjectCreationUtil.createTestOpptys(1, account1, false);

        Application__c app = new Application__c();
        app.Business_Inception_Date__c = System.today();
        insert app;

        newOppA[0].Application__c = app.Id;
        newOppA[0].Name = 'Test Opp Account1 NOT Closed Won';

        insert newOppA;

        Account masterAcct = [SELECT Id, Name FROM Account WHERE Name = 'Testing Account0' LIMIT 1];


        Test.StartTest();

          merge masterAcct account1;

          Opportunity oppControlList = [SELECT id, loan_type__c, AccountId, stageName FROM Opportunity WHERE Name = 'Test Opp Account1 NOT Closed Won' limit 1];
          System.assertEquals('Existing Customer Application',oppControlList.loan_type__c);

          oppControlList = [SELECT id, loan_type__c, AccountId, stageName FROM Opportunity WHERE Loan_id__c = 'loan #2' limit 1];
          System.assertEquals(masterAcct.Id,oppControlList.AccountId);
          System.assertEquals('New Customer',oppControlList.loan_type__c);

          oppControlList = [SELECT id, loan_type__c, AccountId, stageName FROM Opportunity WHERE Loan_id__c = 'loan #1' limit 1];
          //System.assertEquals('New Customer',oppControlList.loan_type__c);
          System.assertEquals('Existing Customer, Repeat Product',oppControlList.loan_type__c);

        Test.StopTest();

    }
    //b.b end SF-4450

    static testMethod void testHandleDnc(){
        List<Account> listAccnts = TestObjectCreationUtil.createTestAccnts(1, true);
        for(Account acc: listAccnts){
        	List<Opportunity> listOppts = TestObjectCreationUtil.createClosedWonOpptys(1, acc, true);
        	List<Application__c> listApps = TestObjectCreationUtil.createTestApps(1, true);
        	Id opptId = listOppts.get(0).Id;
        	Opportunity opp = [SELECT Id, Application__c from Opportunity WHERE id = :opptId];
        	opp.Application__c = listApps.get(0).Id;
        	update opp;
        	//listOppts.get(0).Application__c = listApps.get(0).Id;
    	}
    	Id accId = listAccnts.get(0).Id;
    	Account account = [SELECT Id, Do_Not_Call__c from Account where Id = :accId];
    	account.Do_Not_Call__c = true;
    	update account;
    }

    static testMethod void testLocationId(){
    	Account account = new Account();
    	account.name = 'Just a test account';
    	insert account;
    	Id accountId = account.Id;

    	Account updatedAccount = [SELECT Id, Location_ID__c FROM Account WHERE Id = :accountId];
    	System.assertNotEquals(null, updatedAccount.Location_ID__c);

    }
}