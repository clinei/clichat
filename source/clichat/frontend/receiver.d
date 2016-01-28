module clichat.frontend.receiver;

import vibe.http.router : URLRouter;
URLRouter registerReceiver(URLRouter router, Receiver receiver)
{
	import vibe.web.web : registerWebInterface;
	return router.registerWebInterface(receiver, receiver.settings.webInterface);
}

class Receiver
{
	ReceiverSettings settings;

	import clichat.backend : Backend;
	Backend backend;

	this(Backend backend)
	{
		settings = new ReceiverSettings;
		this(settings, backend);
	}
	this(ReceiverSettings settings, Backend backend)
	{
		this.settings = settings;
		this.backend = backend;
	}

	import vibe.web.common : path;
	import vibe.http.server : HTTPServerRequest, HTTPServerResponse;
	/++
	Receives new messages
	+/
	@path("")
	void post(HTTPServerRequest req, HTTPServerResponse res)
	{
		string uid = req.cookies.get("uid");

		// Set UserID if there is none
		if (uid == null)
		{
			import vibe.web.common : Cookie;
			auto uidCookie = new Cookie;
			import std.uuid : randomUUID;
			import std.conv : to;
			uidCookie.value = randomUUID().to!string;
			res.cookies["uid"] = uidCookie;
		}

		import clichat.backend.data : Message;
		import std.conv : to;
		import std.datetime : Clock;

		auto message = Message(req.json["data"].to!string, Clock.currTime.toUTC(), uid);

		// TODO: Use Observer pattern
		backend.messages.add(message);

		res.writeVoidBody();
	}
}

class ReceiverSettings
{
	import vibe.web.web : WebInterfaceSettings;
	WebInterfaceSettings webInterface;
	alias web = webInterface;

	this()
	{
		webInterface = new WebInterfaceSettings;
	}
	this(string urlPrefix = "receiver")
	{
		this();
		webInterface.urlPrefix = urlPrefix;
	}
}
