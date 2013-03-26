module dlirium.parser;

import std.regex;
import std.exception;
import std.algorithm : countUntil, sort, SwapStrategy;
import std.stdio;

void  parseFile(string[] file)
{
	enforce(file[1].match("^===+$"));
	string title = file[0];
	string[] tags;
	string text;

	foreach(line; file[2 .. $])
	{
		string tmp = "";
		bool isTag = false;
		foreach(c; line)
		{
			if(tmp == "" && c == '{' && !isTag) isTag = true;
			else
			{
				if(isTag)
				{
					if(c == '}') // closing tag
					{
						if(tags.countUntil(tmp) == -1)
							tags ~= tmp;
						text ~= "[" ~ tmp ~ "](/tag/" ~ tmp ~ ")";
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
				else { // no tag, append text
					text ~= c;
				}
			}
		}
		if(isTag) // line has no closing }
			text ~= "{" ~ tmp;
		text ~= '\n';
	}
	sort!("toLower(a) < toLower(b)", SwapStrategy.stable)(tags); // sort tags alphabetically
	
	writeln(title);
	writeln(tags);
	writeln(text);
}

void main(string[] args)
{
	string f = "This is the title
===
And this is {some} text {with} {some} {tag}s in it is great.
	void bla() { {writeln(hallo)} }
bla";

	parseFile(f.split(regex(r"\n")));
}
