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
    router.get(dlirium.conf.blogPrefix, &routes.blog.index)
          .get("/", staticRedirect(dlirium.conf.blogPrefix))
          
          .any("/create", &routes.user.checkLogin)
          .get("/create", &routes.blog.articleForm)
          
          .any("/save", &routes.user.checkLogin)
          .post("/save", &routes.blog.save)
          
          .get("/login/:provider", &routes.user.login)
          .get("/auth/:provider", &routes.user.auth)
          
          .get("/logout", &routes.user.checkLogin)
          .get("/logout", &routes.user.logout)

          .get(dlirium.conf.blogPrefix ~ "/tag/:tag", &routes.blog.tag)
          .get(dlirium.conf.blogPrefix ~ "/tag/:tag/:slug", &routes.blog.show)
          .get(dlirium.conf.blogPrefix ~ "/tag/:tag/:slug/next", &routes.blog.next)
          .get(dlirium.conf.blogPrefix ~ "/tag/:tag/:slug/prev", &routes.blog.prev)
          
          .any(dlirium.conf.blogPrefix ~ "/tag/:tag/:slug/comment", &routes.user.checkLogin)
          .post(dlirium.conf.blogPrefix ~ "/tag/:tag/:slug/comment", &routes.blog.comment)
          
          .any(dlirium.conf.blogPrefix ~ "/tag/:tag/:slug/:cid/remove", &routes.user.checkLogin)
          .any(dlirium.conf.blogPrefix ~ "/tag/:tag/:slug/:cid/remove", &routes.user.authorized)
          .get(dlirium.conf.blogPrefix ~ "/tag/:tag/:slug/:cid/remove", &routes.blog.rmComment)
          
          .get(dlirium.conf.blogPrefix ~ "/:slug", &routes.blog.show)
          
          .any(dlirium.conf.blogPrefix ~ "/:slug/edit", &routes.user.checkLogin)
          .any(dlirium.conf.blogPrefix ~ "/:slug/edit", &routes.user.authorized)
          .get(dlirium.conf.blogPrefix ~ "/:slug/edit", &routes.blog.articleForm)

          .any(dlirium.conf.blogPrefix ~ "/:slug/save", &routes.user.checkLogin)
          .any(dlirium.conf.blogPrefix ~ "/:slug/save", &routes.user.authorized)
          .post(dlirium.conf.blogPrefix ~ "/:slug/save", &routes.blog.save)
          
          .any(dlirium.conf.blogPrefix ~ "/:slug/delete", &routes.user.checkLogin)
          .any(dlirium.conf.blogPrefix ~ "/:slug/delete", &routes.user.authorized)
          .get(dlirium.conf.blogPrefix ~ "/:slug/delete", &routes.blog.del)
          
          .get(dlirium.conf.blogPrefix ~ "/:slug/next", &routes.blog.next)
          .get(dlirium.conf.blogPrefix ~ "/:slug/prev", &routes.blog.prev)
          
          .any(dlirium.conf.blogPrefix ~ "/:slug/comment", &routes.user.checkLogin)
          .post(dlirium.conf.blogPrefix ~ "/:slug/comment", &routes.blog.comment)

          .any(dlirium.conf.blogPrefix ~ "/:slug/:cid/remove", &routes.user.checkLogin)
          .any(dlirium.conf.blogPrefix ~ "/:slug/:cid/remove", &routes.user.authorized)
          .get(dlirium.conf.blogPrefix ~ "/:slug/:cid/remove", &routes.blog.rmComment);
    /+
     + Public content routing
     +/
    router.get("*", serveStaticFiles("./public/"));

    listenHttp(settings, router);
}
