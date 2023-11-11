//This simple code can be placed into an object to import data from the Weather.com API to Second Life.  It uses the http_request method rather than the XML RPC, which is a bit tricky.



//setup intial strings and keys for searching amd displaying weather information

string URL="http://xoap.weather.com/weather/local?cc=*&prod=xoap&par=1056019094&key=YOUR WEATHER.COM API KEY HERE;
string SearchURL="http://xoap.weather.com/search/search?where=";
string FURL="http://xoap.weather.com/weather/local/";
string BURL="?cc=*&prod=xoap&par=1056019094&key=YOUR WEATHER.COM API KEY HERE";
key requestKey;

//this function that when given a string will return a substring that is contained between the other two strings that you provide and is used for cleaning up the XML data returned by Weather.com
string getStringBetween(string source, string startDelimiter, string endDelimiter)
{
    //find the position of the start delimiter
    integer startDelimiterLength = llStringLength(startDelimiter);
    integer startIndex = llSubStringIndex(source, startDelimiter) + startDelimiterLength;
    
    //exit with a null string if the startDelimiter was not found
    if (startIndex ==-1)return "";
    
    //find the position of the endDelimiter
    string clippedSource = llGetSubString(source,startIndex,llStringLength(source) - 1);
    integer endIndex = llSubStringIndex(clippedSource,endDelimiter) + startIndex - 1;
    
    //exit with a null string if the endDelimiter was not found
    if (endIndex ==-1)return "";
    
    return llGetSubString(source, startIndex,endIndex);
}


