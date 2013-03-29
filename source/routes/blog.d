module routes.blog;

import vibe.core.log;
import vibe.http.server;

import dlirium.conf;
import dlirium.data;
import dlirium.parser;

import std.file;
import std.datetime;
import std.conv;
import std.array : split;

void index(HttpServerRequest req, HttpServerResponse res)
{
	string path = "articles/";
	
	int year = Clock.currTime().year;
	string yrString = ("0000" ~ to!string(year))[$-4..$];
	while(!isDir(path ~ yrString)) { --year; yrString = ("0000" ~ to!string(year))[$-4..$]; }
	path ~= yrString ~ "/";

	int month = Clock.currTime().month;
	string mthString = ("00" ~ to!string(month))[$-2..$];
	while(!isDir(path ~ mthString)) { --month; mthString = ("00" ~ to!string(month))[$-2..$]; }
	path ~= mthString ~ "/";
	
	int day = Clock.currTime().day;
	string dayString = ("00" ~ to!string(day))[$-2..$];
	while(!isDir(path ~ dayString)) { --day; dayString = ("00" ~ to!string(day))[$-2..$]; }
	path ~= dayString;

	string fileName;

	foreach(file; dirEntries(path, SpanMode.shallow, false))
	{
		fileName = file[path.length+1..$-3]; // Remove .md
	}

	req.params["year"] = yrString;
	req.params["month"] = mthString;
	req.params["day"] = dayString;
	req.params["url"] = fileName;

	show(req, res);
}

void tag(HttpServerRequest req, HttpServerResponse res)
{
    string tag = req.path.split("/")[2];
    string path = "articles/tags/"~tag;
    string fileName;
    foreach(file; dirEntries(path, SpanMode.shallow, true))
    {
        fileName = file;
    }

    string relLink = fileName.readLink();

    req.params["year"] = relLink[6..10];
    req.params["month"] = relLink[11..13];
    req.params["day"] = relLink[14..16];
    req.params["url"] = relLink[17..$-3];
    
    show(req, res);
}

void show(HttpServerRequest req, HttpServerResponse res)
{
	Article article = parseArticleFile("articles/" 
		~ req.params["year"] ~ "/" ~ req.params["month"] ~ "/" 
		~ req.params["day"] ~ "/" ~ req.params["url"] ~ ".md");
	res.renderCompat!("blog.dt", HttpServerRequest, "req", string, "title", Article, "article")(req, "d.lirium", article);
}

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
}
