-- Email Auto Archiving AppleScript for use in an Apple Mail Rule.
-- Copyright (c) 2019 Camlin (Gilles)
-- This software is provided under the terms of the GPL v3 or later.
-- Use entirely at your own risk. We accept no liability. If you are not happy with that - don't use it.

-- Name of the mailbox that will be used to store the emails from the inbox
property pInboxArchiveName : "Archived"

-- Name of the mailbox that will be used to store the emails from the sent mailbox
property pSentArchiveName : "ArchivedSent"

-- Delay in days in which emails will be left in the inbox before before being archived
property pInboxArchiveDelay : 90

-- Delay in days in which emails will be left in the sent mailbox before before being archived
property pSentArchiveDelay : 90

using terms from application "Mail"
	on perform mail action with messages _messages
		-- This is executed when Mail runs the rule.
		my archiveMessages()
	end perform mail action with messages
end using terms from

on logToConsole(_message)
	set _logMessage to "[Email Archiving] " & _message
	do shell script "/usr/bin/logger -s " & _logMessage's quoted form
end logToConsole

on archiveMessages()
	try
		tell application "Mail"
			
			-- First archive the inbox...
			my logToConsole("Started to archive old inbox emails")
			set _archiveMailbox to my findMailbox(pInboxArchiveName)
			if (_archiveMailbox = null) then
				my logToConsole("Can't find the archive mailbox: " & pInboxArchiveName)
			else
				my archiveMessagesFromMailbox(inbox, _archiveMailbox, pInboxArchiveDelay)
				my logToConsole("Done archiving old inbox emails")
			end if
			
			-- Then archive the sent mailbox...
			my logToConsole("Started to archive old sent mailbox emails")
			set _archiveMailbox to my findMailbox(pSentArchiveName)
			if (_archiveMailbox = null) then
				my logToConsole("Can't find the archive mailbox: " & pSentArchiveName)
			else
				my archiveMessagesFromMailbox(sent mailbox, _archiveMailbox, pSentArchiveDelay)
				my logToConsole("Done archiving old sent mailbox email")
			end if
			
		end tell
	on error _errorMessage
		my logToConsole("Error trying to archive emails: " & _errorMessage)
	end try
end archiveMessages

-- _fromMailbox The Mailbox (INBOX, Sent, etc) from which we will remove the messages to archive them
-- _archiveMailbox The mailbox where the selected emails will be archived.
-- _days How many days the emails must be old before they can be archived.
on archiveMessagesFromMailbox(_fromMailbox, _archiveMailbox, _days)
	try
		tell application "Mail"
			-- Number of seconds an email should stay in the inbox
			-- before being moved to the Archive box.
			
			set secondsInInbox to 60 * 60 * 24 * _days
			
			set dateToday to current date
			set archivedCount to 0
			
			-- The main inboxes (like inbox) can contain multiple inboxes themselves like
			-- say your icloud and main IMAP INBOX mailboxes.
			-- And the dates could interleave, thus causing messages not to be archived (as
			-- the overall virtual mailbox presents them one mailbox after another).
			-- So, if we want the date check to work correctly, we need to process each
			-- of these mailboxes independently from one another.
			--
			-- Hence this repeat loop...
			--
			repeat with _mailbox in mailboxes of _fromMailbox
				
				set msgIdx to (get count of messages in _mailbox)
				repeat while msgIdx ≥ 1
					set msg to message msgIdx of _mailbox
					set timeDifference to dateToday - (date received of msg)
					if timeDifference ≥ secondsInInbox then
						-- In the case of IMAP accounts, emails are just marked deleted and
						-- they take a while to disappear (depends of the Mail's app preferences)
						-- So we need to check this flag first...
						if (deleted status of msg is false) then
							-- archive the email by simply changing its ownership
							set mailbox of msg to _archiveMailbox
							set archivedCount to archivedCount + 1
						end if
					else
						-- AppleScript and Mail interactions are very slow (1 email per second!)
						-- And we want to script to be quick enough so that it does not affect Mail
						-- The emails are also ordered by arrival date so stop
						-- processing them as soon as we see the beginning of the ones
						-- that will be left unarchived for now...
						--
						-- This is especially important if you plan to archive emails only once they
						-- are several month olds. It means your mailbox could contain hundred of
						-- the non archived ones, thus causing a severe performance drain if we were to scan them all...
						exit repeat
					end if
					set msgIdx to msgIdx - 1
				end repeat
				
			end repeat
			
			my logToConsole("Number of messages archived: " & archivedCount)
			
		end tell
	on error _errorMessage
		my logToConsole("Error trying to archive emails: " & _errorMessage)
	end try
end archiveMessagesFromMailbox

on findMailbox(_name)
	tell application "Mail"
		try
			repeat with _mailbox in mailboxes
				set _mailboxName to name of _mailbox
				if (_mailboxName = _name) then
					return _mailbox
				end if
			end repeat
			return null
		on error _errorMessage
			my logToConsole("Error finding mailbox: " & _errorMessage)
		end try
	end tell
end findMailbox