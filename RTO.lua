local rto_debug = true

-- By default DCS has the io and lfs libraries removed from the scripting engine as a security precaution. 
-- You can stop the game from doing this by modifying install/Scripts/missionScripting.lua. 
-- Simply comment out the two lines running the sanitizeModule function on io and lfs.

if io then
    local file = io.open(os.getenv("USERPROFILE") .. "\\Saved Games\\DCS.openbeta\\Tracks\\RTO-" .. os.date("%c"):gsub("/",""):gsub(" ","-"):gsub(":","") .. ".log", "w")
end

function Log(id,log,bool)
    if file then
        file:write("TIME:" .. timer.getAbsTime() .. " SHOTID:" .. id .. " LOG:" .. log .. "\n")
    end
    if rto_debug then
        trigger.action.outText(log,10,false)
    else
        if bool then
            trigger.action.outText(log,10,false)
        end
    end
end

id = 0

local AspectAngle = {
    QuickExit = 30,
    Drag      = 60,
    Beam      = 110,
    Flank     = 150,
    Hot       = 180
};

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

    function obj:valid(shot)
        return false
    end

    function obj:isTimeout(shot)
        return false
    end

    function obj:hasCriteria()
        return false
    end

    function obj:hasEnergy(shot)
        return false
    end

    function obj:altitudeCoefficient(alt)
        return (alt - 35000) * 2 / 10000
    end

    function obj:reactThreat(shot)
        return
    end

    function obj:quickExit(shot)
        return
    end

    return obj
end

function AAM_AIM120C()
    local obj = {}

    obj.RMAX     = 62
    obj.DOR      = 36
    obj.MAR      = 32
    obj.DR       = 27
    obj.STERNWEZ = 23

    obj.timeout  = 80
    obj.fQuickE  = false

    function obj:valid(shot)
        if shot:getShotRangeNm() <  self.STERNWEZ + shot:getTgtAltFactorNm() + shot:getShotAltFactorNm() then
            Log(shot:getID(), "RTO: Shot Val: Kill Confirmed: Shot Within STERNWEZ",false)
            return true
        end
        if shot:getShotRangeNm() >  self.RMAX     + shot:getTgtAltFactorNm() + shot:getShotAltFactorNm() then
            Log(shot:getID(), "RTO: Shot Val: Shot Trashed (Out of RMAX)",false)
            return false
        end
        if shot:getShotRangeNm() >  self.MAR      + shot:getTgtAltFactorNm() + shot:getShotAltFactorNm() then
            Log(shot:getID(), "RTO: Shot Val: Shot Inside RMAX Outside MAR",false)
            if self.fQuickE then
                Log(shot:getID(), "RTO: Shot Val: Shot Trashed (Quick Exit)",false)
                return false
            end
            if shot:getTargetAspectAngle() >= AspectAngle.Beam then
                Log(shot:getID(), "RTO: Shot Val: Kill Confirmed (Hotter than Beam)",false)
                return true
            else
                Log(shot:getID(), "RTO: Shot Val: Shot Trashed (At or Colder than Beam)",false)
                return false
            end
        end
        if shot:getShotRangeNm() >= self.DR       + shot:getTgtAltFactorNm() + shot:getShotAltFactorNm() then
            Log(shot:getID(), "RTO: Shot Val: Shot Outside DR",false)
            if shot:getTargetAspectAngle() >= AspectAngle.Beam then
                Log(shot:getID(), "RTO: Shot Val: Kill Confirmed (Hotter than Beam)",false)
                return true
            else
                Log(shot:getID(), "RTO: Shot Val: Shot Trashed (At or Colder than Beam)",false)
                return false
            end
        end
        if shot:getShotRangeNm() >= self.STERNWEZ + shot:getTgtAltFactorNm() + shot:getShotAltFactorNm() then
            Log(shot:getID(), "RTO: Shot Val: Shot Inside DR",false)
            if shot:getTargetAspectAngle() >= AspectAngle.Drag then
                Log(shot:getID(), "RTO: Shot Val: Kill Confirmed (Hotter than Drag)",false)
                return true
            else
                Log(shot:getID(), "RTO: Shot Val: Shot Trashed (Drag)",false)
                return false
            end
        end
    end

    function obj:isTimeout(shot)
        local t = timer.getTime() - shot:getShotTime()
        local d = 1029 * t - 10 * t * t / 2
        return d * feet_per_meter / feet_per_nm > shot:getTargetToShotPosDistance()
    end

    function obj:hasCriteria()
        return true
    end

    function obj:hasEnergy(shot)
        local t = timer.getTime() - shot:getShotTime()
        local d = 1029 - 10 * t
        return d > 343
    end

    function obj:altitudeCoefficient(alt)
        return (alt - 35000) * 2 / 10000
    end

    function obj:reactThreat(shot)
        return
    end

    function obj:quickExit(shot)
        if shot:getTargetAspectAngle() < AspectAngle.QuickExit then
            self.fQuickE = true;
        end
    end

    return obj
