#!/usr/bin/expect -f

# Set a long timeout (in seconds) because extracting Puppet
# and setting up the DB can take a while between questions.
set timeout 600

# Define your master password variable
set password "Manager123"

# Start the interactive installer script
spawn sh ./psft-dpk-setup.sh

# 1. Non-root user question
expect "Would you like to proceed with the setup as a non-root user? \\\[y/n\\\]:"
send "y\r"

# 2. Base Directory path
expect "Enter the full path for the PeopleSoft Base Directory:"
send "/u02\r"

expect "Are you happy with your answer? \\\[Y|n|q\\\]:"
send "y\r"

# 3. Puppet Space allocation verification
expect "with at least 10.0GB space"
send "\r"; # Presses enter to accept default or proceed

expect "Are you happy with your answer? \\\[Y|n|q\\\]:"
send "Y\r"

# 4. Installation type (PUM vs Fresh)
expect "Enter the PeopleSoft installation \\\[PUM or FRESH\\\] type \\\[PUM\\\]:"
send "PUM\r"

expect "Are you happy with your answer? \\\[y|n\\\]:"
send "y\r"

# 5. DB Name (Press Enter to accept default HR92U054)
expect "numbers and is no more than 8 characters in length"
send "\r"

# 6. DB Listener Port (Press Enter to accept default 1521)
expect "Enter the PeopleSoft database listener port \\\[1521\\\]:"
send "\r"

# 7.1 Database Admin (SYS/SYSTEM) Password
expect "requirements for your database platform"
send "$password\r"

# 7. Database Admin (SYS/SYSTEM) Password
expect "Re-Enter the database admin users password:"
send "$password\r"

# 8. Connect ID (Press Enter to accept default 'people')
expect "contains only alphanumeric characters \\\[people\\\]:"
send "\r"

# 9. Connect ID Password
expect "requirements for your database platform"
send "$password\r"

# 9.1 Connect ID Password
expect "Re-Enter the PeopleSoft Connect ID password"
send "$password\r"

# 10.2 Access ID (SYSADM) Password
expect "requirements for your database platform"
send "$password\r"

# 10.2 Access ID (SYSADM) Password
expect "Re-Enter the PeopleSoft Access ID password"
send "$password\r"

# 11. Operator ID (PS) Password
expect "You may include these special characters"
send "$password\r"

# 11.2 Operator ID (PS) Password
expect "Re-Enter the PeopleSoft Operator ID password"
send "$password\r"

# 12. Domain connection passwor Password
expect "You may include these special characters"
send "$password\r"

# 13.2 Operator ID (PS) Password
expect "Re-Enter the Application Server Domain connection password"
send "$password\r"

# 14. Operator ID (PS) Password
expect "contain one number or one of these special characters"
send "$password\r"

# 14.2 Operator ID (PS) Password
expect "Re-Enter the WebLogic Server Admin user password"
send "$password\r"

# 15. PTWEBSERVER) Password
expect "You may include these special characters"
send "$password\r"

# 15.2 (PTWEBSERVER) Password
expect "Re-Enter the PeopleSoft Web Profile user password"
send "$password\r"

# 15. Integration Gateway User Name (Press Enter for 'administrator')
expect "Enter the PeopleSoft Integration Gateway user \\\[administrator\\\]:"
send "\r"

# 16.1 Gateway User Password
expect "You may include these special characters"
send "$password\r"

# 16.2 Gateway User Password
expect "Re-Enter the PeopleSoft Integration Gateway user password:"
send "$password\r"

# 17. Integration Gateway Keystore Password
expect "You may include these special characters"
send "$password\r"

# 17.2 Integration Gateway Keystore Password
expect "Re-Enter the PeopleSoft Integration Gateway Keystore password"
send "$password\r"


# 18. Confirmation of answers
expect "Are you happy with your answers? \\\[y|n\\\]:"
send "y\r"

# 19. Final default initialization confirmation
expect "Do you want to continue with the default initialization process? \\\[y|n\\\]:"
send "y\r"

# Allow the script to stay open so you can see Puppet execution logs live
interact