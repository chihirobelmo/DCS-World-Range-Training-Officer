local rto_debug = false

-- By default DCS has the io and lfs libraries removed from the scripting engine as a security precaution. 
-- You can stop the game from doing this by modifying install/Scripts/missionScripting.lua. 
-- Simply comment out the two lines running the sanitizeModule function on io and lfs.

if io then
    file = io.open(os.getenv("USERPROFILE") .. "\\Saved Games\\DCS.openbeta\\Tracks\\RTO-" .. os.date("%c"):gsub("/",""):gsub(" ","-"):gsub(":","") .. ".csv", "w")
    if file then
        file:write("TIME" .. ",SHOTID" .. ",LOG" .. "\n")
    end
end

function Log(id,log,coalition)
    if file then
        file:write(timer.getAbsTime() .. "," .. id .. "," .. log .. "\n")
    end
    if rto_debug then
        trigger.action.outText("ID:" .. id .. ", LOG: " .. log,10,false)
    else
        if coalition then
            if coalition == 0 then
                trigger.action.outTextForCoalition(0,"ID:" .. id .. ", LOG: " .. log,10,false)
            elseif coalition == 1 then
                trigger.action.outTextForCoalition(1,"ID:" .. id .. ", LOG: " .. log,10,false)
            elseif coalition == 2 then
                trigger.action.outTextForCoalition(2,"ID:" .. id .. ", LOG: " .. log,10,false)
            else
                return
            end
        end
    end
end

local feet_per_meter = 3.28084
local feet_per_nm    = 6000
local ms_per_mach    = 343

function ceaseSamRadar(con)
    con:setOption(AI.Option.Ground.id.ALARM_STATE, AI.Option.Ground.val.ALARM_STATE.GREEN)
end

function activeSamRadar(con)
    con:setOption(AI.Option.Ground.id.ALARM_STATE, AI.Option.Ground.val.ALARM_STATE.AUTO)
end

function AAM_NULL()
    local obj = {}

    function obj:hasCriteria()
        return false
    end

    return obj
end

function AAM_ARH()
    local obj = {}

    obj.guiding  = true
    obj.husky    = false

    obj.topSpeed    = 1543
    obj.speedReduce = 10
    obj.huskyRange  = 20
    obj.altMach     = 2

    function obj:valid(shot)
        if self.husky == false then
            Log(shot:getID(), "RTO: Shot Val: Ceased guidance before Husky",false)
            return false
        end
        return true
    end

    function obj:getEnergy(shot)
        local t = timer.getTime() - shot:getShotTime()
        local m = self.topSpeed + 343 * shot:getShotAltFactorNm()
        local d = m * t - self.speedReduce * t * t / 2
        local s = m - self.speedReduce * t
        return s, d
    end

    function obj:checkGuidance(shot)
        if self.guiding == false then
            return
        end
        if self.husky == true then
            return
        end
        if shot:isMissileTrackingTgt() == false then
            Log(shot:getID(), "RTO: Guidance Stop",false)
            self.guiding = false
        end
    end

    function obj:isHusky(shot)
        if self.guiding == false then
            return
        end
        if self.husky == true then
            return
        end
        local s, d = self:getEnergy(shot)
        if shot:getTargetToShotPosDistance() - (d * feet_per_meter / feet_per_nm) < 20 then
            if self.guiding == true then
                Log(shot:getID(), "RTO: " .. shot:getLauncherCallsign() .. " Husky",shot:getLauncherCoalition())
                Log(shot:getID(), "RTO: " .. shot:getTargetCallsign() .. " Spiked",shot:getTargetCoalition())
                self.husky = true
                shot:destroy()
            end
        end
    end

    function obj:isTimeout(shot)
        local s, d = self:getEnergy(shot)
        if d * feet_per_meter / feet_per_nm > shot:getTargetToShotPosDistance() then
            Log(shot:getID(), "RTO: " .. shot:getLauncherCallsign() .. " TimeOut",shot:getLauncherCoalition())
            Log(shot:getID(), "RTO: " .. shot:getTargetCallsign() .. " Naked",shot:getTargetCoalition())
            return true
        else
            return false
        end
    end

    function obj:hasEnergy(shot)
        local s, d = self:getEnergy(shot)
        if s > 343 * 0.9 then
            return true
        else
            Log(shot:getID(), "RTO: " .. shot:getTargetCallsign() .. " Naked",shot:getTargetCoalition())
            return false
        end
    end

    function obj:hasCriteria()
        return true
    end

    function obj:altitudeCoefficient(alt)
        return (alt - 35000) / 10000
    end

    function obj:reactThreat(shot)
        return
    end

    return obj
end

function AAM_AIM120C()
    local obj = AAM_ARH()

    obj.topSpeed    = 1543
    obj.speedReduce = 10
    obj.huskyRange  = 20

    return obj
end

function AAM_AIM120()
    local obj = AAM_ARH()

    obj.topSpeed    = 1372
    obj.speedReduce = 10
    obj.huskyRange  = 20
    
    return obj
