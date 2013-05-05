module dlirium.conf;

import dlirium.data;

/+
 + Server settings
 +/
public ushort portNo = 3838;
/* public string host = "localhost" ~ (portNo!=80?":"~to!string(portNo):""); */
public string host = "localhost:3838";

/+
 + Blog settings
 +/

public string pageTitle = "d.lirium";
public string blogPrefix = "";


public string slugPath(string path, string[string] params, string slug)
{
    string p = path;
    if(path[$-1] == '/') { p = p[0..$-1]; }
    if("slug" !in params) { p ~= "/" ~ slug; }
    return p;
}

public OAuth2Provider[string] authProviders;

static this()
{
    authProviders = [ 
        "github": 
            OAuth2Provider("github",
                    "client_id", 
                    "client_secret", 
                    "https://github.com/login/oauth/authorize", 
                    "https://github.com/login/oauth/access_token", 
                    "https://api.github.com/user", 
                    "user:email"), 
        "google": // Not yet working
            OAuth2Provider("google",
                "client_id",
                "client_secret",
                "https://accounts.google.com/o/oauth2/auth",
                "https://accounts.google.com/o/oauth2/token",
                "https://www.googleapis.com/oauth2/v2/userinfo",
                "https%3A%2F%2Fwww.googleapis.com%2Fauth%2Fuserinfo.email+https%3A%2F%2Fwww.googleapis.com%2Fauth%2Fuserinfo.profile",
                ["Authorization": "OAuth "])
    ];
}
