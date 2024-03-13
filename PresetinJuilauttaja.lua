package.path = package.path .. ";" .. string.match(({reaper.get_action_context()})[2], "(.-)([^\\/]-%.?([^%.\\/]*))$") .. "?.lua"
local tracks = require "Tracks"

-- Consts

local MUTED   = true
local UNMUTED = false

local SPLIT_NOTE = 60

local COLOR      = {}
COLOR.RED        = {255, 0, 0}
COLOR.GREEN      = {0, 255, 0}
COLOR.BLUE       = {11, 139, 244}
COLOR.GREY       = {138, 138, 138}
COLOR.LIGHT_BLUE = {128, 201, 255}

-- Functions

local function log(msg)
    -- Uncomment this for debugging
    -- reaper.ShowConsoleMsg(msg .. "\n")
end

local function getTrackByName(trackName)
    for i = 0, reaper.CountTracks(0) - 1 do
        local track = reaper.GetTrack(0, i)
        local _, currentTrackName = reaper.GetSetMediaTrackInfo_String(track, "P_NAME", "", false)
        if currentTrackName == trackName then
            return track
        end
    end
    return nil
end

function setTrackColor(track, rgbcolor)
    if track then
        local nativeColor = reaper.ColorToNative(rgbcolor[1], rgbcolor[2] , rgbcolor[3])|0x1000000
        reaper.SetMediaTrackInfo_Value(track, "I_CUSTOMCOLOR", nativeColor)
    end
end

local function setTrackMuteState(trackName, muteState)
    local track = getTrackByName(trackName)
    if track then
        local logMsg = muteState and "Muting track" or "Unmuting track"
        log(logMsg .. ": " .. trackName)
        
        if muteState == MUTED then
            -- Set MIDI Note Filter to block all notes
            reaper.TrackFX_SetParam(track, 0, 0, 127)
            reaper.TrackFX_SetParam(track, 0, 1, 0)
        end

        -- Set MIDI Note Filter Enabled/Disabled depending on muteState
        reaper.TrackFX_SetEnabled(track, 0, muteState)

        -- Set track color
        setTrackColor(track, (not muteState) and COLOR.GREEN or COLOR.GREY)

        -- Arm for recording just to be safe
        reaper.SetMediaTrackInfo_Value(track, "I_RECARM", 1)
    end
end

local function muteTrack(trackName)
   setTrackMuteState(trackName, MUTED)
end

local function unmuteTrack(trackName)
    setTrackMuteState(trackName, UNMUTED)
end

local function makeTrackLowerSplit(trackName)
    local track = getTrackByName(trackName)
    if track then 
        reaper.TrackFX_SetEnabled(track, 0, MUTED)
        
        -- Set MIDI Note Filter to pass notes from 0 to SPLIT_NOTE
        reaper.TrackFX_SetParam(track, 0, 0, 0)
        reaper.TrackFX_SetParam(track, 0, 1, SPLIT_NOTE)
        
        setTrackColor(track, COLOR.BLUE)
    end
end

local function makeTrackUpperSplit(trackName)
    local track = getTrackByName(trackName)
    if track then 
        reaper.TrackFX_SetEnabled(track, 0, MUTED)
        
        -- Set MIDI Note Filter to pass notes from SPLIT_NOTE to 127
        reaper.TrackFX_SetParam(track, 0, 0, SPLIT_NOTE + 1)
        reaper.TrackFX_SetParam(track, 0, 1, 127)

        setTrackColor(track, COLOR.LIGHT_BLUE)
    end
end

local function contains(tab, val)
    for _, value in pairs(tab) do
        if value == val then
            return true
        end
    end
    return false
end

-- Gets n number of trackNames, unmutes those, and mutes others
local function useTracks(...)
    for _, val in pairs(tracks) do
        if contains({...}, val) then
            unmuteTrack(val)
        else
            muteTrack(val) 
        end
    end
end

-- Gets 2 trackNames and creates a split from them
local function createSplit(lowerTrack, upperTrack)
    makeTrackLowerSplit(lowerTrack)
    makeTrackUpperSplit(upperTrack)

    for _, val in pairs(tracks) do
        if val ~= lowerTrack and val ~= upperTrack  then
            muteTrack(val)    
        end
    end
end

-- Module export

local moduleExport = {}
moduleExport.useTracks = useTracks
moduleExport.createSplit = createSplit

return moduleExport
