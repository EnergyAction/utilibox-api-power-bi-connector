# utilibox-api-power-bi-connector
A simple custom Power bi connector that uses the authentication_token flow to connect to the Utilibox API

## Getting Started
1. Request a Utilibox API v1 `client id` and `client secret` from Energy Action.  Energy Action will issue you a client with scope `Company-Client-App`
2. Install Power BI Desktop
3. Install a standard Power BI gateway https://learn.microsoft.com/en-us/data-integration/gateway/service-gateway-install#download-and-install-a-standard-gateway https://go.microsoft.com/fwlink/?LinkId=2116849&clcid=0x409
4. Install VS Code
5. Install the Power Query SDK extension for VS Code: https://marketplace.visualstudio.com/items?itemName=PowerQuery.vscode-powerquery-sdk
6. Clone this repository
7. Open the root folder of the repository in VS Code
8. Enter the client id obtained in (1) into file `client_id.txt` and the client secret obtained in (1) into file `client_secret.txt`
9. Run Set Credential function - for it to succeed you'll need to sign in with your UB username and password.  The console should show something like this when you initiate this:
```
tools\PQTest.exe set-credential
				--extension "c:\Users\clint.irving\source\repos\UtiliboxApiV1PowerBiConnector\bin\AnyCPU\Debug\UtiliboxApiV1PowerBiConnector.mez"
				--queryFile "c:\Users\clint.irving\source\repos\UtiliboxApiV1PowerBiConnector\UtiliboxApiV1PowerBiConnector.query.pq"
				--prettyPrint
				-ak "OAuth"
				--interactive
```
it should then launch a login window where you can enter your username and password (as you would to access Utilibox), and your MFA code.  If it succeeds, the response in console should show something like:
```
[Info]	CreateAuthState {
    "Details": {
        "Kind": "UtiliboxApiV1PowerBiConnector",
        "Path": "UtiliboxApiV1PowerBiConnector",
        "NormalizedPath": "UtiliboxApiV1PowerBiConnector",
        "IsDefaultForKind": false
    },
    "Message": "Successfully set credential",
    "Status": "Success"
}
```
10. Run the TestConnection function to build and test the PowerBI connector .mez file.  The console should show something like this when you initiate it:
```
tools\PQTest.exe test-connection
				--extension "c:\Users\clint.irving\source\repos\UtiliboxApiV1PowerBiConnector\bin\AnyCPU\Debug\UtiliboxApiV1PowerBiConnector.mez"
				--queryFile "c:\Users\clint.irving\source\repos\UtiliboxApiV1PowerBiConnector\UtiliboxApiV1PowerBiConnector.query.pq"
				--prettyPrint
[Info]	TestConnection result {
    "Details": "UtiliboxApiV1PowerBiConnector.Contents(null)",
    "Message": "TestConnection succeeded",
    "Status": "Success"
}
```
12. Copy the PowerBI connector mez file from `<repository-root>/bin/AnyCPU/Debug/UtiliboxApiV1PowerBiConnector.mez` to your local Power BI Desktop "Custom Connectors" directory (usually `<user>/Documents/Power BI Desktop/Custom Connectors`)
13. Give the gateway service account (by default `NT SERVICE\PBIEgwService`)read permissions on the local Power BI Desktop "Custom Connectors" directory (usually `<user>/Documents/Power BI Desktop/Custom Connectors`).
14. Add the custom data connector to the on-premises data gateway by pointing it to load custom data connectors from the folder where your connector is located.
15. Launch Power BI
16. Adjust the data extension security settings to allow custom data connectors.  In Power BI Desktop, select `File > Options and settings > Options > Security`. Under `Data Extensions`, select `(Not Recommended) Allow any extension to load without validation or warning`. Select `OK`, and then restart Power BI Desktop.
17. In Power BI - create a blank report > "Get data from another source" in the "Get Data" dialog that pops up, search for "Utilibox" and select `UtiliboxApiV1PowerBiConnector (Beta) (Custom)` > click `Continue`
18. In the fx box, replace null with the an example url of the UB V1 API endpoint to test `= UtiliboxApiV1PowerBiConnector.Contents(null)` => `= UtiliboxApiV1PowerBiConnector.Contents("https://eaxapi.utilibox.tech/v1/organizations")`
