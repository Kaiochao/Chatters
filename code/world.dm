
world
	version = 0
	name = "Chatters"
	hub = "Xooxer.Chatters"
	hub_password = "rbl9FQ0hzWtOEKtg"	// my eyes only 0_0

	view = "13x11"

	cache_lifespan = 1

	mob = /mob/Temp		 // default temporary mob
	visibility = 1		// Set to 0 in LoadServerCfg if we're not public, leave otherwise.

	New()
		var/rsc_check = VerifyResources()
		if(!rsc_check)
			spawn(10)
				if(Host && Host.client)
					Host << output("Chatters.rsc is missing, corrupt or out of date!\nPlease check your Options & Messages and correct the error.\nShutting down...", "main_menu_output.output")
				del(src)
		else if(rsc_check == "unpakit") // Unpack the hosting package
			var/zipfile/Z = new("./Chatters.zip") // Dantom.zipfile ftw!
			for(var/z in Z.Flist()) Z.Export("./", z) // export host files here
			Reboot() // Restart server to ensure proper boot environment
		..()
		Console = new()	// spawn the Console <-- This starts everything else
		swapmaps_mode = SWAPMAPS_SAV // set SwapMaps to use savfiles

	Del()
		del(Console) // last ditch effort to save before the world dies
		..()


	Topic(Text,Addr)
		..()
		Text+="&addr=[Addr]"
		Console.Topic(Text)

