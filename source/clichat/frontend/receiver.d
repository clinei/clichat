module clichat.frontend.receiver;

import vibe.http.router : URLRouter;
URLRouter registerReceiver(URLRouter router, Receiver receiver)
{
	import vibe.web.web : registerWebInterface;
	return router.registerWebInterface(receiver, receiver.settings.webInterface);
}

enum ReceiveType : string
{
	getLast = "getLast",
	message = "message"
}

enum SendType : string
{
	message = "message",
	error = "error"
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

	import vibe.web.common : path, method;
	import vibe.http.common : HTTPMethod;
	import vibe.http.server : HTTPServerRequest, HTTPServerResponse;
	/++
	Receives new messages
	+/
	@path("")
	@method(HTTPMethod.POST)
	void receive(HTTPServerRequest req, HTTPServerResponse res)
	{

		string uid = req.cookies.get("uid");

		// Set UserID if there is none
		if (uid == null)
		{
			import vibe.web.common : Cookie;
			auto uidCookie = new Cookie;

			import std.uuid : randomUUID;
			import std.conv : to;
			uid = randomUUID().to!string;

			uidCookie.value = uid;
			res.cookies["uid"] = uidCookie;
		}

		try
		{
			import std.conv : to;
			auto type = req.json["type"].to!string;

			switch (type) with (ReceiveType)
			{
				case getLast:
					try
					{
						auto lastMessage = backend.messages.getLast();

						import vibe.data.json : serializeToJson;
						auto data = ["type": SendType.message, "data": lastMessage.data].serializeToJson();

						res.writeJsonBody(data);
					}
					catch (Exception e)
					{
						auto message = ["type": SendType.error, "data": "failed getting last message"];

						import vibe.data.json : serializeToJson;
						auto data = message.serializeToJson();

						res.writeJsonBody(data);
					}
					break;
				case message:
					auto data = req.json["data"];

					import clichat.backend.data : Message;
					import std.conv : to;
					import std.datetime : Clock;
					auto message = Message(data.to!string, Clock.currTime.toUTC().to!string, uid);

					backend.messages.add(message);

					res.writeVoidBody();
					break;
				default:
					break;
			}
		}
		catch (Exception e)
		{
			auto message = ["data": "missing 'type' field"];

			import vibe.data.json : serializeToJson;
			auto data = message.serializeToJson();

			res.writeJsonBody(data);
		}

	}
}

class ReceiverSettings
{
	import vibe.web.web : WebInterfaceSettings;
	WebInterfaceSettings webInterface;
	alias web = webInterface;

	this(string urlPrefix = "receiver")
	{
		webInterface = new WebInterfaceSettings;
		webInterface.urlPrefix = urlPrefix;
	}
}
