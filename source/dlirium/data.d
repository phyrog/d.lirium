module dlirium.data;

import dlirium.textfilter.markdown;

struct Article
{
	string		_id;
	string		author;
	string[]	tags;
	string		title;
	string		_text;

	@property public string text() { return _text.filterMarkdown(); }
}
