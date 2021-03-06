Channel
	var
		name
		topic
		qotd

		list
			chatters = list()
			operators = list()
			snippets = list()

	New(params[])
		if(params)
			name = params["name"]
			topic = params["topic"]

		..()

	proc
		join(mob/chatter/C)
			if(!C || !C.client)
				del(C)
				return

			winset(C, null, "channel.default_input.is-default=true;channel.topic_label.text=\"[text_manager.escapeQuotes(topic)]\";")

			if(isBanned(C))
				C << output("<font color='red'>Sorry, you are banned from this channel.</font>", "default_output")
				C << output("<font color='red'>Connection closed.</font>", "default_output")

				server_manager.logger.info("Banned user [C.name] attempted to log in.")

				del(C)

				return

			if(C.flip_panes) winset(C, "default.child", "left=who;right=channel;splitter=20")
			else winset(C, "default.child", "left=channel;right=who;splitter=80")

			C.setInterfaceColor(C.interface_color)

			winshow(C, ckey(name), 1)
			winset(C, "default_output", "style='[C.default_output_style]';")

			if(C.ckey in operators) winset(C, "channel.ops_button", "is-visible=true")
			else winset(C, "channel.ops_button", "is-visible=false")

			C << output("<center>- - - - - - - - - - - - - - -", "default_output")

			if(C.show_title)
				if(C.show_colors)
					C << output({"<span style='text-align: center;'><b><font color='#0000ff'>[world.name] - Created by Xooxer</font></b></span>
<span style='text-align: center;'><b><font color='#0000ff'>and the BYOND Community</font></b></span>
<span style='text-align: center;'><b>[text_manager.fadeText("Still the greatest chat program on BYOND!", list("102000000","255000000","102000000","000000000","000000255"))]</b></span>
<span style='text-align: center;'>Source available on the <a href='http://www.github.com/Stephen001/Chatters/'>Chatters Repository</a>.</span>
<span style='text-align: center;'>Copyright (c) 2008 Andrew "Xooxer" Arnold</span>
<span style='text-align: center;'><font color=red>- All Rights Reserved -</font></span>
"}, "default_output")

				else
					C << output({"<span style='text-align: center;'><b>[world.name] - Created by Xooxer</b></span>
<span style='text-align: center;'><b>and the BYOND Community</b></span>
<span style='text-align: center;'><b>Still the greatest chat program on BYOND!</b></span>
<span style='text-align: center;'>Source available on the <a href='http://www.github.com/Stephen001/Chatters/'>Chatters Repository</a>.</span>
<span style='text-align: center;'>Copyright (c) 2008 Andrew "Xooxer" Arnold</span>
<span style='text-align: center;'>- All Rights  Reserved -</span>
"}, "default_output")

			if(C.show_qotd) text_manager.qotd(C)
			if(C.show_welcome) C << output("<center>[time2text(world.realtime + C.time_offset, textutil.list2text(C.long_date_format, ""))]<br><b>Welcome, [C.name]!</b></center>", "default_output")

			C << output("<span style='text-align: center;'><b>Please report any issues with Chatters <a href='https://github.com/Stephen001/Chatters/issues?state=open'>here</a>!</b></span>", "default_output")
			C << output("<center>- - - - - - - - - - - - - - -</center>", "default_output")

			if(!chatters) chatters = new()

			C.afk = FALSE
			C.away_at = 0

			chatters += C
			updateWho()

			world.status = "[name] ([length(chatters)] chatter\s)"

			winset(C, "channel.default_input", "text='> ';focus=true;")

			server_manager.bot.say("[C.name] has joined [name].")
			server_manager.bot.say("[topic]", C)

			if(chatter_manager.isTelnet(C.key))
				C.who()

		quit(mob/chatter/C)
			if(!C)
				for(var/i = 1 to length(chatters))
					if(!chatters[i]) chatters -= chatters[i]

				updateWho()

				return

			if(chatters) chatters -= C
			if(!length(chatters)) chatters = null

			updateWho()

			server_manager.bot.say("[C.name] has quit [name].")

		updateWho()
			for(var/i = 1, i <= length(chatters), i ++)
				var/mob/chatter/c = chatters[i]
				if(!c || !c.client) chatters -= c

			chatters = sortWho(chatters)

			for(var/mob/chatter/C in chatters)
				if(!chatter_manager.isTelnet(C.key))
					for(var/i = 1, i <= length(chatters), i ++)
						var/mob/chatter/c = chatters[i]

						if(c.client && C.client)
							winset(C, "who.grid", "current-cell=1,[i]")
							var/n = c.name

							if(c.afk)
								c.icon_state = "away"
								if(!(c.ckey in server_manager.home.operators)) winset(C, "who.grid", "style='body{color: gray;}'")
								else winset(C, "who.grid", "style='body{color:gray;font-weight:bold}'")

							else if(c.ckey in server_manager.home.operators)
								c.icon_state = "active"
								winset(C, "who.grid", "style='body{color:[c.name_color];font-weight:bold}'")

							else if(server_manager.ban_manager.isMuted(c.ckey))
								c.icon_state = "active"
								winset(C, "who.grid", "style='body{color:[c.name_color];text-decoration:line-through;}'")

							else
								c.icon_state = "active"
								winset(C, "who.grid", "style='body{color:[c.name_color];}'")

							C << output(c, "who.grid")
							c.name = n

					if(C.client)
						winset(C, "who.grid", "cells=1x[length(chatters)]")

		sortWho(list/L)
			var/list/afk_list

			for(var/mob/chatter/C in L)
				if(C.afk)
					if(!afk_list)
						afk_list = new

					L -= C
					afk_list += C

					if(!length(L))
						L = null

			L = atomSort(L)
			afk_list = atomSort(afk_list)

			if(L && afk_list) return L + afk_list
			else if(afk_list) return afk_list
			else return L

		atomSort(list/L = list())
			var
				atom/A1
				atom/A2

			if(length(L) > 1)
				for(var/i = length(L), i > 0, i --)
					for(var/j = 1, j < i, j ++)
						A1 = L[j]
						A2 = L[j + 1]

						if(!istype(A1) || !istype(A2)) continue
						if(ckey(A1.name) > ckey(A2.name))
							L.Swap(j, j + 1)

			if(!length(L)) L = null

			return L

		say(mob/chatter/C, msg, clean, window)
			if(isMute(C))
				server_manager.bot.say("I'm sorry, but you appear to be muted.", C)
				if(textutil.hasPrefix(C.ckey, "guest"))
					server_manager.bot.say("Please login with your registered key, or visit http://www.byond.com/ to create a new key now.",C)

				return

			msg = copytext(msg, 1, 1024)

			if(!clean)
				msg = text_manager.sanitize(msg)

			var
				raw_msg = msg
				smsg = text_manager.parseSmileys(msg)

			smsg = text_manager.parseLinks(smsg)
			msg = text_manager.parseLinks(msg)

			if(!window) window = "default_output"

			for(var/mob/chatter/c in chatters)
				if(c.ignoring(C) & CHAT_IGNORE)
					continue

				var/message = raw_msg
				if(c.show_smileys && !(c.ignoring(C) & SMILEY_IGNORE)) message = text_manager.parseSmileys(raw_msg)

				message = text_manager.parseLinks(message)
				message = text_manager.parseTags(message, c.show_colors, c.show_highlight, 0)

				var/parsed_msg = c.parseMsg(C, message, c.say_format)
				if(parsed_msg) c << output(parsed_msg, "[window]")

		me(mob/chatter/C, msg, clean, window)
			if(isMute(C))
				server_manager.bot.say("I'm sorry, but you appear to be muted.", C)
				return

			msg = copytext(msg, 1, 1024)

			if(!clean) msg = text_manager.sanitize(msg)

			var
				raw_msg = msg
				smsg = text_manager.parseSmileys(msg)

			smsg = text_manager.parseLinks(smsg)
			msg = text_manager.parseLinks(msg)

			if(!window) window = "default_output"

			for(var/mob/chatter/c in chatters)
				if(!c.ignoring(C))
					var/message
					if(c.show_smileys && !(c.ignoring(C) & SMILEY_IGNORE)) message = text_manager.parseSmileys(raw_msg)

					message = text_manager.parseLinks(message)
					message = text_manager.parseTags(message, c.show_colors, c.show_highlight, 0)

					var/parsed_msg = c.parseMsg(C,message, c.me_format, 1)
					if(parsed_msg) c << output(parsed_msg, "[window]")

		my(mob/chatter/C, msg, clean, window)
			if(isMute(C))
				server_manager.bot.say("I'm sorry, but you appear to be muted.",C)
				return

			msg = copytext(msg, 1, 1024)
			if(!clean) msg = text_manager.sanitize(msg)

			var
				raw_msg = msg
				smsg = text_manager.parseSmileys(msg)

			smsg = text_manager.parseLinks(smsg)
			msg = text_manager.parseLinks(msg)

			if(!window) window = "default_output"

			for(var/mob/chatter/c in chatters)
				if(!c.ignoring(C))
					var/message
					if(c.show_smileys && !(c.ignoring(C) & SMILEY_IGNORE)) message = text_manager.parseSmileys(raw_msg)

					message = text_manager.parseLinks(message)
					message = text_manager.parseTags(message, c.show_colors, c.show_highlight, 0)

					var/parsed_msg = c.parseMsg(C,message, c.me_format, 2)
					if(parsed_msg) c << output(parsed_msg, "[window]")

		goAFK(mob/chatter/C, msg)
			if(chatter_manager.isTelnet(C.key))
				return

			C.afk = TRUE
			C.away_at = world.realtime
			msg = copytext(msg, 1, 1024)
			msg = text_manager.sanitize(msg)
			C.away_reason = msg

			var/raw_msg = msg

			updateWho()
			server_manager.bot.say("You are now AFK.", C)

			if(!isMute(C))
				for(var/mob/chatter/c in chatters)
					if(!(c.ignoring(C) & CHAT_IGNORE))
						var/rsn = ""
						if(ckey(raw_msg)) rsn = "([raw_msg])"

						c << output("[c.parseTime()] [c.show_colors ? "<font color=[C.name_color]>[C.name]</font>" : "[C.name]"] is now AFK. [rsn]", "default_output")

		returnAFK(mob/chatter/C)
			if(!C) return

			C.afk = FALSE
			C.away_reason = null

			updateWho()

			server_manager.bot.say("You are no longer AFK.", C)

			if(!isMute(C))
				for(var/mob/chatter/c in chatters)
					if(!(c.ignoring(C) & CHAT_IGNORE))
						c << output("[c.parseTime()] <font color=[C.name_color]>[C.name]</font> is back from <b>AFK</b> after [round(((world.realtime - C.away_at)/600),1)] minute\s of inactivity.", "default_output")

			C.away_at = null

		isMute(mob/chatter/M)
			var/search = ""

			if(istext(M)) search = ckey(M)
			else if(ismob(M)) search = M.ckey
			else return 1

			if(textutil.hasPrefix(search, "guest")) if(server_manager.ban_manager.isMuted("guest")) return 1
			else if(server_manager.ban_manager.isMuted(search)) return 1

			if(textutil.hasPrefix(search, "telnet")) if(server_manager.ban_manager.isMuted("telnet")) return 1
			else if(server_manager.ban_manager.isMuted(search)) return 1

		isBanned(mob/chatter/M)
			if(server_manager.ban_manager.isBanned(M.ckey)) return 1
			else
				var/search = ""

				if(istext(M)) search = ckey(M)
				else if(ismob(M)) search = M.ckey
				else return 1

				if(textutil.hasPrefix(search, "guest")) if(server_manager.ban_manager.isBanned("guest")) return 1
				else if(server_manager.ban_manager.isBanned(search)) return 1

				if(textutil.hasPrefix(search, "telnet")) if(server_manager.ban_manager.isBanned("telnet")) return 1
				else if(server_manager.ban_manager.isBanned(search)) return 1

				var/TrackerEntry/entry

				if(M.client) entry = tracker_manager.findByClient(M.client)
				else entry = tracker_manager.findByCkey(search)

				if(entry)
					for(var/ck in entry.ckeys)
						if(server_manager.ban_manager.isBanned(ckey(ck)))
							return 1