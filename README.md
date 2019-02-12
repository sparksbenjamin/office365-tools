# Office 365 Toolbox

This is a collection of scripts that will create some basic security rules on your Office 365 Exchange online.  You will need to update the scripts to use your EMAIL and PASSWORD!  Once you have done that they script should run and create or update the rules on exchange.  Each script is explaned below. 

<h3>Unverified Sender</h3><p>This rule wll add [Unverified Sender] to the subject of inbound emails that have not passed the SPF check.  This will alert the mailbox user that the email may not be who it claims to be from.  Simple google search will show and explain what that means and how to proceed. This is a common prefix to put in the subject line and is in common practice to inclued GMAIL, YAHOO and AOL.</p>

<h3>Matching External Senders</h3><p>This will create a rule that will prepend text to the inbound external email that has a sender that matches one of your users display name.  This will help the mailbox owner know when they are repling to an external account and not a org mailbox.</p>

<h3>Group Bulk Imports</h3><p>This script is meant to work for Distribution Groupsa and takes the paramater of csv. A template of this CSV has been provided called bulk-import-template.csv. This will allow you to setup a import csv with the identity of the groups and the email addresses that get imported into that group.  The script will prompt you for a run as account to use to perform this operation.  It is suggested that this group be an admin or the owner of the the group.</p>
  
  
