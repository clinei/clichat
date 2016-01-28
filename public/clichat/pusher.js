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
		if (this.responseText)
		{
			var res = JSON.parse(this.responseText);
			processResponse(res);
		}
		// Send another request
		poll();
	}

	function errorListener(event)
	{
		// Wait a bit and then check if the server is functional again
		setTimeout(poll, 2000);
	}

	xhr.addEventListener("load", loadListener);
	xhr.addEventListener("error", errorListener);

	poll(xhr);
}

initPusher();
