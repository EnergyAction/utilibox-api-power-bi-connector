// This file contains the Data Connector logic for the Utilibox Power BI Connector
// Note that prior to build you must first enter your client id and client secret respectively into client_id.txt and client_secret.txt
// Then run the Set credential function
// And finally run the "Run TestConnection" function to build the Power BI connector .mez file and test the connection works.
section UtiliboxApiV1PowerBiConnector;

// OAuth2 values
client_id = Text.FromBinary(Extension.Contents("client_id.txt"));
client_secret = Text.FromBinary(Extension.Contents("client_secret.txt"));
redirect_uri = "https://oauth.powerbi.com/views/oauthredirect.html";
token_uri = "https://identityserver.sts.identity.utilibox.tech/connect/token";
authorize_uri = "https://identityserver.sts.identity.utilibox.tech/connect/authorize";
logout_uri = "https://identityserver.sts.identity.utilibox.tech/connect/endsession";

// Login modal window dimensions
windowWidth = 720;
windowHeight = 1024;

// OAuth2 scope
scope_prefix = "";
scopes = {
    "Company-Client-App",
    "openid"
};

[DataSource.Kind="UtiliboxApiV1PowerBiConnector", Publish="UtiliboxApiV1PowerBiConnector.Publish"]
shared UtiliboxApiV1PowerBiConnector.Contents = (optional url as text) =>
    let
        response = if (url <> null) then Json.Document(Web.Contents(url)) else "No API URL provided.  Please enter an API URL and try again."
    in
        response;


// Data Source Kind description
UtiliboxApiV1PowerBiConnector= [
    TestConnection = (dataSourcePath) => { "UtiliboxApiV1PowerBiConnector.Contents", null },
    Authentication = [
        OAuth = [
            StartLogin=StartLogin,
            FinishLogin=FinishLogin,
            Refresh=Refresh,
            Logout=Logout
        ]
    ],
    Label = Extension.LoadString("DataSourceLabel")
];

// Data Source UI publishing description
UtiliboxApiV1PowerBiConnector.Publish = [
    Beta = true,
    Category = "Other",
    ButtonText = { Extension.LoadString("ButtonTitle"), Extension.LoadString("ButtonHelp") },
    LearnMoreUrl = "https://powerbi.microsoft.com/",
    SourceImage = UtiliboxApiV1PowerBiConnector.Icons,
    SourceTypeImage = UtiliboxApiV1PowerBiConnector.Icons
];

// Helper functions for OAuth2: StartLogin, FinishLogin, Refresh, Logout
StartLogin = (resourceUrl, state, display) =>
    let
        authorizeUrl = authorize_uri & "?" & Uri.BuildQueryString([
            response_type = "code",
            client_id = client_id,
            redirect_uri = redirect_uri,
            state = state,
            scope = GetScopeString(scopes, scope_prefix)
        ])
    in
        [
            LoginUri = authorizeUrl,
            CallbackUri = redirect_uri,
            WindowHeight = 720,
            WindowWidth = 1024,
            Context = null
        ];

FinishLogin = (context, callbackUri, state) =>
    let
        // parse the full callbackUri, and extract the Query string
        parts = Uri.Parts(callbackUri)[Query],
        // if the query string contains an "error" field, raise an error
        // otherwise call TokenMethod to exchange our code for an access_token
        result = if (Record.HasFields(parts, {"error", "error_description"})) then 
                    error Error.Record(parts[error], parts[error_description], parts)
                 else
                    TokenMethod("authorization_code", "code", parts[code])
    in
        result;

Refresh = (resourceUrl, refresh_token) => TokenMethod("refresh_token", "refresh_token", refresh_token);

Logout = (token) => logout_uri;

TokenMethod = (grantType, tokenField, code) =>
    let
        queryString = [
            grant_type = "authorization_code",
            redirect_uri = redirect_uri,
            client_id = client_id,
            client_secret = client_secret
        ],
        queryWithCode = Record.AddField(queryString, tokenField, code),

        tokenResponse = Web.Contents(token_uri, [
            Content = Text.ToBinary(Uri.BuildQueryString(queryWithCode)),
            Headers = [
                #"Content-type" = "application/x-www-form-urlencoded",
                #"Accept" = "application/json"
            ],
            ManualStatusHandling = {400} 
        ]),
        body = Json.Document(tokenResponse),
        result = if (Record.HasFields(body, {"error", "error_description"})) then 
                    error Error.Record(body[error], body[error_description], body)
                 else
                    body
    in
        result;

Value.IfNull = (a, b) => if a <> null then a else b;

GetScopeString = (scopes as list, optional scopePrefix as text) as text =>
    let
        prefix = Value.IfNull(scopePrefix, ""),
        addPrefix = List.Transform(scopes, each prefix & _),
        asText = Text.Combine(addPrefix, " ")
    in
        asText;
        

UtiliboxApiV1PowerBiConnector.Icons = [
    Icon16 = { Extension.Contents("UtiliboxApiV1PowerBiConnector16.png"), Extension.Contents("UtiliboxApiV1PowerBiConnector20.png"), Extension.Contents("UtiliboxApiV1PowerBiConnector24.png"), Extension.Contents("UtiliboxApiV1PowerBiConnector32.png") },
    Icon32 = { Extension.Contents("UtiliboxApiV1PowerBiConnector32.png"), Extension.Contents("UtiliboxApiV1PowerBiConnector40.png"), Extension.Contents("UtiliboxApiV1PowerBiConnector48.png"), Extension.Contents("UtiliboxApiV1PowerBiConnector64.png") }
];