end

function AAM_AIM120()
    local obj = {}

    obj.RMAX     = 58
    obj.DOR      = 34
    obj.MAR      = 29
    obj.DR       = 25
    obj.STERNWEZ = 21

    obj.timeout  = 80 
    obj.fQuickE  = false

    function obj:valid(shot)
        if shot:getShotRangeNm() <  self.STERNWEZ + shot:getTgtAltFactorNm() + shot:getShotAltFactorNm() then
            Log(shot:getID(), "RTO: Shot Val: Kill Confirmed: Shot Within STERNWEZ",false)
            return true
        end
        if shot:getShotRangeNm() >  self.RMAX     + shot:getTgtAltFactorNm() + shot:getShotAltFactorNm() then
            Log(shot:getID(), "RTO: Shot Val: Shot Trashed (Out of RMAX)",false)
            return false
        end
        if shot:getShotRangeNm() >  self.MAR      + shot:getTgtAltFactorNm() + shot:getShotAltFactorNm() then
            Log(shot:getID(), "RTO: Shot Val: Shot Inside RMAX Outside MAR",false)
            if self.fQuickE then
                Log(shot:getID(), "RTO: Shot Val: Shot Trashed (Quick Exit)",false)
                return false
            end
            if shot:getTargetAspectAngle() >= AspectAngle.Beam then
                Log(shot:getID(), "RTO: Shot Val: Kill Confirmed (Hotter than Beam)",false)
                return true
            else
                Log(shot:getID(), "RTO: Shot Val: Shot Trashed (At or Colder than Beam)",false)
                return false
            end
        end
        if shot:getShotRangeNm() >= self.DR       + shot:getTgtAltFactorNm() + shot:getShotAltFactorNm() then
            Log(shot:getID(), "RTO: Shot Val: Shot Outside DR",false)
            if shot:getTargetAspectAngle() >= AspectAngle.Beam then
                Log(shot:getID(), "RTO: Shot Val: Kill Confirmed (Hotter than Beam)",false)
                return true
            else
                Log(shot:getID(), "RTO: Shot Val: Shot Trashed (At or Colder than Beam)",false)
                return false
            end
        end
        if shot:getShotRangeNm() >= self.STERNWEZ + shot:getTgtAltFactorNm() + shot:getShotAltFactorNm() then
            Log(shot:getID(), "RTO: Shot Val: Shot Inside DR",false)
            if shot:getTargetAspectAngle() >= AspectAngle.Drag then
                Log(shot:getID(), "RTO: Shot Val: Kill Confirmed (Hotter than Drag)",false)
                return true
            else
                Log(shot:getID(), "RTO: Shot Val: Shot Trashed (Drag)",false)
                return false
            end
        end
    end

    function obj:isTimeout(shot)
        local t = timer.getTime() - shot:getShotTime()
        local d = 1029 * t - 10 * t * t / 2
        return d * feet_per_meter / feet_per_nm > shot:getTargetToShotPosDistance()
    end

    function obj:hasCriteria()
        return true
    end

    function obj:hasEnergy(shot)
        local t = timer.getTime() - shot:getShotTime()
        local d = 1029 - 10 * t
        return d > 343
    end

    function obj:altitudeCoefficient(alt)
        return (alt - 35000) * 2 / 10000
    end

    function obj:reactThreat(shot)
        return
    end

    function obj:quickExit(shot)
        if shot:getTargetAspectAngle() < AspectAngle.QuickExit then
            self.fQuickE = true;
        end
    end

    return obj
