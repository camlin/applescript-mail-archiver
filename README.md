# applescript-mail-archiver
AppleScript allowing automatic email archiving in the Apple Mail Application.

This is useful in particular if you want to share emails between multiple devices (via IMAP) but do not want to deal with the issue of the IMAP account later exceeding its quota (Or use some providers that have big quota, like Google, but where there is always a catch).

Basically, this script should be run on a MacOS computer that will be responsible for storing (archiving) your emails locally on its file system.

This is done by creating a local mailbox in Apple Mail and then configuring the script to use that mailbox when the email is older than a given number of days.

The script will archive the two main Apple mail mailboxes, i.e. Inbox and SENT.

Customising the name of the target mailboxes is done by changing the values of the `pInboxArchiveName` and `pSentArchiveName` properties.

Customising the number of days after which any given email will be archived is controlled by the properties `pInboxArchiveDelay` and `pSentArchiveDelay`.

To work, the script will need to be located in the folder `~/Libray/Application Scripts/com.apple.mail`

Final step will be to create a Rule in Apple Mail that triggers the script for every email received:

![applescript-mail-archiver](https://github.com/camlin/applescript-mail-archiver/blob/master/rule-screenshot1.png)

![applescript-mail-archiver](https://github.com/camlin/applescript-mail-archiver/blob/master/rule-screenshot2.png)
