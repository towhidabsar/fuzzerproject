#Discovers all the inputs in the page.
def inputDiscover(page)
	#Get the URL of the current page.
	url = page.link.uri
	url = url.to_s
	url = url.split('?')
	puts "AA"
	link = url[0]
	puts link
	input = url[1]
	if not $filteredInputs.has_key? link
		$filteredInputs[link] = Array.new
	end
	if url.length > 1
		input = input.split('&')
		input.each do |x|
			$filteredInputs[link] << x
		end
	end
	#Get all the form parameters of the page
	inputForms = page.forms
	$filteredInputs[link] << inputForms
end