end

function AAM_SD_10()
    local obj = {}

    obj.RMAX     = 54
    obj.DOR      = 32
    obj.MAR      = 27
    obj.DR       = 23
    obj.STERNWEZ = 19

    obj.timeout  = 80 
    obj.fQuickE  = false

    function obj:valid(shot)
        if shot:getShotRangeNm() <  self.STERNWEZ + shot:getTgtAltFactorNm() + shot:getShotAltFactorNm() then
            Log(shot:getID(), "RTO: Shot Val: Kill Confirmed: Shot Within STERNWEZ",false)
            return true
        end
        if shot:getShotRangeNm() >  self.RMAX     + shot:getTgtAltFactorNm() + shot:getShotAltFactorNm() then
            Log(shot:getID(), "RTO: Shot Val: Shot Trashed (Out of RMAX)",false)
            return false
        end
        if shot:getShotRangeNm() >  self.MAR      + shot:getTgtAltFactorNm() + shot:getShotAltFactorNm() then
            Log(shot:getID(), "RTO: Shot Val: Shot Inside RMAX Outside MAR",false)
            if self.fQuickE then
                Log(shot:getID(), "RTO: Shot Val: Shot Trashed (Quick Exit)",false)
                return false
            end
            if shot:getTargetAspectAngle() >= AspectAngle.Beam then
                Log(shot:getID(), "RTO: Shot Val: Kill Confirmed (Hotter than Beam)",false)
                return true
            else
                Log(shot:getID(), "RTO: Shot Val: Shot Trashed (At or Colder than Beam)",false)
                return false
            end
        end
        if shot:getShotRangeNm() >= self.DR       + shot:getTgtAltFactorNm() + shot:getShotAltFactorNm() then
            Log(shot:getID(), "RTO: Shot Val: Shot Outside DR",false)
            if shot:getTargetAspectAngle() >= AspectAngle.Beam then
                Log(shot:getID(), "RTO: Shot Val: Kill Confirmed (Hotter than Beam)",false)
                return true
            else
                Log(shot:getID(), "RTO: Shot Val: Shot Trashed (At or Colder than Beam)",false)
                return false
            end
        end
        if shot:getShotRangeNm() >= self.STERNWEZ + shot:getTgtAltFactorNm() + shot:getShotAltFactorNm() then
            Log(shot:getID(), "RTO: Shot Val: Shot Inside DR",false)
            if shot:getTargetAspectAngle() >= AspectAngle.Drag then
                Log(shot:getID(), "RTO: Shot Val: Kill Confirmed (Hotter than Drag)",false)
                return true
            else
                Log(shot:getID(), "RTO: Shot Val: Shot Trashed (Drag)",false)
                return false
            end
        end
    end

    function obj:isTimeout(shot)
        local t = timer.getTime() - shot:getShotTime()
        local d = 1029 * t - 10 * t * t / 2
        return d * feet_per_meter / feet_per_nm > shot:getTargetToShotPosDistance()
    end

    function obj:hasCriteria()
        return true
    end

    function obj:hasEnergy(shot)
        local t = timer.getTime() - shot:getShotTime()
        local d = 1029 - 10 * t
        return d > 343
    end

    function obj:altitudeCoefficient(alt)
        return (alt - 35000) * 2 / 10000
    end

    function obj:reactThreat(shot)
        return
    end

    function obj:quickExit(shot)
        if shot:getTargetAspectAngle() < AspectAngle.QuickExit then
            self.fQuickE = true;
        end
    end

    return obj