end

function AAM_SD_10()
    local obj = AAM_ARH()

    obj.topSpeed    = 1200
    obj.speedReduce = 10
    obj.huskyRange  = 20
    
    return obj
end

function AAM_P_77()
    local obj = AAM_ARH()

    obj.topSpeed    = 1029
    obj.speedReduce = 10
    obj.huskyRange  = 20
    
    return obj
end

function AAM_P_27PE()
    local obj = AAM_ARH()

    obj.topSpeed    = 1029
    obj.speedReduce = 10
    obj.huskyRange  = 20

    function obj:valid(shot)
        if shot:isMissileTrackingTgt() == false then
            Log(shot:getID(), "RTO: Shot Val: Shot Trashed (Ceased STT)",false)
            return false
        end
    end

    function obj:checkGuidance(shot)
        return
    end

    function obj:isHusky(shot)
        return false
    end

    return obj
end

function AGM_AGM_88()
    local obj = AAM_ARH()

    obj.timeout = 90
    obj.RMAX    = 60

    function obj:valid(shot)
        if shot:isTargetRadarActive() == false then
            Log(shot:getID(), "RTO: Shot Cal: Shot Trashed (Target ceasing radar emission)",false)
            return false
        end
        if shot:getShotRangeNm() > self.RMAX + shot:getShotAltFactorNm() then
            Log(shot:getID(), "RTO: Shot Cal: Shot Trashed (Out of RMAX)",false)
            return false
        end
        return true
    end

    function obj:isTimeout(shot)
        if (timer.getTime() - shot:getShotTime()) % 10 < 1 then
            Log(shot:getID(), "RTO: HARM TOF " .. string.format("%.0f",timer.getTime() - shot:getShotTime()),false)
        end

        local tof  = (timer.getTime() - shot:getShotTime())
        local tot  = (shot:getShotRangeNm() * self.timeout) / (self.RMAX + shot:getShotAltFactorNm())

        if tof > tot then
            Log(shot:getID(), "RTO: " .. shot:getLauncherCallsign() .. " TimeOut HARM",shot:getLauncherCoalition())
            return true
        else
            return false
        end
    end

    function obj:checkGuidance(shot)
        return
    end

    function obj:isHusky(shot)
        return false
    end

    function obj:hasEnergy(shot)
        return true
    end

    function obj:reactThreat(shot)
        local con = shot:getControllerOfTargetGroup()
        local tot = (shot:getShotRangeNm() * self.timeout) / (self.RMAX + shot:getShotAltFactorNm())
        timer.scheduleFunction(ceaseSamRadar,  con, timer.getTime()       + math.random(14) + 16)
        timer.scheduleFunction(activeSamRadar, con, timer.getTime() + tot + math.random(30) - 15)
    end

    return obj
end

function Missile(w)
    if     w:getTypeName() == "AIM_120C" then
        return AAM_AIM120C()
    elseif w:getTypeName() == "AIM_120"  then
        return AAM_AIM120()
    elseif w:getTypeName() == "P_77"     then
        return AAM_P_77() 
    elseif w:getTypeName() == "SD-10"    then
        return AAM_SD_10() 
    elseif w:getTypeName() == "P_27PE"   then
        return AAM_P_27PE()
    elseif w:getTypeName() == "AGM_88"   then
        return AGM_AGM_88()
    else
        return AAM_NULL()
    end
end

