module clichat.frontend;

class Frontend
{
	import clichat.backend : Backend;
	Backend backend;

	import clichat.frontend.root : Root;
	Root root;

	import clichat.frontend.pusher : Pusher;
	Pusher pusher;

	import clichat.frontend.receiver : Receiver;
	Receiver receiver;

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

		pusher = new Pusher(settings.pusher);
		import clichat.frontend.pusher : registerPusher;
		router.registerPusher(pusher);

 		backend.messages.newMessageObservers ~= &pusher.onNewMessage;

		receiver = new Receiver(settings.receiver, backend);
		import clichat.frontend.receiver : registerReceiver;
		router.registerReceiver(receiver);

		root = new Root(settings.root, pusher);
		import clichat.frontend.root : registerRoot;
		router.registerRoot(root);

		import vibe.http.fileserver : serveStaticFiles;
		router.get("/*", serveStaticFiles("public/", settings.fileServer));

		import vibe.http.server : listenHTTP;
		listenHTTP(settings.server, router);
	}
}

class FrontendSettings
{
	string urlPrefix;

	import clichat.frontend.root : RootSettings;
	RootSettings root;

	import clichat.frontend.pusher : PusherSettings;
	PusherSettings pusher;

	import clichat.frontend.receiver: ReceiverSettings;
	ReceiverSettings receiver;

	import vibe.http.server : HTTPServerSettings;
	HTTPServerSettings server;

	import vibe.http.fileserver : HTTPFileServerSettings;
	HTTPFileServerSettings fileServer;

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
		this.urlPrefix = urlPrefix;

		backend = new BackendSettings;

		root = new RootSettings;
		root.webInterface.urlPrefix = urlPrefix;

		pusher = new PusherSettings;
		pusher.webInterface.urlPrefix = urlPrefix ~ "/pusher";

		receiver = new ReceiverSettings;
		receiver.webInterface.urlPrefix = urlPrefix ~ "/receiver";

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
