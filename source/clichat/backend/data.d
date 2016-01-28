module clichat.backend.data;

alias MessageData = string;

import std.uuid : UUID;
alias UserID = string;

// revert back to SysTime when vibe.d has caught up
alias Time = string;

struct Message
{
	MessageData data;
	alias data this;

	Time time;

	/// Unique identifier for the user that sent this message
	UserID uid;

	this(MessageData data, Time time, UserID uid)
	{
		this.data = data;
		this.time = time;
		this.uid = uid;
	}
}

struct Messages
{
	import vibe.db.mongo.collection : MongoCollection;
	MongoCollection collection;

	void delegate(Message)[] newMessageObservers;

	this(MongoCollection collection)
	{
		opAssign(collection);
	}

	void opAssign(MongoCollection collection)
	{
		this.collection = collection;
	}

	/++
	Adds a new messages, should trigger sending it to all connected clients
	+/
	void add(Message message)
	{
		import vibe.data.bson : serializeToBson;
		// Insert into database
		collection.insert(message.serializeToBson());

		// Notify all interested parties about the newly added message
		notifyNewMessage(message);
	}

	void notifyNewMessage(Message message)
	{
		foreach (observer; newMessageObservers)
		{
			observer(message);
		}
	}

	/++
	Gets called when a new connection is established,
	updates should be sent to clients asynchronously
	+/
	Message getLast()
	{
		auto messages = collection.find().sort(["time": -1]);

		if (messages.empty)
		{
			import std.datetime : Clock;
			import std.conv : to;
			// Return a default message
			return Message("Hello, world.", Clock.currTime.toUTC().to!string, "init");
		}
		else
		{
			import vibe.data.bson : deserializeBson;
			return messages.front.deserializeBson!Message;
		}
	}
}