default
{
    state_entry()
    {
       llListen(0,"",NULL_KEY,"");  //listens only to owner
       llOwnerSay("\n Hello, welcome to realtime weather for Second Life.");
       llOwnerSay("To begin you will need to set your location.  To search for a location enter the word search followed by your location.");
 llOwnerSay("You will be presented with a list of locations and codes from Weather.com \n To set your location simply type in the word set followed by the relevant code from Weather.com \n This weather object updates every 12 hours, but you may update it manually be entering the word refresh.");
    }
    
//Listen for command from the object owner in local chat 
    listen(integer channel, string name, key id, string message) //when owner says
    
    {
        //trim the message from the listner to see what the user wants to do
        string trimmedmessage = (llGetSubString((string)message, 0, 5));
        string searchlocation = (llGetSubString((string)message, 6, 1000));
        string refreshfunction = (llGetSubString((string)message, 0, 6));
        string setfunction = (llGetSubString((string)message, 0, 2));
        string setlocation = (llGetSubString((string)message, 3, 1000)); 
        if (trimmedmessage=="search")
        {
            llOwnerSay("Searching Weather.com for " + searchlocation + "......");
            list replacepercentage = llParseString2List(searchlocation,[" "],[]);
            string cleansearchlocation = (llDumpList2String(replacepercentage, "%20"));
            string searchstring =(SearchURL + cleansearchlocation);
            requestKey = llHTTPRequest( searchstring,[HTTP_METHOD,"GET"],"");           
        }
        if (refreshfunction=="refresh")
        {
            llOwnerSay("Refreshing weather data......");
        }
        if (setfunction=="set")
        {
            llOwnerSay("Setting location to " + setlocation);
            string buildurl = (FURL + setlocation + BURL);
            
            list goone = llParseString2List(buildurl,[" "],[]);
            string EURL = (llDumpList2String(goone, ""));
            requestKey = llHTTPRequest( EURL,[HTTP_METHOD,"GET"],"");         
        }
    }
    
 
    touch_start(integer n)
    {
        //this will ask for whatever resides at the URL you defined above
        //the first parameter is the string containing the URL you want to communicate with
        //the second parameter is a list containing the type of command you want and a string defining the actual command
        //the third parameter is a string that you send to the URL (e.g. if you were using PUT rather than GET
        //llHTTPRequest will return a key identifying your request
        requestKey = llHTTPRequest( URL,[HTTP_METHOD,"GET"],"");
    }
    //this event handler is called when SL gets a response to your request
    http_response(key _requestKey,integer status,list metadata,string body)
    {
        if (requestKey == _requestKey)
        {
            //handle the response and handle it depinding upon what it is.
            string results = (body);
            string trimmedresults = (llGetSubString(results, 251, 256));
            string trimmedsearch = (llGetSubString(body, 269, 10000)); //trim search response from Weather.com to get the data we need
            //llOwnerSay(trimmedresults);  //debug 
            
            if(trimmedresults=="search")
        {
        string quote = "\"";
        list passone = llParseString2List(trimmedsearch,[quote, "<loc id=","</loc>","type",">","</search>"],[]);
        string amended = (llDumpList2String(passone, ""));
        list passtwo = llParseString2List(amended,["=1"],[]);
        llOwnerSay("\n" + llDumpList2String(passtwo, ""));  //unrem to debug pass one 
        }   
            else
        {  
            
            //this section of code sets diffrent parts of the returned XML to strings for use later
            
            //the location returned by the XML
            string start = "<dnam>";
            string end = "</dnam>";
            string xmlloc = (getStringBetween(body,start,end));
            //llOwnerSay(xmlloc); //unrem to debug
            
            //the sunrise time returned by the xml
            start= "<sunr>";
            end ="</sunr>";
            string xmlsunr = (getStringBetween(body,start,end));
            //llOwnerSay(xmlsunr); //unrem to debug
            
            //the sunset time returned by the xml
            start= "<suns>";
            end ="</suns>";
            string xmlsuns = (getStringBetween(body,start,end));
            //llOwnerSay(xmlsuns); //unrem to debug
            
            //the temp returned by the xml
            start= "<tmp>";
            end ="</tmp>";
            string xmltmp = (getStringBetween(body,start,end));
            //llOwnerSay(xmltmp); //unrem to debug
            
            //the feels like temp returned by the xml
            start= "<flik>";
            end ="</flik>";
            string xmlflik = (getStringBetween(body,start,end));
            //llOwnerSay(xmlflik);  //unrem to debug
            
            //the weather condition returned by the xml
            start= "<t>";
            end ="</t>";
            string xmlt = (getStringBetween(body,start,end));
            //llOwnerSay(xmlt);  //unrem to debug
            
            //the weather condition icon returned by the xml
            start= "<icon>";
            end ="</icon>";
            string xmlicon = (getStringBetween(body,start,end));
            //llOwnerSay(xmlicon); //unrem to debug
            
            //the humidity returned by the xml
            start= "<hmid>";
            end ="</hmid>";
            string xmlhmid = (getStringBetween(body,start,end));
            // llOwnerSay(xmlhmid); //unrem to debug
            
            //the dew point returned by the xml
            start= "<dewp>";
            end ="</dewp>";
            string xmldewp = (getStringBetween(body,start,end));
            //llOwnerSay(xmldewp); //unrem to debug
            
            //the wind conditions returned by the xml
            start= "<s>";
            end ="</s>";
            string xmls = (getStringBetween(body,start,end));
            //llOwnerSay(xmls);  //unrem to debug
            
            //the wind gusts returned by the xml
            start= "<gust>";
            end ="</gust>";
            string xmlgust = (getStringBetween(body,start,end));
            // llOwnerSay(xmlgust); //unrem to debug
            
            //the temp units returned by the xml
            start= "<ut>";
            end ="</ut>";
            string xmlut = (getStringBetween(body,start,end));
            //llOwnerSay(xmlut);  //unrem to debug
            
            //the speed units returned by the xml
            start= "<us>";
            end ="</us>";
            string xmlus = (getStringBetween(body,start,end));
            //llOwnerSay(xmlus); //unrem to debug
            
            //the last update time returned by the xml
            start= "<lsup>";
            end ="</lsup>";
            string xmllsup = (getStringBetween(body,start,end));
            llOwnerSay("Weather data last updated " + xmllsup);
            
            //there are more items that you can strip out of the XML returned, but I have all I want
            llSetText(xmlloc + "\n" + xmlt + "," + xmltmp +  xmlut + "\n Feels like" + xmlflik + xmlut + "\n Wind " + xmls + "\n Humidity " + xmlhmid + "% \n Sunrise " + xmlsunr + "\n Sunset " + xmlsuns, <0,0,1>, 1.0);
        }
    }
        else
        {
            llOwnerSay((string)status + " error"); //print out the error code if there was a problem with the request
        }
    }
}
