void main()
{
	import clichat.frontend : Frontend;
	auto frontend = new Frontend("/chat", 8080);

	import vibe.core.core : lowerPrivileges;
	lowerPrivileges();

	import vibe.core.core : runEventLoop;
	runEventLoop();
}