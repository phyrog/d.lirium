module dlirium.db;

import vibe.core.log;

import vibe.db.mongo.mongo;
import vibe.data.bson;
import vibe.data.json;
import dlirium.data;
import std.algorithm;
import std.array;

private MongoClient     db_connection;
private MongoCollection col_articles;
private MongoCollection col_users;

shared static this()
{
    logInfo("Attempting db connection");
    db_connection = connectMongoDB("127.0.0.1");
    col_articles = db_connection.getCollection("dlirium.articles");
    col_users = db_connection.getCollection("dlirium.users");
    logInfo("Database connected");
}

public Article getArticle(BsonObjectID id)
{
    return Article.fromBson(col_articles.findOne(["_id": Bson(id)]));
}

public Article getArticle(string slug)
{
    return Article.fromBson(col_articles.findOne(["slug": Bson(slug)]));
}

public Article getArticle()
{
    Bson[string] query;
    Bson[string] q = ["query": Bson(query), "orderby" : Bson(["_id" : Bson(-1)]), "maxScan": Bson(1)];
    auto res = col_articles.find(q);
    if(!res.empty) return Article.fromBson(res.front);
    else return Article();
}

public Article getLatestArticleByFilter(string key, string value)
{
    Bson[string] query = [key: Bson(value)];
    Bson[string] q = ["query": Bson(query), "orderby" : Bson(["_id" : Bson(-1)]), "maxScan": Bson(1)];

    auto res = col_articles.find(q);
    if(!res.empty) return Article.fromBson(res.front);
    else return Article();
}

public Article getNextArticle(string slug, string tag = "")
{
    Article current = getArticle(slug);
    Bson[string] query = ["_id": Bson(["$gt": Bson(current.id)])];
    if(tag != "")
    {
        query["tags"] = Bson(tag);
    }
    Bson[string] q = ["query": Bson(query), "orderby": Bson(["_id": Bson(1)]), "maxScan": Bson(1)];
    auto res = col_articles.find(q);
    if(!res.empty) return Article.fromBson(res.front);
    else return current;
}

public Article getPreviousArticle(string slug, string tag = "")
{
    Article current = getArticle(slug);
    Bson[string] query = ["_id": Bson(["$lt": Bson(current.id)])];
    if(tag != "")
    {
        logInfo("with tag: " ~ tag);
        query["tags"] = Bson(tag);
    }
    Bson[string] q = ["query": Bson(query), "orderby": Bson(["_id": Bson(-1)]), "maxScan": Bson(1)];
    auto res = col_articles.find(q);
    if(!res.empty) return Article.fromBson(res.front);
    else return current;
}

public void insertArticle(Article article)
{
    Bson bson = article.toBson();
    col_articles.insert(bson);
}

public void saveArticle(Article article)
{
    Bson bson = article.toBson();
    Bson[string] q = ["_id": Bson(article.id)];
    col_articles.update(Bson(q), bson);
}

public void addComment(string slug, Comment comment)
{
    Bson bson = comment.toBson();
    Bson[string] q = ["slug": Bson(slug)];
    col_articles.update(q, Bson(["$push": Bson(["comments": bson])]));
}

public Comment getComment(string slug, string cid)
{
    Bson[string] q = ["slug": Bson(slug), "comments._id": Bson(BsonObjectID.fromString(cid))];
    auto res = col_articles.find(q, Bson(["comments": Bson(1)]));
    if(!res.empty) return (cast(Bson[])res.front["comments"]).map!(a => Comment.fromBson(a))().filter!(a => a.id.toString() == cid)().front;
    else return Comment();
}

public void removeComment(string slug, string id)
{
    Bson[string] q = ["slug": Bson(slug)];
    col_articles.update(q, Bson(["$pull": Bson(["comments": Bson(["_id": Bson(BsonObjectID.fromString(id))])])]));
}

public void addUser(string token, string provider, string username, string email)
{
    Bson[string] bson = ["provider": Bson(provider), "name": Bson(username), "email": Bson(email), "token": Bson(token)];
    col_users.insert(Bson(bson));
}
