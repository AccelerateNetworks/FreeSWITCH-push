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
        c = split(components[1], "/") --might need to max this at 2?
        if (c[1] == "error") then
                return nil
        end
        args = {}
        for i, component in ipairs(components) do
                if (i = 0) then end
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
        if (len(c) > 1) then
                if (len(c) > 2) then
                        out[uri] = c[2]
                end
                out[profile] = c[1]
        end
end


api = freeswitch.API();
local fb = require('firebase'):new({PROJECT_FN = "/var/firebase/firebase-session.json", PROJECT_ID="accelerate-networks"})                   
fb.auth:auth_service_account('/etc/firebase/google-account.json')
contacts = split(api:executeString("sofia_contact " .. session:getVariable("destination_number") .. "@" .. session:getVariable("domain_name")), ",")

session:consoleLog("err", len(contacts))
if contacts then

        for i, contact_info in pairs(contacts) do
                delay = 0
                contact = parse_contact(contact_info)
                if (contact and contact[args] and contact[args][pn-type]) then                                                               
                        args = contact[args]
                        if (args[pn-type] == "firebase" and args[pn-tok]) then                                                               
                                fb.messaging:send({
                                        to = args[pn-tok],
                                        priority = "high"
                                })
                        end
                end
        end
end

