function processResponse(response)
{
	switch (response.type)
	{
		case "message":
			var target = document.getElementById("message");
			target.innerHTML = response.data;
			break;
		default:
			break;
	}
}
