module clichat.frontend.pusher;

import vibe.http.router : URLRouter;
URLRouter registerPusher(URLRouter router, Pusher pusher)
{
	import vibe.web.web : registerWebInterface;
	return router.registerWebInterface(pusher, pusher.settings.webInterface);
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
	version(observer)
 	Message message;

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
	version(observer)
	void onNewMessage(Message message)
	{
// 		this.message = message;
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
			condition.wait(10.seconds);
		}

		if (shouldPush)
		{
// 			res.writeBody(message.data);

			synchronized(mutex)
			{
				shouldPush = false;
			}
		}
		else
		{
			res.writeVoidBody();
		}

		// TODO: asynchrounously send message when one is received
		import core.thread : Thread;
		import core.time : seconds;
		Thread.sleep(1.seconds);
	}
}

class PusherSettings
{
	import vibe.web.web : WebInterfaceSettings;
	WebInterfaceSettings webInterface;
	alias web = webInterface;

	this()
	{
		webInterface = new WebInterfaceSettings;
	}
	this(string urlPrefix = "pusher")
	{
		this();
		webInterface.urlPrefix = urlPrefix;
	}
}
