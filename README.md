# memex

A monorepo containing the constituent components of a software system that provides text entry and retrieval functionality via a web UI.

The repository contains the following components:


- memex-service

- memex-ui

- memex-data-service


Each of the components have their own README. The software system uses the underinformed design of program integration across its data access and user authentication functionalities, providing both data endpoints and authentication endpoints via the memex-service system component.

The repository also contains the following library:

- memex-spring-data

The system is not currently in use, but had previously been deployed to AWS on a Kubernetes single node cluster. The system was used to record personal journal entries.


To use the system locally:
 - Install system level dependencies
   - Java 17+ with JAVA_HOME set
   - Docker daemon (any version)
   - npm version 10 (packaged with Node version 22)
   - Mongo DB client, version 4+
 - Start the memex-service
   - Open a CLI and change directory to memex-service/docker, then run the [memex-service/docker/docker-compose-up.sh](memex-service/docker/docker-compose-up.sh) script.
   - Provide responses to the input prompts as follows:
     - Username and password: any value, but will be needed later
     - Encryption secrets: any value, including 0 character strings
     - Spring active profile: 'dev', without quotes
 - Start the memex-ui
   - Open a CLI and change directory to memex-ui/docker, then run the [memex-ui/docker/docker-compose-up.sh](memex-ui/docker/docker-compose-up.sh) script.
 - Access the app via web browser at http://localhost:4200
   - Click any button to prompt a login
   - Login using the user name and password that were entered when starting the memex-service

If the application starts but authentication fails with a 401 response, a possible cause of failure is the incorrect population of the Mongo userDetails collection. To resolve the issue, choose a new username aand password, use the `getEncryptedPassword` endpoint to encrypt the password, enter a new object in to the memex.userDetails Mongo collection where the object has a "password" value that is the encrypted password and an "_id" value that is the chosen username, then reattempt login using the chosen username and the password.

Using the app:
   - Select the plus sign to create a new entry.
   - Type in the dark grey text box to populate the entry. Please allow 5 to 10 seconds for the entry to automatically persist (see the 'timeInterval' variable in the `EntryScreenComponent` class of the memex-ui program).
   - Use the search function in the 'Retrieval' tab to retrieve entries, where no search string returns all entries, and where typos of up to 1 character are permitted (see the 'fuzziness' variable in the `RawTextESRestTemplate` class of the memex-spring-data library).
   - Delete entries by wiping out the content on the entry screen of the UI or by removing the entry from Mongo. Proper delete functionality is not implemented.

