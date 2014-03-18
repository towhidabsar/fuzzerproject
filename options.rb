class Options
	def self.fuzzTest(agent, mainURL, cmdLineOptions) 
		#Get all the required command line options
		customAuth = cmdLineOptions[0]
		vectorFile = cmdLineOptions[1]
		sensitiveFile = cmdLineOptions[2]
		puts sensitiveFile
		random = cmdLineOptions[3]
		@slow = cmdLineOptions[4]
	end
end