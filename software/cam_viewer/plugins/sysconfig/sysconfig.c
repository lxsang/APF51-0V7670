#include "../plugin.h"
void init();
call __init__ = init;


void init()
{
	printf("Init plugin %s \n", __plugin__.name);
}

void execute(int client, const char* method,dictionary rq)
{

	html(client);
// Body
	__t(client, "<HTML><TITLE>Server configuration</TITLE>");

	__t(client, "<BODY><P>Plugin :");
	__t(client,__plugin__.name);
	__t(client,"<br> Database path:");
	__t(client,__plugin__.dbpath);
	__t(client,"<br> Server time :");
	__t(client,server_time());
	__t(client, "</BODY></HTML>");
}