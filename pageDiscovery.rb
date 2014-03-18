# 
module PageDiscovery

	#
	def discoverPages	
		@foundLinks << curPage.uri	
		begin
			@foundLinks.each do |link|
				@curPage = @agent.get(link)

				@curPage.links.each do |subLink|
					# Merge in-case relative relative
					@foundLinks << @curPage.uri.merge(subLink.uri)
				end

				guessPages(link)

				# Ensure no duplicates are in the list
				@foundLinks = @foundLinks.uniq

				# Ensure there are no 
				filterOffSiteLinks
		end
		rescue => e
			puts e.message
		end
	end
	
	# Check to see if the Remove links that go offsite from given array into corresponding 
	# array. We need to have a verify that this is actually doing what 
	# we think it is doing
	def filterOffSiteLinks
		@foundLinks.delete_if{ |link| 
			(URI.split(link.to_s))[2] != @host
		 }
	end

	# Should this just add in all the guessed pages into 
	# or also validate those pages?
	# or ??? (insert suggestions)
	def guessPages uri
		extensions = ['.php', '.jsp', '.txt', '.html', '.htm']
		words = Array.new
		testURLs = Array.new
		validURLs = Array.new
		
		#url = 'http://127.0.0.1'
		#url = InputValidation.validateURL(url)	

		file = File.new("words.txt")
		file.each do |word|
			words << word.strip
		end

		words.each do |word|
			extensions.each do |ext|
				testURLs << url + '/' + word + ext
				
			end
		end
		
		testURLs.each do |test|
			begin
				agent.get(test) do |page|
				puts 'Page Found: ' + test
					validURLs << test
				end
			rescue
				puts 'No Page Found: ' + test
			end
		end
		
		#puts validURLs
		return validURLs	
	end
end

#.select or .findall
# .select takes in a block 