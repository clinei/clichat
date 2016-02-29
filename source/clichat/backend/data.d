module clichat.backend.data;

alias UserID = string;
struct Message
{
	string data;
	import std.datetime : SysTime;
	SysTime time;
	UserID userID;
}