end

function AAM_P_77()
    local obj = {}

    obj.RMAX     = 42
    obj.DOR      = 25
    obj.MAR      = 21
    obj.DR       = 19
    obj.STERNWEZ = 15

    obj.timeout  = 80 
    obj.fQuickE  = false

    function obj:valid(shot)
        if shot:getShotRangeNm() <  self.STERNWEZ + shot:getTgtAltFactorNm() + shot:getShotAltFactorNm() then
            Log(shot:getID(), "RTO: Shot Val: Kill Confirmed: Shot Within STERNWEZ",false)
            return true
        end
        if shot:getShotRangeNm() >  self.RMAX     + shot:getTgtAltFactorNm() + shot:getShotAltFactorNm() then
            Log(shot:getID(), "RTO: Shot Val: Shot Trashed (Out of RMAX)",false)
            return false
        end
        if shot:getShotRangeNm() >  self.MAR      + shot:getTgtAltFactorNm() + shot:getShotAltFactorNm() then
            Log(shot:getID(), "RTO: Shot Val: Shot Inside RMAX Outside MAR",false)
            if self.fQuickE then
                Log(shot:getID(), "RTO: Shot Val: Shot Trashed (Quick Exit)",false)
                return false
            end
            if shot:getTargetAspectAngle() >= AspectAngle.Beam then
                Log(shot:getID(), "RTO: Shot Val: Kill Confirmed (Hotter than Beam)",false)
                return true
            else
                Log(shot:getID(), "RTO: Shot Val: Shot Trashed (At or Colder than Beam)",false)
                return false
            end
        end
        if shot:getShotRangeNm() >= self.DR       + shot:getTgtAltFactorNm() + shot:getShotAltFactorNm() then
            Log(shot:getID(), "RTO: Shot Val: Shot Outside DR",false)
            if shot:getTargetAspectAngle() >= AspectAngle.Beam then
                Log(shot:getID(), "RTO: Shot Val: Kill Confirmed (Hotter than Beam)",false)
                return true
            else
                Log(shot:getID(), "RTO: Shot Val: Shot Trashed (At or Colder than Beam)",false)
                return false
            end
        end
        if shot:getShotRangeNm() >= self.STERNWEZ + shot:getTgtAltFactorNm() + shot:getShotAltFactorNm() then
            Log(shot:getID(), "RTO: Shot Val: Shot Inside DR",false)
            if shot:getTargetAspectAngle() >= AspectAngle.Drag then
                Log(shot:getID(), "RTO: Shot Val: Kill Confirmed (Hotter than Drag)",false)
                return true
            else
                Log(shot:getID(), "RTO: Shot Val: Shot Trashed (Drag)",false)
                return false
            end
        end
    end

    function obj:isTimeout(shot)
        local t = timer.getTime() - shot:getShotTime()
        local d = 1029 * t - 10 * t * t / 2
        return d * feet_per_meter / feet_per_nm > shot:getTargetToShotPosDistance()
    end

    function obj:hasCriteria()
        return true
    end

    function obj:hasEnergy(shot)
        local t = timer.getTime() - shot:getShotTime()
        local d = 1029 - 10 * t
        return d > 343
    end

    function obj:altitudeCoefficient(alt)
        return (alt - 35000) * 2 / 10000
    end

    function obj:reactThreat(shot)
        return
    end

    function obj:quickExit(shot)
        if shot:getTargetAspectAngle() < AspectAngle.QuickExit then
            self.fQuickE = true;
        end
    end

    return obj
end

