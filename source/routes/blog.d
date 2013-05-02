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
import std.string : strip;
import std.array : split, array;

void renderArticle(HttpServerRequest req, HttpServerResponse res, Article article)
{
    res.renderCompat!("blog.dt", HttpServerRequest, "req", Article, "article")(req, article);
}

void redirectArticle(HttpServerRequest req, HttpServerResponse res, Article article)
{
    if("tag" in req.params) res.redirect("/tag/" ~ req.params["tag"] ~ "/" ~ article.slug);
    else res.redirect("/" ~ article.slug);
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
    renderArticle(req, res, getLatestArticleByFilter("tags", req.params["tag"]));
}

void edit(HttpServerRequest req, HttpServerResponse res)
{
    renderArticle(req, res, getArticle(req.params["slug"]));
}

void next(HttpServerRequest req, HttpServerResponse res)
{
    redirectArticle(req, res, getNextArticle(req.params["slug"], req.params.get("tag", "")));
}

void prev(HttpServerRequest req, HttpServerResponse res)
{
    redirectArticle(req, res, getPreviousArticle(req.params["slug"], req.params.get("tag", "")));
}

void createForm(HttpServerRequest req, HttpServerResponse res)
{
    res.renderCompat!("create.dt", HttpServerRequest, "req")(req);
}

void create(HttpServerRequest req, HttpServerResponse res)
{
    bool published = true;
    bool commentable = true;
    logInfo(to!string(req.query.length));
    string author = req.form["author"];
    string title = req.form["title"];
    string slug = makeSlugFromHeader(title);
    string[] tags = req.form["tags"].split(",").map!(a => strip(a))().array();
    string text = req.form["text"];

    Article article = Article(BsonObjectID.generate(), published, commentable, author, dlirium.data.Date(Clock.currTime()), title, slug, tags, text, []);

    insertArticle(article);

    redirectArticle(req, res, article);
}
/+
void save(HttpServerRequest req, HttpServerResponse res)
{
	if(req.params["year"] !is null
		&& req.params["month"] !is null
		&& req.params["day"] !is null
		&& req.params["url"] !is null)
	{
		res.redirect(dlirium.conf.blogPrefix ~ "/" 
					 ~ req.params["year"] ~ "/"
					 ~ req.params["month"] ~ "/"
					 ~ req.params["day"] ~ "/"
					 ~ req.params["url"], 302);
	}
	else
	{
		res.redirect(dlirium.conf.blogPrefix ~ "/", 302);
	}
}+/
