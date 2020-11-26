function split (inputstr, sep)
	if (sep == nil) then
		sep = "%s"
	end
	local t={}
	for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
		table.insert(t, str)
	end
	return t
end

function len (array)
	count = 0
	for Index, Value in pairs(array) do
		count = count + 1
	end
	return count
end


function parse_contact (unparsed)
	components = split(unparsed, ";")
	c = split(components[1], "/")
	if (c[1] == "error") then
		return nil
	end
	args = {}
	for i, component in ipairs(components) do
		if (i == 0) then
		elseif (string.find(component,"=")) then
			parts = split(component, "=")
			args[parts[1]] = parts[2]
		end
	end
	out = {
		args = args,
		profile = nil,
		uri = nil
	}
--[[	if (len(c) > 1) then
		if (len(c) > 2) then
			out[uri] = c[2]
		end
		out[profile] = c[1]
	end]]-- disabled due to errors and not needed
	return out
end

sentCount=0
api = freeswitch.API();
local fb = require('firebase'):new({PROJECT_FN = "/var/firebase/firebase-session.json", PROJECT_ID="accelerate-networks"})                   
fb.auth:auth_service_account('/etc/firebase/google-account.json')
contacts = split(api:executeString("sofia_contact " .. session:getVariable("destination_number") .. "@" .. session:getVariable("domain_name")), ",")
if contacts then
	for i, contact_info in pairs(contacts) do
		delay = 0
		contact = parse_contact(contact_info)
		if (contact) then
			if (contact["args"] and contact["args"]["pn-type"] and contact["args"]["pn-type"] == "firebase" and contact["args"]["pn-tok"]) then
				fb.messaging:send({
					message = {
						token = contact["args"]["pn-tok"],                                                           
						android = {
							priority = "HIGH"                                                                    
						}
					}
				})
				sentCount = sentCount + 1
				if delay < 2000 then
					delay = 2000
				end
			end
		end
	end
end
session:execute("sleep", delay)
session:consoleLog("info", "Sent push notifaction to " .. sentCount .. " device(s)") 
