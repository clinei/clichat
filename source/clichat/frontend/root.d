module clichat.frontend.root;

import vibe.http.router : URLRouter;
URLRouter registerRoot(URLRouter router, Root root, RootSettings settings)
{
	import vibe.web.web : registerWebInterface;
	return router.registerWebInterface(root, settings);
}

class Root
{
	import clichat.frontend : FrontendSettings;
	FrontendSettings settings;

	this()
	{
		settings = new FrontendSettings;
	}
	this(FrontendSettings settings)
	{
		this.settings = settings;
	}

	import vibe.web.common : path;
	import vibe.http.server : HTTPServerRequest, HTTPServerResponse;
	@path("/")
	void getIndex(HTTPServerRequest req, HTTPServerResponse res)
	{
		struct Info
		{
			string title;
		}
		auto info = Info("CLIchat");
		import vibe.http.server : render;
		res.render!("index.dt", settings, info);
	}
}

import vibe.web.web : WebInterfaceSettings;
alias RootSettings = WebInterfaceSettings;
