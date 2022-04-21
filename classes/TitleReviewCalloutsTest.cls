/**
 * @description Salesforce Auction Id is missing on Case when a digital Case is created before Auction.
 * This trigger will backfill the missing Acution Id on Case.
 * 
 * 
 * @author Manmeet Vaseer
 * @date 04/07/2022
 * 
 * @history
 * 		04/07/2022 Manmeet Vaseer - Initial Revision.
 * 
 */ 
@isTest
public class TitleReviewCalloutsTest {
	@isTest
    public static void testSetTitleReviewSalesforceId()	{
        List<Title_Review__c> titleReviews = new List<Title_Review__c>();

		Title__c aTitle = new Title__c(Name = 'title');
        insert aTitle;
        
        Title_Review__c aTitleReview = new Title_Review__c(
            Name = 'title review 1',
            Commit_Pending__c = true,
            Title__c = aTitle.Id
        );

		insert aTitleReview;        
    }
}