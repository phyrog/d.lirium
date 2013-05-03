module dlirium.parser;

import dlirium.data;

import std.regex;
import std.exception;
import std.file;
import std.algorithm : countUntil, sort, SwapStrategy;
import std.stdio;
import std.process;
import std.string : toLower;

import vibe.core.log;

Article parseArticleFile(string fileName)
{

    string file = cast(string)read(fileName);

    if(file.length <= 0) return Article();

    string[] lines = file.split(regex("\n"));

    enforce(lines[1].match("^===+$"));
    string title = lines[0];
    string[] tags;
    string text;

    foreach(line; lines[2 .. $])
    {
        string tmp = "";
        bool isTag = false;
        foreach(i, c; line)
        {
            if(tmp == "" && c == '{' && (i == 0 || line[i-1] != '\\') && !isTag) isTag = true;
            else
            {
                if(isTag)
                {
                    if(c == '}') // closing tag
                    {
                        if(tags.countUntil(tmp) == -1 && tmp != ".." && tmp != ".") {
                            tags ~= tmp.toLower();
                            // create symlink for tag
                            string tagPath = "articles/tags/" ~ tmp.toLower();
                            if(!tagPath.exists)
                                system("mkdir -p " ~ tagPath);
                            string filePath = tagPath ~ fileName[19..$];
                            if(!filePath.exists)
                                system("ln -s ../../" ~ fileName[9..$] ~ " " ~ tagPath ~ "/");
                        }
                        if(line[i-tmp.length-2] != '#')
                            text ~= tmp;
                        else
                            text = text[0..$-1];
                        tmp = "";
                        isTag = false;
                    }
                    else if(c == '{') // text has {{, so no tag
                    {
                        text ~= "{{" ~ tmp;
                        tmp = "";
                        isTag = false;
                    }
                    else if(c != '\t' && c != ' ' && c != ';') // Probably no code
                        tmp ~= c;
                    else // no tag, end and append text
                    {
                        text ~= "{" ~ tmp ~ c;
                        isTag = false;
                        tmp = "";
                    }
                }
                else // no tag, append text
                {
                    if(i > 0 && line[i-1] == '\\')
                        text = text[0..$-1] ~ c;
                    else
                        text ~= c;
                }
            }
        }
        if(isTag) // line has no closing }
            text ~= "{" ~ tmp;
        text ~= '\n';
    }
    sort!("toLower(a) < toLower(b)", SwapStrategy.stable)(tags); // sort tags alphabetically
    
    return Article(title, tags, text);
}
