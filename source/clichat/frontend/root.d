module clichat.frontend.root;

import vibe.http.router : URLRouter;
URLRouter registerRoot(URLRouter router, Root root)
{
	import vibe.web.web : registerWebInterface;
	return router.registerWebInterface(root, root.settings.webInterface);
}

class Root
{
	RootSettings settings;

	import clichat.frontend.pusher : Pusher;
	Pusher pusher;

	this(Pusher pusher)
	{
		settings = new RootSettings;
		this(settings, pusher);
	}
	this(RootSettings settings, Pusher pusher)
	{
		this.settings = settings;
		this.pusher = pusher;
	}

	import vibe.web.common : path;
	import vibe.http.server : HTTPServerRequest, HTTPServerResponse;
	@path("/")
	void getIndex(HTTPServerRequest req, HTTPServerResponse res)
	{
		auto info = RootInfo("CLIchat");
		import vibe.http.server : render;
		res.render!("index.dt", settings, info);
	}
}

// Might need to move this into functions
struct RootInfo
{
	string title;
}

class RootSettings
{
	import vibe.web.web : WebInterfaceSettings;
	WebInterfaceSettings webInterface;
	alias web = webInterface;

	import vibe.inet.path : Path;
	Path dataPath = "clichat";

	Path pusherPath = "pusher";

	this()
	{
		webInterface = new WebInterfaceSettings;
	}
}
