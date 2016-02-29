module clichat.backend.receiver;

import vibe.http.router : URLRouter;
URLRouter registerReceiver(URLRouter router, Receiver receiver, ReceiverSettings settings)
{
	import vibe.web.web : registerWebInterface;
	return router.registerWebInterface(receiver, settings);
}

final class Receiver
{
	import clichat.backend.backend : Backend;
	Backend backend;

	this(Backend backend)
	{
		this.backend = backend;
	}

	import vibe.web.common : path, method;
	import vibe.http.common : HTTPMethod;
	import vibe.http.websockets : WebSocket;
	@path("/:room")
	@method(HTTPMethod.GET)
	void getWS(string _room, scope WebSocket socket)
	{
		auto r = backend.getRoom(_room);

		if (r.messages.length > 0)
		{
			socket.send(r.messages[$-1]);
		}

		auto userID = socket.request.peer;

		import vibe.core.core : runTask;
		auto writer = runTask({
			auto next_message = r.messages.length;

			while (socket.connected)
			{
				while (next_message < r.messages.length)
				{
					socket.send(r.messages[next_message++]);
				}
				r.waitForMessage(next_message);
			}
		});

		while (socket.waitForData) {
			auto message = socket.receiveText();
			if (message.length) r.addMessage(message, userID);
		}

		writer.join(); // wait for writer task to exit
	}
}
import vibe.web.web : WebInterfaceSettings;
alias ReceiverSettings = WebInterfaceSettings;
