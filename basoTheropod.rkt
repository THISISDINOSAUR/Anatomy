#lang anatomy

//baso-theropod based on Herrerasaurus ischiguanlastensis
//"The classic achaidc theropod"

Parameters = {
	test: 0.2 > < 1.8 = 0.43
}

//hips start
illium = [0,0], [-115, 24], [-81, -89], [40, -135], [90, -111], [100, -75], [28, -48], [84, -14]

pubis = [-22, 4], [-53,26], [-156, 30], [-204, 2], [-209, 63], [-132, 113], [-102, 67], [-35, 60], [-10, 86]
illium~pubis = average(0,last) ~ average(3,4), 70

ischium = [-2, 45], [-74, 3], [-98, 53], [-127, 69], [-213, 69], [-244, 71], [-230, 92], [-209, 83], [-118, 83], [-85, 97], [-67, 96]
illium~ischium = average(0,1) ~ average(0,1), -40

sacrum = [-7, 0], [-127, 2], [-107, 162], [-109, 166], [-2, 178]
illium~sacrum = average(0,1,2,3) ~ average(all), -22
//hips end

//back leg start
femur = [-35, 3], [-76, 20], [-235, 28], [-284, 7], [-308, 26], [-311, 48], [-310, 68], [-287, 95], [-257, 80], [-60, 77], [-32, 93], [-13, 81], [-3, 45]
illium~femur = average(0,0,1,last) ~ average(0,10), -110

tibiaFibula = [-37, 1], [-61, 12], [-110, 16], [-200, 12], [-239, 6], [-238, 17], [-231, 35], [-233, 50], [-224, 80], [-186, 74], [-72, 83], [-36, 95], [-16, 94], [-8, 80], [-21, 42], [-26, 16]
femur~tibiaFibula = 5 ~ 14, 25

backFoot = [-79, 0], [-153, 7], [-137, 32], [-139, 74], [-68, 74], [-5, 68], [-23, 42], [-54, 37]
tibiaFibula~backFoot = 6 ~ average(0,1), 90
//back leg end

//body start
dorsalSpine = [-9, 9], [-336, 3], [-643, 71], [-555, 215], [-307, 139], [0, 139]
sacrum~dorsalSpine = average(0, last) ~ average(2,3), 22

dorsalRibs = [-17, 28], [-137, 10], [-278, 6], [-536, 63], [-515, 193], [-411, 331], [-275, 375], [-42, 304], [0, 173]
dorsalSpine~dorsalRibs = [-276, 13] ~ 2, 0

scapula = [-146.22, 38.765, 0], [-178.84, 23.12, 0], [-197.22, 23.12, 0], [-218.283, 55.085, 0], [-203.322, 91.81, 0], [-165.922, 91.12, 0], [-153.68, 82.28, 0], [-61.88, 80.92, 0], [-25.843, 90.441, 0], [-2.72, 117.641, 0], [12.922, 113.56, 0], [28.562, 87.04, 0], [17.0, 38.085, 0], [17.68, 24.48, 0], [-3.4004, 6.801, 0], [-30.6, 3.4004, 0], [-57.804, 21.76, 0], [-56.445, 36.04, 0], [-61.2, 43.52, 0]
dorsalSpine~scapula = [-194.5, 94] ~ average(1,4), 46.84

coracoid = [-10.21, 1.36, 0], [-67.321, 3.44, 0], [-93.161, 36.04, 0], [-59.164, 60.52, 0], [-19.043, 51.1, 0], [-1.36, 12.24, 0]
scapula~coracoid = [23.8, 68.0, 0] ~ average(0,1), -90

sternalPlate = [-2.72, 5.44, 0], [-73.441, 2.72, 0], [-95.2, 8.16, 0], [-128.52, 8.16, 0], [-102.68, 20.42, 0], [-48.28, 29.92, 0], [-6.81, 26.523, 0]
coracoid~sternalPlate = 2 ~ last, 15
//body end

//neck start
cervicalLastEndHeight = distanceBetween(dorsalSpine[0], dorsalSpine[last])
cervicalFirstStartHeight = 87
neckHeightDifference = cervicalLastEndHeight - cervicalFirstStartHeight

cervicalLastStartHeight = cervicalLastEndHeight - neckHeightDifference * 0.42
cervicalLastLength = 129 
cervicalLast = trapesium(-cervicalLastLength, -cervicalLastLength, cervicalLastStartHeight, cervicalLastEndHeight)
dorsalSpine~cervicalLast = average(0, last) ~ average(1, 2), -7.776

cervicalMiddleStartHeight = cervicalLastStartHeight - neckHeightDifference * 0.42
cervicalMiddleLength = 215
cervicalMiddle = trapesium(-cervicalMiddleLength, -cervicalMiddleLength, cervicalMiddleStartHeight, cervicalLastStartHeight)
cervicalLast~cervicalMiddle = average(0, last) ~ average(1, 2), -31.1

