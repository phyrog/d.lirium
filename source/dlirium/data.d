module dlirium.data;

import vibe.data.bson;
import dlirium.textfilter.markdown;
import std.algorithm : map;
import std.array : array, Appender;
import std.conv : to;
import dlirium.conf;

import vibe.core.log;

public import std.datetime;

struct OAuth2Provider
{
    string provider_name;
    string client_id;
    string client_secret;
    
    string authCodeRequestURL;
    string authTokenRequestURL;
    string userDataRequestURL;
    string scopes;
    string[string] headers;

    string authLink(string referer = "")
    {
        string q;
        if(referer != "")
            q = "?ref=" ~ referer;
        return authCodeRequestURL ~ "?client_id=" ~ client_id ~ "&response_type=code&scope=" ~ scopes ~ "&redirect_uri=http://" ~ dlirium.conf.host ~ "/auth/" ~ provider_name ~ q;
    }
}

struct Date
{
    SysTime      date;

    @property public string year() { return ("0000" ~ to!string(this.date.year))[$-4..$]; }
    @property public string month() { return ("00" ~ to!string(cast(int)this.date.month))[$-2..$]; }
    @property public string day() { return ("00" ~ to!string(this.date.day))[$-2..$]; }
}

struct Article
{
    BsonObjectID id;
    bool         published;
    bool         commentable;
    string       author;
    Date         date;
    string       title;
    string       slug;
    string[]     tags;
    string       _text;
    Comment[]    comments;

    @property public string text() { return this._text.filterMarkdown(); }

    const Bson toBson()
    {
        Bson[string] vals;
        vals["_id"] = Bson(this.id);
        vals["published"] = Bson(this.published);
        vals["commentable"] = Bson(this.commentable);
        vals["author"] = Bson(this.author);
        vals["date"] = Bson(this.date.date.toISOExtString());
        vals["title"] = Bson(this.title);
        vals["slug"] = Bson(this.slug);
        vals["tags"] = Bson(this.tags.map!(a => Bson(a))().array());
        vals["text"] = Bson(this._text);
        vals["comments"] = Bson(this.comments.map!(a => a.toBson())().array());

        return Bson(vals);
    }

    public static Article fromBson(Bson bson)
    {
        Article art;
        art.id = cast(BsonObjectID)bson["_id"];
        art.published = cast(bool)bson["published"];
        art.commentable = cast(bool)bson["commentable"];
        art.author = cast(string)bson["author"];
        art.date = Date(SysTime.fromISOExtString(cast(string)bson["date"]));
        art.title = cast(string)bson["title"];
        art.slug = cast(string)bson["slug"];
        art.tags = (cast(Bson[])bson["tags"]).map!(a => cast(string)a)().array();
        art._text = cast(string)bson["text"];
        art.comments = (cast(Bson[])bson["comments"]).map!(a => Comment.fromBson(a))().array();

        return art;
    }
}

struct Comment
{
    BsonObjectID id;
    string       author;
    Date         date;
    string       _text;

    @property public string text() { return this._text.filterMarkdown(); }

    public const Bson toBson()
    {
        Bson[string] vals;
        vals["_id"] = Bson(this.id);
        vals["author"] = Bson(this.author);
        vals["date"] = Bson(this.date.date.toISOExtString());
        vals["text"] = Bson(this._text);

        return Bson(vals);
    }

    public static Comment fromBson(Bson bson)
    {
        Comment com;
        com.id = cast(BsonObjectID)bson["_id"];
        com.author = cast(string)bson["author"];
        com.date = Date(SysTime.fromISOExtString(cast(string)bson["date"]));
        com._text = cast(string)bson["text"];

        return com;
    }
}

string makeSlugFromHeader(string header)
{
    Appender!string ret;
    foreach(dchar ch; header){
        switch(ch)
        {
            default:
                ret.put('-');
                break;
            case '"', '\'', '´', '`', '.', ',', ';', '!', '?':
                break;
            case 'A': .. case 'Z'+1:
                ret.put(cast(dchar)(ch - 'A' + 'a'));
                break;
            case 'a': .. case 'z'+1:
            case '0': .. case '9'+1:
                ret.put(ch);
                break;
        }
    }
    return ret.data;
}
