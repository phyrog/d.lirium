module routes.error;

import vibe.http.server;

void handler(HttpServerRequest req,
			 HttpServerResponse res,
			 HttpServerErrorInfo error)
{
	res.writeBody("Error.");
}
