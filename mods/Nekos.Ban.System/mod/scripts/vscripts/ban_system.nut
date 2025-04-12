global function Ban_System_Init

struct {
	array<string> banned
	array<string> githubbanned
} file

void function Ban_System_Init()
{
UpdateBanList()
AddCallback_OnClientConnected( DoJoinStuff )
}

void function UpdateBanList()
{
string bans = GetConVarString( "banned_uids" )
file.banned = split( bans, "," )
foreach ( string ban in file.banned )
	StringReplace( ban, " ", "" )
}

void function GithubBan( entity player )
{
thread GithubBan_thread( player )
}

void function GithubBan_thread( entity player )
{
    void functionref( HttpRequestResponse ) onSuccess = void function (HttpRequestResponse response) : ( player )
    {
        if (NSIsSuccessHttpCode(response.statusCode)) 
        {
            string githubbans = response.body
            file.githubbanned = split( githubbans, "," )
            print( "[Nekos.Ban.System] Http Request Success" )
            if( IsValid( player ) )
            {
            if( file.githubbanned.contains( player.GetUID() ) )
            DoJoinStuffInstantBan( player )
            }
        }
    }

    void functionref( HttpRequestFailure ) onFailure = void function ( HttpRequestFailure failure )
    {
        print( "[Nekos.Ban.System] Http Request Failed" )
    }
    string url = GetConVarString( "banned_uids_website" )
    NSHttpGet( url, {}, onSuccess, onFailure )
}

bool function PlayerIsBanned( entity player )
{
if ( file.banned.contains( player.GetUID() ) )
return true
return false
}

bool function ShouldUseGithubBan( entity player )
{
if( GetConVarInt( "banned_use_website" ) == 0 )
return false
if( PlayerIsBanned( player ) )
return false
return true
}

void function DoJoinStuff( entity player )
{
thread DoJoinStuff_thread( player )
}

void function DoJoinStuff_thread( entity player )
{
wait 0.1
if( !IsValid( player ) )
return
UpdateBanList()
if( ShouldUseGithubBan( player ) )
GithubBan( player )
if ( PlayerIsBanned( player ) )
{
print( "[Nekos.Ban.System] Player Is Banned Disconnecting Player" )
string disconnectmessage = GetConVarString( "banned_disconnect_text" )
NSDisconnectPlayer( player, disconnectmessage )
return
}
print( "[Nekos.Ban.System] Player Isn't Banned" )
}

void function DoJoinStuffInstantBan( entity player )
{
print( "[Nekos.Ban.System] Player Is Banned Disconnecting Player" )
string disconnectmessage = GetConVarString( "banned_disconnect_text" )
NSDisconnectPlayer( player, disconnectmessage )
}