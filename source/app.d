void main()
{
	import clichat.frontend : Frontend;
	auto frontend = new Frontend("127.0.0.1", 80, "/chat", "clinei.noip.me", 80, "/ws");

	import vibe.core.core : lowerPrivileges;
	lowerPrivileges();

	import vibe.core.core : runEventLoop;
	runEventLoop();
}
