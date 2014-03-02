
class displayResults

	#Creates the arrays that are needed to hold the links
	def self.displayInputs(links)
		puts "\n##########################################################################"
		puts "\tInputs via Links:"
		puts "##########################################################################"
		links.each do |key, value|
			puts "Base URL : "+key
			puts "Possible Inputs:"
			value.each do |input|
				puts input
			end
		end
	end

	def self.displayForms(forms)
		puts "\n##########################################################################"
		puts "\tInputs via Forms:"
		puts "##########################################################################"
		forms.each do |key, value|
			puts "Page URL: #{key.to_s}"
			value.each do |input|
				puts "\t Name: #{input.name} - Value: #{input.value}"
				puts "\t\tType: #{input.type}"
			end
		end
	end

	def self.displayCookies(cookies)
		puts "\n##########################################################################"
		puts "\tInputs via Cookies:"
		puts "##########################################################################"
		
		cookies.each do |cookie|
			puts "Name: #{cookie.name} \tDomain Name: "+cookie.domain+"\tValue = "+cookie.value
		end
	end
end