module clichat.backend.data;

alias MessageData = string;

import std.uuid : UUID;
alias UserID = string;

struct Message
{
	MessageData data;
	alias data this;

	import std.datetime : SysTime;
	SysTime time;

	/// Unique identifier for the user that sent this message
	UserID uid;

	this(MessageData data, SysTime time, UserID uid)
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

	version(observer)
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

		version(observer)
		{
			// Notify all interested parties about the newly added message
			notifyNewMessage(message);
		}
	}

	version(observer)
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
		import std.datetime : Clock;
		return Message("Hello, world.", Clock.currTime.toUTC(), "init");

		static if (false)
		{
			auto messages = collection.find().sort(["date": 1]);

			if (messages.empty)
			{
				import std.datetime : Clock;
				// Return a default message
				return Message("Hello, world.", Clock.currTime.toUTC(), "init");
			}
			else
			{
				import vibe.data.bson : deserializeBson;
				return messages.front.deserializeBson!Message;
			}
		}
	}
}
