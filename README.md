# DCS-World-Range-Training-Officer

The RTO(Range Training Officer) judges if a fighter was shot down or successfully defeated a missile during the Air Force BVR exercise.

In real-life Air to Air Combat training, Fighter pilots don't shoot a real missile but they call they've "shot" missile to the target, and RTO will judge if the target could evade the missile from various parameters: shot range, altitude, speed, and target aspect angle at the time TIMEOUT(predicted missile hit time).

DCS World is the most popular modern combat flight simulator, but there missiles guidance is too weak to replicate AFTTP based BVR, and its effective tactics often change every time they update and change missile flight model, guidance model, or beam/chaff resistance.

Therefore, I decided to script the DCS world BVR to explode a fighter who did not evade the missile properly...even if the missile was defeated in the DCS 3D world.

[![RTO Video](http://img.youtube.com/vi/M2QO_1vZEnE/0.jpg)](https://www.youtube.com/watch?v=M2QO_1vZEnE "RTO Video")

## Air to air training criteria

![image](https://user-images.githubusercontent.com/32677587/108588285-9d3bd000-739b-11eb-8d97-dfe63363faf6.png)

SOURCE: https://www.15wing.af.mil/News/Art/igphoto/2001719311/

You need to BEAM or be colder to the shooter at TIMEOUT(missile hit predicted time) to defeat the missile. You can't BEAM to defeat missile by notch-doppler and turn in to commit immediately. 

## How to apply the script to your mission

Set 2 Trigger:

1. ONCE              / TIME MORE (1) / DO SCRIPT FILE (RTO.lua)
2. REPETITIVE ACTION / TIME MORE (2) / DO SCRIPT (rto:calc())

![image](https://user-images.githubusercontent.com/32677587/108588342-028fc100-739c-11eb-91f5-9005a0f349cb.png)
![image](https://user-images.githubusercontent.com/32677587/108588374-2ce17e80-739c-11eb-9178-0698bc76e36c.png)
