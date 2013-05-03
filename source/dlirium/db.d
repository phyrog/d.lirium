module dlirium.db;

import vibe.core.log;

import vibe.db.mongo.mongo;
import vibe.data.bson;
import vibe.data.json;
import dlirium.data;

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
