# PostRawStockResponseToiService.ps1
This script will create a new stock response in iService by posting the raw html to the api, rather than using the iService editor. This is useful if you want to create a stock response that contains html that is not supported by the editor.

## To use this script
1. Edit the parameters at the top of the script
2. Edit the stockresponse.html file to contain the html you want to post
3. Run the script in powershell
4. When prompted, enter your iService user password
5. The script will create the stock response and display the stock response ID

## Parameters to edit in PostRawStockResponseToiService.ps1
* tenant - the url of your iService tenant
* login - the user to log in as
* segmentid - the segment id to create the stock response in
* name - the name of the stock response
* description - the description of the stock response
* stockResponseBodyFilename - the name of the file containing the stock response's html