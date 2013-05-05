module routes.user;

import vibe.core.log;
import vibe.http.server;
import vibe.data.json;
import vibe.http.session;
import dlirium.conf;
import dlirium.auth.oauth2;
import dlirium.db;
import dlirium.data;

void auth(HttpServerRequest req, HttpServerResponse res)
{
    string token = authProviders[req.params["provider"]].requestAuthToken(req.query["code"]);
    Json info = authProviders[req.params["provider"]].requestUserInfo(token);
    auto session = res.startSession();
    session["token"] = token;
    session["name"] = info["login"].get!string;
    res.redirect("/");
}

void login(HttpServerRequest req, HttpServerResponse res)
{
    res.redirect(authProviders[req.params["provider"]].authLink);
}

void logout(HttpServerRequest req, HttpServerResponse res)
{
    res.terminateSession();
    res.redirect("/");
}

void checkLogin(HttpServerRequest req, HttpServerResponse res)
{
    if(req.session is null)
        res.redirect("/");
}

void authorized(HttpServerRequest req, HttpServerResponse res)
{
    if("slug" in req.params)
    {
        string slug = req.params["slug"];
        string user = req.session["name"];
        if("cid" in req.params)
        {
            Comment comment = getComment(slug, req.params["cid"]);
            logInfo(comment.author);
            logInfo(comment.id.toString());
            logInfo(user);
            if(comment.author != user && getArticle(slug).author != user)
                res.redirect("/");
        }
        else
        {
            Article article = getArticle(slug);
            if(article.author != user)
                res.redirect("/");
        }
    }
}

void register(string token, string provider, Json info)
{
    addUser(token, provider, info["login"].get!string, info["email"].get!string);
}
