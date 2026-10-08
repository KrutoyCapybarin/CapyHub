--external_mode = true/false

local ok, t = pcall(os.date, "%H:%M:%S")
print(ok and t or "os.date() is not available", "CapyHub: HttpGet succeeded. Looking for the right script for your environment...")

local datamodel = game

local executor = (type(identifyexecutor) == "function" and identifyexecutor())
    or (type(getexecutorname) == "function" and getexecutorname())
    or "Unknown"

if external_mode == nil or external_mode == false then
    if executor == "Matcha" or executor == "CapyWare" then
        external_mode = true
    end
end

--[[ it is time to SHITCODE!!! 

d2lsbHlvdXdha2V1cHRvbW9ycm93d2lsbHlvdXdha2V1cHRvbW9ycm93d2lsbHlvdXdha2V1cHRvbW9ycm93d2lsbHlvdXdha2V1cHRvbW9ycm93d2lsbHlvdXdha2V1cHRvbW9ycm93
d2lsbHlvdXdha2V1cHRvbW9ycm93d2lsbHlvdXdha2V1cHRvbW9ycm93d2lsbHlvdXdha2V1cHRvbW9ycm93d2lsbHlvdXdha2V1cHRvbW9ycm93d2lsbHlvdXdha2V1cHRvbW9ycm93
d2lsbHlvdXdha2V1cHRvbW9ycm93d2lsbHlvdXdha2V1cHRvbW9ycm93d2lsbHlvdXdha2V1cHRvbW9ycm93d2lsbHlvdXdha2V1cHRvbW9ycm93d2lsbHlvdXdha2V1cHRvbW9ycm93
d2lsbHlvdXdha2V1cHRvbW9ycm93d2lsbHlvdXdha2V1cHRvbW9ycm93d2lsbHlvdXdha2V1cHRvbW9ycm93d2lsbHlvdXdha2V1cHRvbW9ycm93d2lsbHlvdXdha2V1cHRvbW9ycm93
d2lsbHlvdXdha2V1cHRvbW9ycm93d2lsbHlvdXdha2V1cHRvbW9ycm93d2lsbHlvdXdha2V1cHRvbW9ycm93d2lsbHlvdXdha2V1cHRvbW9ycm93d2lsbHlvdXdha2V1cHRvbW9ycm93
d2lsbHlvdXdha2V1cHRvbW9ycm93d2lsbHlvdXdha2V1cHRvbW9ycm93d2lsbHlvdXdha2V1cHRvbW9ycm93d2lsbHlvdXdha2V1cHRvbW9ycm93d2lsbHlvdXdha2V1cHRvbW9ycm93
d2lsbHlvdXdha2V1cHRvbW9ycm93d2lsbHlvdXdha2V1cHRvbW9ycm93d2lsbHlvdXdha2V1cHRvbW9ycm93d2lsbHlvdXdha2V1cHRvbW9ycm93d2lsbHlvdXdha2V1cHRvbW9ycm93
d2lsbHlvdXdha2V1cHRvbW9ycm93d2lsbHlvdXdha2V1cHRvbW9ycm93d2lsbHlvdXdha2V1cHRvbW9ycm93d2lsbHlvdXdha2V1cHRvbW9ycm93d2lsbHlvdXdha2V1cHRvbW9ycm93
d2lsbHlvdXdha2V1cHRvbW9ycm93d2lsbHlvdXdha2V1cHRvbW9ycm93d2lsbHlvdXdha2V1cHRvbW9ycm93d2lsbHlvdXdha2V1cHRvbW9ycm93d2lsbHlvdXdha2V1cHRvbW9ycm93
d2lsbHlvdXdha2V1cHRvbW9ycm93d2lsbHlvdXdha2V1cHRvbW9ycm93d2lsbHlvdXdha2V1cHRvbW9ycm93d2lsbHlvdXdha2V1cHRvbW9ycm93d2lsbHlvdXdha2V1cHRvbW9ycm93
d2lsbHlvdXdha2V1cHRvbW9ycm93d2lsbHlvdXdha2V1cHRvbW9ycm93d2lsbHlvdXdha2V1cHRvbW9ycm93d2lsbHlvdXdha2V1cHRvbW9ycm93d2lsbHlvdXdha2V1cHRvbW9ycm93
]]

--[[ i didnt fkin know that game.PlaceId IsA number value]]

BiteByNight = 70845479499574
BiteByDaylight = 129117145449630

TowerOfHell = 1962086868
ProTowerOfHell = 3582763398
THETowerOfHell = 94971861814985
TowerOfAppeals = 5253186791
TowerOfTakeover = 7227293156

--[[ external loaders ]]
if datamodel.PlaceId == BiteByNight and external_mode == true then
    loadstring(datamodel:HttpGet("https://raw.githubusercontent.com/KrutoyCapybarin/CapyHub/main/BiteByNight/CapyHub_BiteByNight_external.lua"))()
    print("CapyHub: BiteByNight External Script loaded successfully.")
end
if datamodel.PlaceId == BiteByDaylight and external_mode == true then
    loadstring(datamodel:HttpGet("https://raw.githubusercontent.com/KrutoyCapybarin/CapyHub/main/BiteByNight/CapyHub_BiteByNight_external.lua"))()
    print("CapyHub: BiteByDaylight External Script loaded successfully.")
end


--[[ i HATE TowerOfHell so much, i will never play it again, but i will make a script for it because my schizophrenic hallucination told me. ]]
if datamodel.PlaceId == TowerOfHell and external_mode == true then
    loadstring(datamodel:HttpGet("https://raw.githubusercontent.com/KrutoyCapybarin/CapyHub/main/TowerOfHell/CapyHub_TowerOfHell_external.lua"))()
    print("CapyHub: TowerOfHell External Script loaded successfully.")
end
if datamodel.PlaceId == ProTowerOfHell and external_mode == true then
    loadstring(datamodel:HttpGet("https://raw.githubusercontent.com/KrutoyCapybarin/CapyHub/main/TowerOfHell/CapyHub_TowerOfHell_external.lua"))()
    print("CapyHub: TowerOfHell External Script loaded successfully.")
end
if datamodel.PlaceId == THETowerOfHell and external_mode == true then
    loadstring(datamodel:HttpGet("https://raw.githubusercontent.com/KrutoyCapybarin/CapyHub/main/TowerOfHell/CapyHub_TowerOfHell_external.lua"))()
    print("CapyHub: TowerOfHell External Script loaded successfully.")
end
if datamodel.PlaceId == TowerOfAppeals and external_mode == true then --[[ idk why would you play TowerOfAppeals but ]]
    loadstring(datamodel:HttpGet("https://raw.githubusercontent.com/KrutoyCapybarin/CapyHub/main/TowerOfHell/CapyHub_TowerOfHell_external.lua"))()
    print("CapyHub: TowerOfHell External Script loaded successfully.")
end
if datamodel.PlaceId == TowerOfTakeover and external_mode == true then --[[ idk how CAN you play TowerOfTakeover since its not available but ]]
    loadstring(datamodel:HttpGet("https://raw.githubusercontent.com/KrutoyCapybarin/CapyHub/main/TowerOfHell/CapyHub_TowerOfHell_external.lua"))()
    print("CapyHub: TowerOfHell External Script loaded successfully.")
end