function AAM_P_27PE()
    local obj = {}

    obj.RMAX     = 39
    obj.DOR      = 25
    obj.MAR      = 13
    obj.DR       = 15
    obj.STERNWEZ = 9

    obj.timeout  = 80 
    obj.fQuickE  = false

    function obj:valid(shot)
        if shot:isMissileTrackingTgt() == false then
            Log(shot:getID(), "RTO: Shot Val: Shot Trashed (Ceased STT)",false)
            return false
        end
        if shot:getShotRangeNm() <  self.STERNWEZ + shot:getTgtAltFactorNm() + shot:getShotAltFactorNm() then
            Log(shot:getID(), "RTO: Shot Val: Kill Confirmed: Shot Within STERNWEZ",false)
            return true
        end
        if shot:getShotRangeNm() >  self.RMAX     + shot:getTgtAltFactorNm() + shot:getShotAltFactorNm() then
            Log(shot:getID(), "RTO: Shot Val: Shot Trashed (Out of RMAX)",false)
            return false
        end
        if shot:getShotRangeNm() >  self.MAR      + shot:getTgtAltFactorNm() + shot:getShotAltFactorNm() then
            Log(shot:getID(), "RTO: Shot Val: Shot Inside RMAX Outside MAR",false)
            if self.fQuickE then
                Log(shot:getID(), "RTO: Shot Val: Shot Trashed (Quick Exit)",false)
                return false
            end
            if shot:getTargetAspectAngle() >= AspectAngle.Beam then
                Log(shot:getID(), "RTO: Shot Val: Kill Confirmed (Hotter than Beam)",false)
                return true
            else
                Log(shot:getID(), "RTO: Shot Val: Shot Trashed (At or Colder than Beam)",false)
                return false
            end
        end
        if shot:getShotRangeNm() >= self.DR       + shot:getTgtAltFactorNm() + shot:getShotAltFactorNm() then
            Log(shot:getID(), "RTO: Shot Val: Shot Outside DR",false)
            if shot:getTargetAspectAngle() >= AspectAngle.Beam then
                Log(shot:getID(), "RTO: Shot Val: Kill Confirmed (Hotter than Beam)",false)
                return true
            else
                Log(shot:getID(), "RTO: Shot Val: Shot Trashed (At or Colder than Beam)",false)
                return false
            end
        end
        if shot:getShotRangeNm() >= self.STERNWEZ + shot:getTgtAltFactorNm() + shot:getShotAltFactorNm() then
            Log(shot:getID(), "RTO: Shot Val: Shot Inside DR",false)
            if shot:getTargetAspectAngle() >= AspectAngle.Drag then
                Log(shot:getID(), "RTO: Shot Val: Kill Confirmed (Hotter than Drag)",false)
                return true
            else
                Log(shot:getID(), "RTO: Shot Val: Shot Trashed (Drag)",false)
                return false
            end
        end
    end

    function obj:isTimeout(shot)
        local t = timer.getTime() - shot:getShotTime()
        local d = 1029 * t - 10 * t * t / 2
        return d * feet_per_meter / feet_per_nm > shot:getTargetToShotPosDistance()
    end

    function obj:hasCriteria()
        return true
    end

    function obj:hasEnergy(shot)
        local t = timer.getTime() - shot:getShotTime()
        local d = 1029 - 10 * t
        return d > 343
    end

    function obj:altitudeCoefficient(alt)
        return (alt - 20000) * 3/ 10000
    end

    function obj:reactThreat(shot)
        return
    end

    function obj:quickExit(shot)
        if shot:getTargetAspectAngle() < AspectAngle.QuickExit then
            self.fQuickE = true;
        end
    end

    return obj
end

