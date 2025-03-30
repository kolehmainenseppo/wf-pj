package.path = package.path .. ";" .. string.match(({reaper.get_action_context()})[2], "(.-)([^\\/]-%.?([^%.\\/]*))$") .. "?.lua"
local pj = require "PresetinJuilauttaja"
local tracks = require "Tracks"

pj.createSplit(tracks.NUC_Strings, tracks.OMNI_Choir_1oct,62)