function Shot(id,weapon,missile)
    local obj = {}

    obj.id      = id
    obj.missile = missile

    obj.weapon            = weapon
    obj.launcher          = weapon:getLauncher()
    obj.launcherCallsign  = weapon:getLauncher():getCallsign()
    obj.launcherCoalition = weapon:getLauncher():getCoalition()
    obj.target            = weapon:getTarget()
    obj.targetCallsign    = weapon:getTarget():getCallsign()
    obj.targetCoalition   = weapon:getTarget():getCoalition()
    obj.shotPosition      = weapon:getPosition().p

    obj.isTargetAi = obj.target:getPlayerName() == nil

    obj.targetAltitude          = 35000;                -- target altitude
    obj.targetToShotPosDistance = 99999;                -- target to shot position distance

    local l  = weapon:getLauncher():getPosition().p
    local t  = weapon:getTarget():getPosition().p

    obj.shotRange    = math.sqrt((l.x-t.x)^2 + (l.y-t.y)^2 + (l.z-t.z)^2) * feet_per_meter / feet_per_nm   -- shot range
    obj.shotAltitude = l.y * feet_per_meter                                                                -- shot altitude
    obj.time         = timer.getTime()                                                                     -- shot time
    
    Log(obj.id, "RTO: Copy Shot " .. obj.weapon:getTypeName() .. " to " .. obj.targetCallsign,false)

    function obj:isTimeout()
        if self.target == nil then
            Log(self.id, "RTO: Trashed Target:" .. self.targetCallsign .. " (Target is nil)",false)
            return false, false
        end
        if self.target:isExist() == false then
            Log(self.id, "RTO: Trashed Target:" .. self.targetCallsign .. " (Target does not exist)",false)
            return false, false
        end
        if self.missile:hasEnergy(self) == false then
            Log(self.id, "RTO: TimeOut Target:" .. self.targetCallsign .. " (Missile has no Energy)",false)
            return false, false
        end
        if self.missile:isTimeout(self) then
            Log(self.id, "RTO: TimeOut Target:" .. self.targetCallsign,true)
            return true, false
        end
        return false, true
    end

    function obj:update()
        if self.weapon == nil then
            return
        end
        if self.weapon:isExist() == false then
            return
        end
        if self.target == nil then
            return
        end
        if self.target:isExist() == false then
            return
        end

        local ps = self.shotPosition             -- position    shot
        local pt = self.target:getPosition().p   -- position    target
        local ot = self.target:getVelocity()     -- orientation target

        self.targetAltitude   = pt.y * feet_per_meter

        -- aspect angle from shot position to the target
        local p = {
            x = ps.x - pt.x,
            y = ps.y - pt.y,
            z = ps.z - pt.z
        }

        self.targetToShotPosDistance = math.sqrt(p.x^2 + p.y^2 + p.z^2) * feet_per_meter / feet_per_nm

        self.missile:checkGuidance(self)

        self.missile:isHusky(self)
    end

    function obj:destroy()
        if self.weapon == nil then
            return false
        end
        if self.weapon:isExist() == false then
            return false
        end
        self.weapon:destroy()
    end

    function obj:getLauncherCoalition()
        return self.launcherCoalition
    end

    function obj:getLauncherCallsign()
        return self.launcherCallsign
    end

    function obj:getTargetCoalition()
        return self.targetCoalition
    end

    function obj:getTargetCallsign()
        return self.targetCallsign
    end

    function obj:getTargetToShotPosDistance()
        return self.targetToShotPosDistance
    end
    
    function obj:reactThreat()
        self.missile:reactThreat(self)
    end

    function obj:getControllerOfTargetGroup()
        if self.target == nil then
            return nil
        end
        if self.target:isExist() == false then
            return nil
        end
        return self.target:getGroup():getController()
    end

    function obj:isMissileTrackingTgt()
        if self.weapon == nil then
            return false
        end
        if self.weapon:isExist() == false then
            return false
        end
        return self.weapon:getTarget() ~= nil
    end

    function obj:isTargetRadarActive()
        if self.weapon == nil then
            return
        end
        if self.weapon:isExist() == false then
            return
        end
        if self.weapon:getTarget() == nil then
            return
        end
        if self.weapon:getTarget():isExist() == false then
            return
        end
        local b, t = self.weapon:getTarget():getRadar()
        return b
    end

    function obj:getID()
        return self.id
    end

    function obj:getShotTime()
        return self.time
    end

    function obj:getShotRangeNm()
        return self.shotRange
    end

    function obj:getTgtAltFactorNm()
        return self.missile:altitudeCoefficient(self.targetAltitude)
    end

    function obj:getShotAltFactorNm()
        return self.missile:altitudeCoefficient(self.shotAltitude)
    end

    function obj:valid()
        if self.target == nil then
            return
        end
        if self.target:isExist() == false then
            return
        end
        if obj.missile:valid(self) == true then
            Log(self.id, "RTO: Kill Confirmed " .. self.targetCallsign .. " " .. string.format("%.0f",self.targetAltitude/1000) .. "K",self.targetCoalition)
            if self.isTargetAi == true then
                trigger.action.explosion(self.target:getPoint(), 100)
            end
        else
            Log(self.id, "RTO: Shot Trashed " .. self.targetCallsign .. " " .. string.format("%.0f",self.targetAltitude/1000) .. "K" ,false)
        end
    end

    return obj
end

function RTO()
    local obj = {}
    
    obj.shot = {}
    obj.id   = 0

    function obj:onEvent(event)
        if event.id ~= world.event.S_EVENT_SHOT then
            return
        end
        if event.weapon == nil then
            return
        end
        if event.weapon:getLauncher() == nil then
            return
        end
        if event.weapon:getTarget() == nil then
            return
        end

        local missile = Missile(event.weapon)

        -- trigger.action.outText(event.weapon:getTypeName(),10,true)

        if missile:hasCriteria() == false then
            return
        end

        obj.id = obj.id + 1
        
        self.shot[#self.shot + 1] = Shot(obj.id, event.weapon, missile)

        self.shot[#self.shot]:reactThreat()
    end
    
    function obj:calc()
        for i,track in pairs(self.shot) do
            local to, exist = track:isTimeout()
            if to then
                self.shot[i]:valid()
                table.remove(self.shot, i)
            else
                if exist then
                    self.shot[i]:update()
                else
                    table.remove(self.shot, i)
                end
            end
        end
    end
    
    return obj
end

rto = RTO()

world.addEventHandler(rto)