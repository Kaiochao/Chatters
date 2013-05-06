
/* Chatters Channel Server

* Copyright (c) 2008, Andrew "Xooxer" Arnold
* All rights reserved.
*
* Redistribution and use in source and binary forms, with or without
* modification, are permitted provided that the following conditions are met:
*     * Redistributions of source code must retain the above copyright
*       notice, this list of conditions and the following disclaimer.
*     * Redistributions in binary form must reproduce the above copyright
*       notice, this list of conditions and the following disclaimer in the
*       documentation and/or other materials provided with the distribution.
*     * Neither the name of the Chatters Network nor the
*       names of its contributors may be used to endorse or promote products
*       derived from this software without specific prior written permission.
*
* THIS SOFTWARE IS PROVIDED BY Andrew "Xooxer" Arnold ``AS IS'' AND ANY
* EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
* WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
* DISCLAIMED. IN NO EVENT SHALL Andrew "Xooxer" Arnold BE LIABLE FOR ANY
* DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
* (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
* LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
* ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
* (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
* SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/


// Preprocessor Definitions

// Network Status
#define FAILED     0
#define CONTACTING 1
#define VALIDATING 2
#define CONNECTING 3
#define CONNECTED  4

#define LIKEABOSS 16

// Ignore Scopes
#define NO_IGNORE     0
#define IM_IGNORE     1
#define CHAT_IGNORE   2
#define FADE_IGNORE   4
#define COLOR_IGNORE  8
#define SMILEY_IGNORE 16
#define IMAGES_IGNORE 32
#define FILES_IGNORE  64
#define FULL_IGNORE   128

// File Size Limit
#define MAX_FILE_SIZE 5242880 // 5 Megabytes

// telnet echo ON
#define VERBOSE 1

// Used to enable debugging output with debug()
#define DEV_DEBUG

// Paint canvas dimensions
#define CANVASX 32
#define CANVASY 32

// Number of Undos allowed to painters
#define UNDONUM 99

// Swap two variables
// pass an unused temporary
// variable C so you can swap A and B
#define swapVars(A,B,C) C=(A);A=(B);B=(C)

#define drawbound(x1,y1,x2,y2,L) \
do { \
	L += x1; L += y1;\
	L += x2; L += y1;\
	L += x1; L += y2;\
	L += x2; L += y2 \
}  while(0)

#define fillbound(x1,y1,x2,y2,L,i) \
do { \
	for(i=y1,i<=y2,i++) { \
		L += x1; L += i;\
		L += x2; L += i \
	} \
}  while(0)

// Global variables and procedures
var/global
	mob/chatter		// Current Host of the Channel Server
		Host

	ServerConsole	// Main controller handles all managers
		Console

	Channel			// Main server channel
		Home

	// Global Managers
	BotManager/BotMan
	ChannelManager/ChanMan
	ChatterManager/ChatMan
	ErrorManager/ErrMan
	EventManager/EventMan
	ListManager/ListMan
	LogManager/LogMan
	MessageManager/MsgMan
	OperatorManager/OpMan
	TextManager/TextMan

	savefile_version = "0.1.6" // savefile versioning to reduce needless wipes

	list/debugs // debug messages saved when host is offline


proc
// Global Procedure Aliases
	debug		(text)						return Console.debug(text)
	islist		(list/L)					return ListMan.isList(L)
	text2list	(text)						return TextMan.List(text)
	list2text	(list/L)					return ListMan.Text(L)
	listOpen	(list/L)					return ListMan.Open(L)
	listAdd		()							return ListMan.Add(args)
	listRemove	()							return ListMan.Remove(args)
	listClose	(list/L)					return ListMan.Close(L)
	invertList	(list/L)					return ListMan.Invert(L)
	stack		(list/L, item, list_len)	return ListMan.Stack(L, item, list_len)
	implode		(list/words, separator)		return TextMan.Implode(words, separator)
	explode		(text, separator)			return TextMan.Explode(text, separator)
	trim		(text)						return TextMan.Trim(text)
	ltrim		(text)						return TextMan.lTrim(text)
	rtrim		(text)						return TextMan.rTrim(text)
	escapeQuotes(txt)						return TextMan.escapeQuotes(txt)