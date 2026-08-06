task("setup")
do
	set_menu({
		description = "Download card data",
		options = {},
	})
	on_run(function()
		import("net.http")
		os.mkdir("assets")
		for _, name in ipairs({ "ot.json", "rd.json" }) do
			local file = path.join("assets", name)
			local url = "https://github.com/arshtyi/ygo-cards/releases/latest/download/" .. name
			http.download(url, file)
			io.writefile(file .. ".sha256sum", hash.sha256(file) .. "  " .. name .. "\n")
		end
	end)
end

task("compile")
do
	set_menu({
		description = "Compile the Typst document",
		options = {},
	})
	on_run(function()
		os.exec("typst compile ygo-card-analytics.typ ygo-card-analytics.pdf")
	end)
end

task("watch")
do
	set_menu({
		description = "Watch and compile the Typst document",
		options = {},
	})
	on_run(function()
		os.exec("typst watch ygo-card-analytics.typ ygo-card-analytics.pdf")
	end)
end
