module clichat.backend;

/// Rewrite in progress

/+
auto filterMessage(string message)
{
	// TODO: check redundancy, contract whitespace.
	import std.string : strip;
	import vibe.textfilter.html : htmlEscape;
	return message.strip.htmlEscape;
}
+/

class Backend
{
	BackendSettings settings;

	import vibe.db.mongo.client : MongoClient;
	MongoClient client;

	import vibe.db.mongo.database : MongoDatabase;
	MongoDatabase db;

	import clichat.backend.data : Messages;
	Messages messages;

	this(string name = "clichat", string address = "127.0.0.1")
	{
		import vibe.db.mongo.mongo : connectMongoDB;
		this.client = connectMongoDB(address);
		this.db = client.getDatabase(name);

		messages = db["messages"];
	}

	import clichat.backend.data : Message;
	void addMessage(Message message)
	{
		messages.add(message);
	}
}

/+
class Backend
{
	BackendSettings settings;

	import vibe.core.net : NetworkAddress;
	alias SocketID = NetworkAddress;
	import vibe.http.websockets : WebSocket;
	WebSocket[SocketID] sockets;

	alias UserID = string;
	struct Message
	{
		string data;
		import std.datetime : SysTime;
		SysTime time;
		UserID userID;
	}

	import std.uuid : UUID;
	alias MessageID = UUID;
	Message[MessageID] messages;

	string message;
	size_t userCount;

	import vibe.core.core : Timer;
	Timer updateTimer;

	this()
	{
		this(new BackendSettings);
	}

	this(BackendSettings settings)
	{
		this.settings = settings;

		import std.functional : toDelegate;
		import vibe.core.core : setTimer;
		updateTimer = settings.updateDur.setTimer(toDelegate(&update));
	}

	void update()
	{
		// Schedule next update
		updateTimer.rearm(settings.updateDur);
		import std.datetime : SysTime;
		import std.datetime : Clock;
		SysTime checkTime = Clock.currTime - settings.activeDur;

		UserID[] users;

		foreach (idx, msg; messages)
		{
			if (msg.time < checkTime)
			{
				messages.remove(idx);
			}
			else
			{
				import std.algorithm : canFind;
				if (!users.canFind(msg.userID))
				{
					users ~= msg.userID;
				}
			}
		}
		auto prevUserCount = userCount;
		userCount = users.length;
		if (prevUserCount != userCount)
		{
			send(SendType.UserCount);
		}
	}

	SocketID addSocket(ref WebSocket socket)
	{
		SocketID id = socket.request.clientAddress;
		sockets[id] = socket;
		return id;
	}

	void removeSocket(SocketID id)
	{
		sockets.remove(id);
	}

	size_t activity() nothrow @property
	{
		return messages.length;
	}

	string getData(T)(T sendType)
	{
		import vibe.data.json : Json;
		Json data = Json.emptyObject;

		import std.conv : to;
		if (sendType & SendType.UserCount)
		{
			data["userCount"] = userCount.to!string;
		}
		if (sendType & SendType.Message)
		{
			data["message"] = message.to!string;
		}
		return data.to!string;
	}

	void send(T)(T sendType)
	{
		foreach (WebSocket socket; sockets)
		{
			socket.send(getData(sendType));
		}
	}

	string receive(string data, UserID userID)
	{
		import vibe.data.json : Json, parseJson;
		Json error = Json.emptyObject;
		Json parsed = data.parseJson;
		if ("message" in parsed)
		{
			import std.conv : to;
			auto parsedMessage = parsed["message"].to!string.filterMessage;
			if (parsedMessage.length <= settings.policy.message.maxLength)
			{
				message = parsedMessage;
				import std.datetime : Clock;
				auto msg = Message(message, Clock.currTime.toUTC, userID);

				import std.uuid : randomUUID;
				messages[randomUUID] = msg;
				send(SendType.Message);
			}
			else
			{
				import std.conv : to;
				error["error"] = "Too long! " ~ settings.policy.message.maxLength.to!string ~ " is max!";
			}
		}
		if ("error" in error)
		{
			import std.conv : to;
			return error.to!string;
		}
		else
		{
			return "";
		}
	}

	void handleConnection(scope WebSocket socket)
	{
		// Add to socket list
		auto socketID = addSocket(socket);
		auto userID = socket.request.peer;

		scope (exit)
		{
			// Remove from socket list
			removeSocket(socketID);
		}
		socket.send(getData(initSend));
		while (true)
		{
			if (!socket.connected) break;
			socket.waitForData();

			string data = socket.receiveText();
			string error = receive(data, userID);
			if (error.length > 0)
			{
				socket.send(error);
			}
		}
	}
}
+/

class BackendSettings
{
	import core.time : Duration, dur;
	Duration updateDur = 100.dur!"msecs";
	Duration activeDur = 2.dur!"minutes";

	Policy policy;

	this()
	{
		this.policy = new Policy;
	}
}

class Policy
{
	MessagePolicy message;

	this()
	{
		message = new MessagePolicy;
	}
}

class MessagePolicy
{
	ulong maxLength;

	this(ulong maxLength = 300)
	{
		this.maxLength = maxLength;
	}
}
