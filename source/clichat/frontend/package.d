module clichat.frontend;

class Frontend
{
	import clichat.backend : Backend;
	Backend backend;

	import clichat.frontend.root : Root;
	Root root;

	FrontendSettings settings;

	this(string urlPrefix = "", ushort port = 8080)
	{
		auto settings = new FrontendSettings(urlPrefix, port);
		this(settings);
	}
	this(FrontendSettings settings)
	{
		auto backend = new Backend;
		this(settings, backend);
	}
	this(Backend backend)
	{
		auto settings = new FrontendSettings;
		this(settings, backend);
	}
	this(FrontendSettings settings, Backend backend)
	{
		this.settings = settings;
		this.backend = backend;

		import vibe.http.router : URLRouter;
		auto router = new URLRouter;

		root = new Root(settings);

		import clichat.frontend.root : registerRoot;
		router.registerRoot(root, settings.root);

		import vibe.http.websockets : handleWebSockets;
		router.get(settings.webSocketInfo.urlPrefix, handleWebSockets(&backend.handleConnection));

		import vibe.http.fileserver : serveStaticFiles;
		router.get("/*", serveStaticFiles("public/", settings.fileServer));

		import vibe.http.server : listenHTTP;
		listenHTTP(settings.server, router);
	}
}

class FrontendSettings
{
	import clichat.frontend.root : RootSettings;
	RootSettings root;

	import vibe.http.server : HTTPServerSettings;
	HTTPServerSettings server;

	import vibe.http.fileserver : HTTPFileServerSettings;
	HTTPFileServerSettings fileServer;

	import vibe.inet.path : Path;
	Path dataPath = "clichat";

	import clichat.backend : BackendSettings;
	BackendSettings backend;

	WebSocketInfo webSocketInfo;

	string getWebSocketAddress()
	{
		import std.conv : to;
		return webSocketInfo.address ~ ":" ~ webSocketInfo.port.to!string
		       /+~ root.urlPrefix+/ ~ webSocketInfo.urlPrefix;
	}

	this(string urlPrefix = "", ushort port = 8080)
	{
		backend = new BackendSettings();

		root = new RootSettings;
		root.urlPrefix = urlPrefix;

		server = new HTTPServerSettings;
		server.port = port;
		server.bindAddresses = ["::"];

		fileServer = new HTTPFileServerSettings;
		fileServer.serverPathPrefix = urlPrefix;

		webSocketInfo = WebSocketInfo("clinei.noip.me", 8080u, "/ws");
	}
}

struct WebSocketInfo
{
	string address;
	ushort port;
	string urlPrefix;
}
