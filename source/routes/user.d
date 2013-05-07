module routes.user;

import vibe.core.log;
import vibe.http.server;
import vibe.data.json;
import vibe.http.session;
import dlirium.conf;
import dlirium.auth.oauth2;
import dlirium.db;
import dlirium.data;
import routes.blog : redirectArticle;

import std.array;

void auth(HttpServerRequest req, HttpServerResponse res)
{
    string token = authProviders[req.params["provider"]].requestAuthToken(req.query["code"]);
    Json info = authProviders[req.params["provider"]].requestUserInfo(token);
    auto session = res.startSession();
    session["token"] = token;
    session["name"] = info["login"].get!string ~ "@" ~ req.params["provider"];
    if("ref" in req.query)
        res.redirect(req.query["ref"]);
    else
        res.redirect("/");
}

void login(HttpServerRequest req, HttpServerResponse res)
{
    res.redirect(authProviders[req.params["provider"]].authLink(req.query.get("ref", "")));
}

void logout(HttpServerRequest req, HttpServerResponse res)
{
    res.terminateSession();
    res.redirect(req.query.get("ref", "/"));
}

void checkLogin(HttpServerRequest req, HttpServerResponse res)
{
    if(req.session is null)
    {
        if("slug" in req.params) redirectArticle(req, res, req.params["slug"]);
        else res.redirect("/");
    }
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
                redirectArticle(req, res, slug);
        }
        else
        {
            Article article = getArticle(slug);
            if(article.author != user)
                redirectArticle(req, res, slug);
        }
    }
    else
    {
        res.redirect("/");
    }
}

void register(string token, string provider, Json info)
{
    addUser(token, provider, info["login"].get!string, info["email"].get!string);
}

void show(HttpServerRequest req, HttpServerResponse res)
{
    string name = req.params.get("user", "");
    Comment[] comments = getCommentsByUser(name);
    logInfo(to!string(comments.length));
    res.renderCompat!("user.dt", HttpServerRequest, "req", Comment[], "comments")(req, comments);
}
