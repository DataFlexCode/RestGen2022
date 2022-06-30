# RESTGen2022
<b>Generate DataFlex Structs from input JSON</b>

The workspace does not contain a complied version of the program, so your first step after cloning the repo should be to compile the program RESTGen.src.

<b>Usage:</b>

In the DataFlex Studio, select Tools --> Configure Tools Menu...  Enter "RESTGen" as the Label, the full path to the RESTGen.exe file as the Command and &lt;workspace&gt; in the Parameters, then click OK.  RESTGen will now appear on your Tools menu. This will allow you to use RESTGen to create structs from sample JSON in any of your workspaces for that verson of DataFlex.
 
To use, paste your sample JSON into the large edit window and give the outer struct a meaningful name in the form below it, conventionally prefixed with "st".  You can then opionally alter the sub-directory of your AppSrc folder the structs will be placed in from the default "ApiStructs" (keep the absolute path and relative path in sync if you do so).  Click the "Generate" button to generate the required structs. You will only need to "Use" the outer struct .pkg in your programs as that will use all the dependant sub-structs generated.
 
RESTGen will only look at the FIRST member of any array, so ideally that will be fully populated.
 
RESTGen can only work with what you give it.  It will warn you of things like empty arrays (it will create them as arrays of strings) and nulls (it will create those as strings as well).  The program will warn you about those and also place comments in the struct code where these things occur.
 
Unlike previous versions, this one will only generate the structs themselves, not any handling code for them, assuming that you will use objects the cJsonObject class (introduced in in DataFlex 19.0) to do that.
 
Enjoy!  :-)

Mike Peat, Unicorn InterGlobal Ltd.
