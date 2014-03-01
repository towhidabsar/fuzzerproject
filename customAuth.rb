require 'rubygems'
require 'mechanize'

#to a given product. For this product, BodgeIt and DVWA are two 
#applications you must authenticate to. These can be hardcoded. You 
#are welcome to add other customizations for other products to test
# your fuzzer further (e.g. your senior project). With custom 
# authentication turned off, the fuzzer should just crawl the exterior
#  of the webapp (perhaps get lucky if the vector list had a password)
class CustomAuthentication
	def self.authenticate(agent, site)
		agent.get(site) do |page|
			puts page
			#login_page = agent.click(page.link_with(:text => site))
			case site
				when "http://127.0.0.1/dvwa"
					# Submit the login form
					login_form = page.form_with(:action => 'login.php')
					login_form.username = "admin"
					login_form.password = "password"
					agent.submit(login_form, login_form.buttons.first)

				when "http://127.0.0.1/bodgeit"
					login_page = agent.click(page.link_with(:text => /Login/))	
					login_form = login_page.form_with(:action => '/login.jsp')
					login_form.username = "test@thebodgeitstore.com"
					login_form.password = "password"
					agent.submit(login_form, login_form.buttons.first)
			end
		end
	end
end
