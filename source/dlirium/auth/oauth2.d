module dlirium.auth.oauth2;

import vibe.core.log;
import vibe.http.client;
import vibe.data.json;
import std.array;
import std.algorithm;
import vibe.stream.operations;
import dlirium.data;
import std.conv;

string requestAuthToken(OAuth2Provider provider, string code)
{
    auto res = requestHTTP(provider.authTokenRequestURL, (scope req) {
        req.method = httpMethodFromString("POST");
        req.headers["Content-Type"] = "application/x-www-form-urlencoded";
        string b = "client_id=" ~ provider.client_id ~ "&client_secret=" ~ provider.client_secret ~ "&code=" ~ code;
        logInfo(b);
        req.writeBody(cast(ubyte[])b);

        logInfo(provider.authTokenRequestURL);
    });

    string ret = res.bodyReader.readAllUTF8();

    logInfo(ret);

    string auth_token = ret.split("&").filter!(a => a[0.."access_token=".length] == "access_token=")().front.split("=").array()[1];

    return auth_token;
}

Json requestUserInfo(OAuth2Provider provider, string token)
{
    logInfo(provider.userDataRequestURL);
    return requestHTTP(provider.userDataRequestURL ~ "?access_token=" ~ token, (scope req) {
        foreach(k, v; provider.headers)
        {
            if(k == "Authorization") v ~= token;
            req.headers[k] = v;
        }
    }).readJson();
}
