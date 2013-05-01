module routes.blog;

import vibe.core.log;
import vibe.http.server;

import dlirium.conf;
import dlirium.data;
/* import dlirium.parser; */
import dlirium.db;

import std.file;
import std.datetime;
import std.conv;
import std.array : split;

void renderArticle(HttpServerRequest req, HttpServerResponse res, Article article)
{
    res.renderCompat!("blog.dt", HttpServerRequest, "req", string, "title", Article, "article")(req, "d.lirium", article);
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
    renderArticle(req, res, getArticleByTag(req.params["tag"]));
}
/+
void create(HttpServerRequest req, HttpServerResponse res)
{
	res.writeBody("Create a blog entry");
}

void edit(HttpServerRequest req, HttpServerResponse res)
{
	res.writeBody("Edit a blog entry: " ~ req.params["year"] ~ ", " 
										   ~ req.params["month"] ~ ", "
										   ~ req.params["day"] ~ ", "
										   ~ req.params["url"]);
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
