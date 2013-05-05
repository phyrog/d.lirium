module routes.user;

import std.stdio;
import vibe.http.server;
import vibe.data.json;
import vibe.http.session;
import dlirium.conf;
import dlirium.auth.oauth2;

void auth(HttpServerRequest req, HttpServerResponse res)
{
    string token = authProviders[req.params["provider"]].requestAuthToken(req.query["code"]);
    Json info = authProviders[req.params["provider"]].requestUserInfo(token);
    auto session = res.startSession();
    session["token"] = token;
    res.redirect("/");
}

void login(HttpServerRequest req, HttpServerResponse res)
{
    res.redirect(authProviders[req.params["provider"]].authLink);
}

void register(string token, Json info)
{
    
}
