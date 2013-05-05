module routes.blog;

import vibe.core.log;
import vibe.http.server;
import vibe.data.bson;

import dlirium.conf;
import dlirium.data;
import dlirium.db;

import std.file;
import std.datetime;
import std.conv;
import std.string : strip, translate;
import std.array : split, array;

void renderArticle(HttpServerRequest req, HttpServerResponse res, Article article)
{
    res.renderCompat!("blog.dt", HttpServerRequest, "req", Article, "article")(req, article);
}

void redirectArticle(HttpServerRequest req, HttpServerResponse res, Article article)
{
    if("tag" in req.params) res.redirect(dlirium.conf.blogPrefix ~ "/tag/" ~ req.params["tag"] ~ "/" ~ article.slug);
    else res.redirect(dlirium.conf.blogPrefix ~ "/" ~ article.slug);
}

void redirectArticle(HttpServerRequest req, HttpServerResponse res, string slug)
{
    if("tag" in req.params) res.redirect(dlirium.conf.blogPrefix ~ "/tag/" ~ req.params["tag"] ~ "/" ~ slug);
    else res.redirect(dlirium.conf.blogPrefix ~ "/" ~ slug);
}

void index(HttpServerRequest req, HttpServerResponse res)
{
    renderArticle(req, res, getArticle());
}

void show(HttpServerRequest req, HttpServerResponse res)
{
    renderArticle(req, res, getArticle(req.params["slug"]));
}

void tag(HttpServerRequest req, HttpServerResponse res)
{
    Article article = getLatestArticleByFilter("tags", req.params["tag"].translate([' ': '+']));
    if(article != Article()) renderArticle(req, res, article);
    else res.redirect("/");
}

void next(HttpServerRequest req, HttpServerResponse res)
{
    redirectArticle(req, res, getNextArticle(req.params["slug"], req.params.get("tag", "")));
}

void prev(HttpServerRequest req, HttpServerResponse res)
{
    redirectArticle(req, res, getPreviousArticle(req.params["slug"], req.params.get("tag", "")));
}

void articleForm(HttpServerRequest req, HttpServerResponse res)
{
    res.renderCompat!("create.dt", HttpServerRequest, "req", Article, "article")(req, ("slug" in req.params?getArticle(req.params["slug"]):Article()));
}

void save(HttpServerRequest req, HttpServerResponse res)
{
    bool published = cast(bool)("published" in req.form);
    bool commentable = cast(bool)("commentable" in req.form);
    string author = req.session["name"];
    string title = req.form["title"];
    string slug = makeSlugFromHeader(title);
    string[] tags = req.form["tags"].split(",").map!(a => strip(a))().array();
    string text = req.form["text"];

    Article article;

    if("slug" in req.params) 
    {
        article = getArticle(req.params["slug"]);
        article.published = published;
        article.commentable = commentable;
        article.author = author;
        article.title = title;
        article.slug = slug;
        article.tags = tags;
        article._text = text;
        saveArticle(article);
    }
    else
    {
        article = Article(BsonObjectID.generate(), 
                          published, 
                          commentable, 
                          author, 
                          dlirium.data.Date(Clock.currTime()), 
                          title, 
                          slug, 
                          tags, 
                          text, 
                          []);
        insertArticle(article);
    }

    redirectArticle(req, res, article);
}

void del(HttpServerRequest req, HttpServerResponse res)
{
    removeArticle(req.params["slug"]);
    res.redirect("/");
}

void comment(HttpServerRequest req, HttpServerResponse res)
{
    if("text" in req.form && req.form["text"] != "")
    {
        Comment com = Comment(BsonObjectID.generate(), req.session["name"], dlirium.data.Date(Clock.currTime()), req.form["text"]);
        addComment(req.params["slug"], com);
    }
    redirectArticle(req, res, req.params["slug"]);
}

void rmComment(HttpServerRequest req, HttpServerResponse res)
{
    removeComment(req.params["slug"], req.params["cid"]);
    redirectArticle(req, res, req.params["slug"]);
}
