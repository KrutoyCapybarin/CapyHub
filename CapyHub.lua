--lattemode = true/false

gamelist = {
    BiteByNight = 70845479499574,
    PoopEatingSimulator = 69696969
}

codelist = {
    BiteByNight = "https://raw.githubusercontent.com/KrutoyCapybarin/CapyHub/refs/heads/main/BiteByNight/CapyHub_BiteByNight.lua",
    PoopEatingSimulator = nil
}

for key, id in pairs(gamelist) do
    if id == game.PlaceId and codelist[key] then
        loadstring(game:HttpGet(codelist[key]))()
        break
    end
end
