module clichat.frontend.pusher;

import vibe.http.router : URLRouter;
URLRouter registerPusher(URLRouter router, Pusher pusher)
{
	import vibe.web.web : registerWebInterface;
	return router.registerWebInterface(pusher, pusher.settings.webInterface);
}

enum SendType : string
{
	message = "message",
	error = "error"
}

class Pusher
{
	PusherSettings settings;

	import vibe.core.sync : TaskMutex;
	TaskMutex mutex;

	import vibe.core.sync : TaskCondition;
	TaskCondition condition;

	bool shouldPush;

	import clichat.backend.data : Message;
 	private Message message;

	this()
	{
		settings = new PusherSettings;
		this(settings);
	}
	this(PusherSettings settings)
	{
		this.settings = settings;

		mutex = new TaskMutex;
		condition = new TaskCondition(mutex);
	}

	/++
	Needs to be hooked up to a message source
	+/
	package void onNewMessage(Message message)
	{
		this.message = message;
		shouldPush = true;
		condition.notifyAll();
	}

	import vibe.web.common : path;
	import vibe.http.server : HTTPServerRequest, HTTPServerResponse;
	/++
	Pushes a new message to the client when one is received
	+/
	@path("")
	void get(HTTPServerRequest req, HTTPServerResponse res)
	{
		synchronized(mutex)
		{
			import core.time : seconds;
			condition.wait(15.seconds);

			if (shouldPush)
			{
				auto msg = ["type": SendType.message, "data": message.data];

				import vibe.data.json : serializeToJson;
				res.writeJsonBody(msg.serializeToJson());
				shouldPush = false;
			}
			else
			{
				res.writeVoidBody();
			}
		}
	}
}

class PusherSettings
{
	import vibe.web.web : WebInterfaceSettings;
	WebInterfaceSettings webInterface;
	alias web = webInterface;

	this(string urlPrefix = "pusher")
	{
		webInterface = new WebInterfaceSettings;
		webInterface.urlPrefix = urlPrefix;
	}
}
