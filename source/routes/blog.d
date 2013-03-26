module routes.blog;

import vibe.core.log;
import vibe.http.server;

import dlirium.conf;
import dlirium.data;

void index(HttpServerRequest req, HttpServerResponse res)
{
	req.params["year"] = "2013";
	req.params["month"] = "03";
	req.params["day"] = "20";
	req.params["url"] = "hallo";

	show(req, res);
}

void show(HttpServerRequest req, HttpServerResponse res)
{
	Article article = Article("id", 
							  "author", 
							  [
								"tag", 
								"nacht"
							  ], 
							  "title", 
							  "this is some [text](http://www.google.de)  with some _emphasize_ and **bold** <phyrog@gmail.com>. and some `void main(string[] args) {}` code
	pure @property void main(string[] args) {
		for(int i = 0; i < 10; i++)
			someCoolFunction();
	}
and some really cool
# Headings
with some awesome text
## Subheadings
between them
### Subsubheadings
> trololol
## Other Subheadings
to show off more of this awesome stuff
### and so on
and
> quotation  
> whoohoo");
	res.renderCompat!("blog.dt", HttpServerRequest, "req", string, "title", Article, "article")(req, "d.lirium", article);
	/* res.writeBody("Display a blog entry: " ~ req.params["year"] ~ ", " */ 
	/* 									   ~ req.params["month"] ~ ", " */
	/* 									   ~ req.params["day"] ~ ", " */
	/* 									   ~ req.params["url"]); */
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
