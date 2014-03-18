	# Check all the link queries with fuzz vectors.
	def self.fuzzLinkQueries(agent, linkQueries, vectorList)
		#Check if there is a vector next in the vectorList
		while vectorList.has_next?
			#Get the next vector
			vector = vectorList.next_fuzzVector
			#Go through the list of queries with one specific vector
			linkQueries.each_key do |link|
				testInput( true, link, agent, vector)
			end
		end
		#After parsing reset the vector count.
		vectorList.reset_count!
	end

	# Check all the form inputs with fuzz vectors.
	def self.fuzzFormInputs(agent, formInputs, vectorList)
		#Check if there is a vector next in the vectorList
		while vectorList.has_next?
			#Get the next vector
			vector = vectorList.next_fuzzVector
			#Go through the list of inputs with one specific vector
			formInputs.each_key do |link|
				testInput( false, link, agent, vector)
			end
		end
		#After parsing reset the vector count.
		vectorList.reset_count!
	end