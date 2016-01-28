function initPusher()
{
	var xhr = new XMLHttpRequest();

	function poll()
	{
		xhr.open("GET", "pusher");
		xhr.send();
	}

	function loadListener()
	{
		console.log(this.responseText);
		// Send another request
		poll();
	}

	function errorListener(event)
	{
		// Check if server is back online in 1 second
		setTimeout(poll, 1000);
	}

	xhr.addEventListener("load", loadListener);
	xhr.addEventListener("error", errorListener);

	poll(xhr);
}

initPusher();