cervicalFirstLength = 90.3 
cervicalFirst = trapesium(-cervicalFirstLength, -cervicalFirstLength, cervicalFirstStartHeight, cervicalMiddleStartHeight)
cervicalMiddle~cervicalFirst = average(0, last) ~ average(1, 2), 31.1
//neck end

//head start
cranium = [-347.2, 27.28, 0], [-347.2, 109.12, 0], [-322.4, 131.44, 0], [-322.4, 166.16, 0], [-314.96, 205.84, 0], [-176.08, 195.92, 0], [-121.52, 158.72, 0], [-2.48, 173.6, 0], [-12.4, 109.12, 0], [-66.96, 96.72, 0], [-96.72, 19.84, 0], [-171.12, 2.48, 0], [-213.28, 4.96, 0]
cervicalFirst~cranium = average(0, last) ~ average(0, 1), 27.77

mandible = [-257.92, 19.84, 0], [-305.04, 32.24, 0], [-295.12, 49.6, 0], [-245.52, 39.68, 0], [-188.48, 42.16, 0], [-116.56, 62.0, 0], [-86.8, 84.32, 0], [-44.64, 84.32, 0], [-2.48, 59.516, 0], [-81.84, 37.2, 0], [-124.0, 2.48, 0], [-166.16, 22.32, 0]
cranium~mandible = average(3, 4) ~ average(0, 1), 0
//head end


//tail start
tailFirstStartHeight = distanceBetween(sacrum[1], sacrum[2])
tailFirstEndHeight = 100
tailFirstLength = 350

tailFirst = trapesium(-tailFirstLength, -tailFirstLength, tailFirstStartHeight, tailFirstEndHeight)
sacrum~tailFirst = average(1, 2) ~ average(0, last), 23

tailMiddleEndHeight = 45
tailMiddleLength = 420
tailMiddle = trapesium(-tailMiddleLength, -tailMiddleLength, tailFirstEndHeight, tailMiddleEndHeight)
tailFirst~tailMiddle = average(1, 2) ~ average(0, last), -3.6

tailLastEndHeight = 5
tailLastLength = 680
tailLast = trapesium(-tailLastLength, -tailLastLength, tailMiddleEndHeight, tailLastEndHeight)
tailMiddle~tailLast = average(1, 2) ~ average(0, last), -8.6
//tail end


//front leg start
humerus = [-22.008, 5, 0], [-39.05, 2, 0], [-51.12, 16, 0], [-95.85, 26, 0], [-137.738, 21, 0], [-167.56, 14, 0], [-176.79, 36, 0], [-171.10, 54, 0], [-168.98, 70, 0], [-158.328, 89, 0], [-142.0, 79, 0], [-109.33, 68, 0], [-75.25, 74, 0], [-46.86, 86, 0], [-29.82, 86, 0], [-18.46, 85, 0], [-8.52, 65, 0], [-0.71, 49, 0], [-2.13, 43, 0]
scapula~humerus = scapula[11] + [-10, 15] ~ last, -91.84

ulnaRadius = [-9.94, 3, 0], [-51.12, 16, 0], [-85.1, 21, 0], [-117.86, 13, 0], [-124.96, 21, 0], [-119.99, 59, 0], [-114.30, 67, 0], [-99.3, 64, 0], [-54.665, 68, 0], [-29.82, 78, 0], [-17.75, 83, 0], [-10.64, 77, 0], [-12.07, 62, 0], [-2.84, 19, 0]
humerus~ulnaRadius = 8 ~ 12, -30

frontFoot = [2, 49], [6, 99], [42, 95], [79, 110], [89, 64], [74, 4]
ulnaRadius~frontFoot = average(4, 5) ~ average(0, 1), -200
//front leg end

//second leg
//femur2 = femur.duplicate
//illium~femur2 = average(0,0,1,last) ~ average(0,10), -80

//tibiaFibula2 = tibiaFibula.duplicate
//femur2~tibiaFibula2 = 5 ~ 14, 25

//backFoot2 = backFoot.duplicate
//tibiaFibula2~backFoot2 = 6 ~ average(0,1), 90

//second arm
//humerus2 = humerus.duplicate
//scapula~humerus2 = scapula[11] + [10, 15] ~ last, -121.84

//ulnaRadius2 = ulnaRadius.duplicate
//humerus2~ulnaRadius2 = 8 ~ 12, -50

//frontFoot2 = frontFoot.duplicate
//ulnaRadius2~frontFoot2 = average(4, 5) ~ average(0, 1), -155


//sections start
head = cranium, mandible

neck = cervicalLast, cervicalMiddle, cervicalFirst

tail = tailFirst, tailMiddle, tailLast

body = dorsalSpine, dorsalRibs

shoulder = scapula, coracoid, sternalPlate

armWithoutHand = humerus, ulnaRadius

//armWithoutHand2 = humerus2, ulnaRadius2

arm = humerus, ulnaRadius, frontFoot

//arm2 = humerus2, ulnaRadius2, frontFoot2
