# DCS-World-Range-Training-Officer

The RTO(Range Training Officer) judges if a fighter was shot down or successfully defeated a missile during the Air Force BVR exercise.

In real-life Air to Air Combat training, Fighter pilots don't shoot a real missile but they call they've "shot" missile to the target, and RTO will judge if the target could evade the missile from various parameters: shot range, altitude, speed, and target aspect angle at the time TIMEOUT(predicted missile hit time).

DCS World is the most popular modern combat flight simulator, but there AA missiles guidance is too weak to replicate AFTTP based BVR, and its effective tactics often change every time they update and change missile flight model, guidance model, or beam/chaff resistance. Also HARM is too short ranged and too slow to replicate real life SEAD tactics like PETSHOT and REACTIVESHOT.

Therefore, I decided to script the DCS world BVR to explode a fighter who did not evade the missile properly...even if the missile was defeated in the DCS 3D world.

[![RTO Video](http://img.youtube.com/vi/M2QO_1vZEnE/0.jpg)](https://www.youtube.com/watch?v=M2QO_1vZEnE "RTO Video")

## Real Life Air to air training criteria

![image](https://user-images.githubusercontent.com/32677587/108588285-9d3bd000-739b-11eb-8d97-dfe63363faf6.png)

SOURCE: https://www.15wing.af.mil/News/Art/igphoto/2001719311/

You need to BEAM or be colder to the shooter at TIMEOUT(missile hit predicted time) to defeat the missile. You can't BEAM to defeat missile by notch-doppler and turn in to commit immediately. 

## Logic

- Calculate missile shot distance every seconds.
- If missile flow distance is longer than distance between missile shot position and the target, judge if the shot was valid or not.
- If shot longer than RMAX: shot invalid
- If shot longer than DR and inside RMAX: BEAM or colder to defeat
- If shot longer than STERNWEZ and inside DR: DRAG to defeat
- If shot within STERNWEZ: valid
- RMAX/DR/STERNWEZ range will increase/decrease by shot altitude and target altitude
- AGM-88 has 90 seconds of estimated TOF at RMAX
- SAMs will cease radar when shot by an AGM-88, then turn on the radar again after predicted HARM TOT.
- If missile speed go below Mach 1.0: invalid
- Explode the AI target if shot was valid.
- Husky and Timeout message will be shown to the launcher coalition.
- Kill received message will be shown to the target coalition if shot was valid.

||AIM-120C|AIM-120B|SD-10|R-77|R-27ER|AGM-88|
|-:|:-|:-|:-|:-|:-|:-|
|RMAX|62|58|54|42|42|62|
|DR|27|25|23|19|19|-|
|STERNWEZ|23|21|19|15|13|-|

at 35,000ft

## How to apply the script to your mission

Set 2 Trigger:

1. ONCE              / TIME MORE (1) / DO SCRIPT FILE (RTO.lua)
2. REPETITIVE ACTION / TIME MORE (2) / DO SCRIPT (rto:calc())

![image](https://user-images.githubusercontent.com/32677587/108588342-028fc100-739c-11eb-91f5-9005a0f349cb.png)
![image](https://user-images.githubusercontent.com/32677587/108588374-2ce17e80-739c-11eb-9178-0698bc76e36c.png)

## Log file save

Log files will be saved to Saved Games\DCS.openbeta\Tracks  
You have to edit DCS World OpenBeta/Scripts/missionScripting.lua and comment out lines as follows:
```Lua
do
-- sanitizeModule('os')
-- sanitizeModule('io')
-- sanitizeModule('lfs')
    require = nil
    loadlib = nil
end
```

## Future Update Plan

- AIM-7
(Should have more long range F-POLE)
- AIM-54
- MICA

## Tactics Manual

https://docs.google.com/document/d/1DKxkrI7vi0W4fuXPRrMhvBxJDxbBSI0SbWlbohdqjrY/edit?usp=sharing
