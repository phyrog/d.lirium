module dlirium.data;

import dlirium.textfilter.markdown;

struct Article
{
	string		title;
	string[]	tags;
	string		_text;

	@property public string text() { return _text.filterMarkdown(); }
}
