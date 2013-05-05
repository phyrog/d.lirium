import vibe.d;

import dlirium.conf;
import routes.blog;
import routes.error;
import routes.user;

shared static this()
{ 
    auto settings = new HttpServerSettings;
    settings.sessionStore = new MemorySessionStore;
    settings.errorPageHandler = toDelegate(&routes.error.handler);
    settings.port = dlirium.conf.portNo;

    auto router = new UrlRouter;

    /+
     + Blog routing configuration
     +/
    router.get(dlirium.conf.blogPrefix ~ "/", &routes.blog.index)

          .get(dlirium.conf.blogPrefix ~ "/create", &routes.blog.articleForm)
          .post(dlirium.conf.blogPrefix ~ "/save", &routes.blog.save)
          .get(dlirium.conf.blogPrefix ~ "/login/:provider", &routes.user.login)
          .get(dlirium.conf.blogPrefix ~ "/auth/:provider", &routes.user.auth)

          .get(dlirium.conf.blogPrefix ~ "/tag/:tag", &routes.blog.tag)
          .get(dlirium.conf.blogPrefix ~ "/tag/:tag/:slug", &routes.blog.show)
          .get(dlirium.conf.blogPrefix ~ "/tag/:tag/:slug/next", &routes.blog.next)
          .get(dlirium.conf.blogPrefix ~ "/tag/:tag/:slug/prev", &routes.blog.prev)
          .post(dlirium.conf.blogPrefix ~ "/tag/:tag/:slug/comment", &routes.blog.comment)
          .get(dlirium.conf.blogPrefix ~ "/tag/:tag/:slug/:cid/remove", &routes.blog.rmComment)
          
          .get(dlirium.conf.blogPrefix ~ "/:slug", &routes.blog.show)
          .get(dlirium.conf.blogPrefix ~ "/:slug/edit", &routes.blog.articleForm)
          .get(dlirium.conf.blogPrefix ~ "/:slug/next", &routes.blog.next)
          .get(dlirium.conf.blogPrefix ~ "/:slug/prev", &routes.blog.prev)
          .post(dlirium.conf.blogPrefix ~ "/:slug/comment", &routes.blog.comment)
          .get(dlirium.conf.blogPrefix ~ "/:slug/:cid/remove", &routes.blog.rmComment);
    /+
     + Public content routing
     +/
    router.get("*", serveStaticFiles("./public/"));

    listenHttp(settings, router);
}