function AGM_AGM_88()
    local obj = {}

    obj.RMAX     = 60
    obj.DOR      = 25
    obj.MAR      = 13
    obj.DR       = 15
    obj.STERNWEZ = 9

    obj.timeout  = 90 

    function obj:valid(shot)
        if shot:isMissileTrackingTgt() == false then
            Log(shot:getID(), "RTO: Shot Cal: Shot Trashed (HARM lost target)",false)
            return false
        end
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

        return tof > tot
    end

    function obj:hasCriteria()
        return true
    end

    function obj:hasEnergy(shot)
        return true
    end

    function obj:altitudeCoefficient(alt)
        return (alt - 35000) * 2 / 10000
    end

    function obj:reactThreat(shot)
        local con = shot:getControllerOfTargetGroup()
        local tot = (shot:getShotRangeNm() * self.timeout) / (self.RMAX + shot:getShotAltFactorNm())
        timer.scheduleFunction(ceaseSamRadar,  con, timer.getTime()       + math.random(14) + 16)
        timer.scheduleFunction(activeSamRadar, con, timer.getTime() + tot + math.random(30) - 15)
    end

    function obj:quickExit(shot)
        return
    end

    return obj
end

function Missile(w)
    -- trigger.action.outText(w:getTypeName(), 10, true)
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

    obj.weapon         = weapon
    obj.target         = weapon:getTarget()
    obj.targetCallsign = weapon:getTarget():getCallsign()
    obj.shotPosition   = weapon:getPosition().p

    obj.targetAspectAngle       = 180                   -- shot position to target aspect angle
    obj.targetAltitude          = 35000;                -- target altitude
    obj.targetToShotPosDistance = 99999;                -- target to shot position distance

    local l  = weapon:getLauncher():getPosition().p
    local t  = weapon:getTarget():getPosition().p

    obj.shotRange               = math.sqrt((l.x-t.x)^2 + (l.y-t.y)^2 + (l.z-t.z)^2) * feet_per_meter / feet_per_nm   -- shot range
    obj.shotAltitude            = l.y * feet_per_meter                                                                -- shot altitude
    obj.time = timer.getTime()                                                                                        -- shot time
    
    Log(obj.id, "RTO: Copy Shot " .. obj.weapon:getTypeName() .. " to " .. obj.targetCallsign,false)

    function obj:isTimeout()
        if self.target == nil then
            return false, false
        end
        if self.target:isExist() == false then
            return false, false
        end
        if self.missile:hasEnergy(self) == false then
            return false, false
        end
        if self.missile:isTimeout(self) then
            Log(self.id, "RTO: TimeOut " .. self.targetCallsign,false)
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
        local vw = self.weapon:getVelocity()     -- velocity    weapon
        local pw = self.weapon:getPosition().p   -- position    weapon
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

        local rh = (1 + (math.atan2(p.z,  p.x ) / math.pi)) * 180
        local oh = ((math.atan2(ot.z, ot.x) / math.pi)) * 180

        if oh < 0 then
            oh = oh + 360
        end
        
        local raa = 0
        
        if oh - rh < 180 then
            raa = - (oh - rh)
        else
            raa = 360 - (oh - rh)
        end
        
        self.targetAspectAngle = math.abs(raa)

        self.missile:quickExit(self)

        -- trigger.action.outText("TA : " .. string.format("%.0f",self.targetAltitude) .. " AA : " .. string.format("%.0f",self.targetAspectAngle),  1, true) 
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

    function obj:getControllerOfTargetUnit()
        if self.target == nil then
            return nil
        end
        if self.target:isExist() == false then
            return nil
        end
        return self.target:getController()
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

    function obj:getTargetAspectAngle()
        return self.targetAspectAngle
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
            Log(self.id, "RTO: Kill Confirmed " .. self.targetCallsign .. " " .. string.format("%.0f",self.targetAltitude/1000) .. "K",false)
            trigger.action.explosion(self.target:getPoint(), 100)
        else
            Log(self.id, "RTO: Shot Trashed " .. self.targetCallsign .. " " .. string.format("%.0f",self.targetAltitude/1000) .. "K" ,false)
        end
    end

    return obj
end

function RTO()
    local obj = {}
    
    obj.shot = {}

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

        id = id + 1
        
        self.shot[#self.shot + 1] = Shot(id, event.weapon, missile)

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

-- for i = 1, 100 do
--     timer.scheduleFunction(rto.calc,  rto, timer.getTime() + 0.01 * i)
-- end