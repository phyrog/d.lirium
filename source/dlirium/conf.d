module dlirium.conf;

/+
 + Server settings
 +/

ushort portNo = 3838;

/+
 + Blog settings
 +/

public string pageTitle = "d.lirium";
public string blogPrefix = "";


public string slugPath(string path, string[string] params, string slug)
{
    string p = path;
    if(path[$-1] == '/') { p = p[0..$-1]; }
    if("slug" !in params) { p ~= "/" ~ slug; }
    return p;
}
