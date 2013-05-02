module routes.blog;

import vibe.core.log;
import vibe.http.server;

import dlirium.conf;
import dlirium.data;
import dlirium.db;

import std.file;
import std.datetime;
import std.conv;
import std.array : split;

void renderArticle(HttpServerRequest req, HttpServerResponse res, Article article)
{
    res.renderCompat!("blog.dt", HttpServerRequest, "req", Article, "article")(req, article);
}

void redirectArticle(HttpServerResponse res, Article article)
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
    res.redirectArticle(getNextArticle(req.params["slug"], req.params.get("tag", "")));
}

void prev(HttpServerRequest req, HttpServerResponse res)
{
    res.redirectArticle(getPreviousArticle(req.params["slug"], req.params.get("tag", "")));
}
/+
void create(HttpServerRequest req, HttpServerResponse res)
{
	res.writeBody("Create a blog entry");
}

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
