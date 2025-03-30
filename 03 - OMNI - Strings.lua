package.path = package.path .. ";" .. string.match(({reaper.get_action_context()})[2], "(.-)([^\\/]-%.?([^%.\\/]*))$") .. "?.lua"
local pj = require "PresetinJuilauttaja"
local tracks = require "Tracks"

pj.useTracks(tracks.OMNI_Strings)
