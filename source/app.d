import vibe.d;

import dlirium.conf;
import routes.blog;
import routes.error;
import routes.user;

shared static this()
{ 
	auto settings = new HttpServerSettings;
	settings.errorPageHandler = toDelegate(&routes.error.handler);
	settings.port = dlirium.conf.portNo;

	auto router = new UrlRouter;

	/+
	 + Blog routing configuration
	 +/
	router.get(dlirium.conf.blogPrefix ~ "/", &routes.blog.index)
		  .get(dlirium.conf.blogPrefix ~ "/:year/:month/:day/:url", &routes.blog.show)
		  .get(dlirium.conf.blogPrefix ~ "/:year/:month/:day/:url/edit", &routes.blog.edit)
		  .post(dlirium.conf.blogPrefix ~ "/:year/:month/:day/:url/save", &routes.blog.save)
		  .get(dlirium.conf.blogPrefix ~ "/new", &routes.blog.create)
		  .post(dlirium.conf.blogPrefix ~ "/new/save", &routes.blog.save);
	
	/+
	 + Public content routing
	 +/
	router.get("*", serveStaticFiles("./public/"));

	listenHttp(settings, router);
}
