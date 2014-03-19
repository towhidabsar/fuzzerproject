# Discovers all the inputs in the page
module InputDiscovery extend self

	# Parses the given url to find possible input queries
	def discoverQueries
		# All the queries from the given page
		pageQueries = page.uri.query

		# Check to see if given host is in the hash map
		if not @linkQueries.has_key? page.uri
			@linkQueries[page.uri] = Array.new
		end

		if not pageQueries == nil
			pageQueries = pageQueries.split("&")
			# Traverse each query in pageQueries & append to it's array
			pageQueries.each do |query|
				@linkQueries[page.uri] << query
			end
		end
	end 

	# Parses the given list of forms & add them to the given hash map
	def discoverForms
		# Check to see if given host is in the hash map
		if not @formInputs.has_key? page.uri
			@formInputs[page.uri] = Array.new
		end
		
		# Traverse each form in page.forms & add it to it's array
		page.forms.each do |form|
			@formInputs[page.uri].concat(form.fields)
			@formInputs[page.uri].concat(form.buttons)
		end
	end

	# Acquires the browsers cookies via the given +agent+ & adds it to
	# 	the given array
	def discoverCookies
		@cookies << agent.cookies
	end
end