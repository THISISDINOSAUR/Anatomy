#lang anatomy

Parameters = {
	neckLength: 0.2 > < 1.8 = 1,
	neckAngle: -30 > < 100 = 45,
	headSize: 0.7 > < 3 = 1,
	tailLength: 0.2 > < 1.8 = 1,
        tailAngle: -40 > < 30 = 0,
	scapulaLength: 0.5 > < 1.5 = 1,
	shoulderSize: 0.5 > < 1.5 = 1,
	scapulaAngle: 10 > < 65 = 55,
	armLength: 0.2 > < 1.2 = 1,
	armWidth: 0.5 > < 1.2 = 1,
	bodyLength: 0.5 > < 1.5 = 1,
	bodyAngle: -35 > < 25 = 0
	}

//hips start
illium = [0,0], [115, 24], [81, -89], [-40, -135], [-90, -111], [-100, -75], [-28, -48], [-84, -14]

pubis = [22, 4], [53,26], [156, 30], [204, 2], [209, 63], [132, 113], [102, 67], [35, 60], [10, 86]
illium~pubis = average(0,last) ~ average(3,4), -70

ischium = [2, 45], [74, 3], [98, 53], [127, 69], [213, 69], [244, 71], [230, 92], [209, 83], [118, 83], [85, 97], [67, 96]
illium~ischium = average(0,1) ~ average(0,1), 40

sacrum = [7, 0], [127, 2], [107, 162], [109, 166], [2, 178]
illium~sacrum = average(0,1,2,3) ~ average(all), 22
//hips end

//back leg start
femur = [35, 3], [76, 20], [235, 28], [284, 7], [308, 26], [311, 48], [310, 68], [287, 95], [257, 80], [60, 77], [32, 93], [13, 81], [3, 45]
illium~femur = average(0,0,1,last) ~ average(0,10), 110

tibiaFibula = [37, 1], [61, 12], [110, 16], [200, 12], [239, 6], [238, 17], [231, 35], [233, 50], [224, 80], [186, 74], [72, 83], [36, 95], [16, 94], [8, 80], [21, 42], [26, 16]
femur~tibiaFibula = 5 ~ 14, -25

backFoot = [79, 0], [153, 7], [137, 32], [139, 74], [68, 74], [5, 68], [23, 42], [54, 37]
tibiaFibula~backFoot = 6 ~ average(0,1), -90
//back leg end

//body start
dorsalSpine = [9, 9], [336, 3], [643, 71], [555, 215], [307, 139], [0, 139]
sacrum~dorsalSpine = average(0, last) ~ average(2,3), bodyAngle - 22

dorsalRibs = [17, 28], [137, 10], [278, 6], [536, 63], [515, 193], [411, 331], [275, 375], [42, 304], [0, 173]
dorsalSpine~dorsalRibs = [276, 13] ~ 2, 0

scapula = [215, 57], [263, 34], [290, 34], [321, 81], [299, 135], [244, 134], [226, 121], [136, 119], [83, 133], [49, 173], [26, 167], [3, 128], [20, 56], [19, 36], [50, 10], [90, 5], [130, 32], [128, 53], [135, 64]
scapula[7:18].x += (-90 * scapulaLength) + 90
dorsalSpine~scapula = [194.5, 94] ~ average(1,4), -scapulaAngle

coracoid = [15, 2], [99, 5], [137, 53], [87, 89], [28, 75], [2, 18]
scapula~coracoid = [(-90 * scapulaLength) + 100, 100] ~ average(0,1), 90

sternalPlate = [4, 8], [108, 4], [140, 12], [189, 12], [151, 30], [71, 44], [10, 39]
coracoid~sternalPlate = 2 ~ last, -15
//body end

//neck start
cervicalLastEndHeight = distanceBetween(dorsalSpine[0], dorsalSpine[last])
cervicalFirstStartHeight = 35 * headSize
neckHeightDifference = cervicalLastEndHeight - cervicalFirstStartHeight

//Calculate length removed due to neck angle from first and last parts of neck to keep the total length normalised
tailLastLengthChange = - max(0, (neckAngle - 45) * 3)
tailFirstLengthChange = - max(0, (neckAngle - 45) * 2)

cervicalLastStartHeight = cervicalLastEndHeight - neckHeightDifference * 0.42
cervicalLastLength = 300 + tailLastLengthChange
cervicalLast = trapesium(cervicalLastLength, cervicalLastLength, cervicalLastStartHeight, cervicalLastEndHeight)
dorsalSpine~cervicalLast = average(0, last) ~ average(1, 2), neckAngle * 0.2

cervicalMiddleStartHeight = cervicalLastStartHeight - neckHeightDifference * 0.42
cervicalMiddleLength = 500 - tailLastLengthChange - tailFirstLengthChange
cervicalMiddle = trapesium(cervicalMiddleLength, cervicalMiddleLength, cervicalMiddleStartHeight, cervicalLastStartHeight)
cervicalLast~cervicalMiddle = average(0, last) ~ average(1, 2), neckAngle * 0.8

cervicalFirstLength = 210 + tailFirstLengthChange
cervicalFirst = trapesium(cervicalFirstLength, cervicalFirstLength, cervicalFirstStartHeight, cervicalMiddleStartHeight)
cervicalMiddle~cervicalFirst = average(0, last) ~ average(1, 2), -neckAngle * 0.8 - bodyAngle * 0.5
//neck end

//head start
cranium = [140, 11], [140, 44], [130, 53], [130, 67], [127, 83], [71, 79], [49, 64], [1, 70], [5, 44], [27, 39], [39, 8], [69, 1], [86, 2]
cervicalFirst~cranium = average(0, last) ~ average(0, 1), -neckAngle * 0.2 - bodyAngle * 0.5

mandible = [104, 8], [123, 13], [119, 20], [99, 16], [76, 17], [47, 25], [35, 34], [18, 34], [1, 24], [33, 15], [50, 1], [67, 9]
cranium~mandible = average(3, 4) ~ average(0, 1), 0
//head end


//tail start
tailFirstStartHeight = distanceBetween(sacrum[1], sacrum[2])
tailFirstEndHeight = 100
tailFirstLength = 350

tailFirst = trapesium(tailFirstLength, tailFirstLength, tailFirstStartHeight, tailFirstEndHeight)
sacrum~tailFirst = average(1, 2) ~ average(0, last), tailAngle

tailMiddleEndHeight = 45
tailMiddleLength = 420
tailMiddle = trapesium(tailMiddleLength, tailMiddleLength, tailFirstEndHeight, tailMiddleEndHeight)
tailFirst~tailMiddle = average(1, 2) ~ average(0, last), -tailAngle * 0.8 - 15

tailLastEndHeight = 5
tailLastLength = 680
tailLast = trapesium(tailLastLength, tailLastLength, tailMiddleEndHeight, tailLastEndHeight)
tailMiddle~tailLast = average(1, 2) ~ average(0, last), -tailAngle * 0.8 - 10
//tail end


//front leg start
humerus = [31, 5], [55, 2], [72, 16], [135, 26], [194, 21], [236, 14], [249, 36], [241, 54], [238, 70], [223, 89], [200, 79], [154, 68], [106, 74], [66, 86], [42, 86], [26, 85], [12, 65], [1, 49], [3, 43]
scapula~humerus = scapula[11] + [10, 15] ~ last, 45 - bodyAngle + scapulaAngle

ulnaRadius = [14, 3], [72, 16], [120, 21], [166, 13], [176, 21], [169, 59], [161, 67], [140, 64], [77, 68], [42, 78], [25, 83], [15, 77], [17, 62], [4, 19]
humerus~ulnaRadius = 8 ~ 12, 30

frontFoot = [-2, 49], [-6, 99], [-42, 95], [-79, 110], [-89, 64], [-74, 4]
ulnaRadius~frontFoot = average(4, 5) ~ average(0, 1), 200
//front leg end

//second leg
femur2 = femur.duplicate
illium~femur2 = average(0,0,1,last) ~ average(0,10), 80
tibiaFibula2 = tibiaFibula.duplicate
femur2~tibiaFibula2 = 5 ~ 14, -25
backFoot2 = backFoot.duplicate
tibiaFibula2~backFoot2 = 6 ~ average(0,1), -90

//second arm
humerus2 = humerus.duplicate
scapula~humerus2 = scapula[11] + [10, 15] ~ last, 75 - bodyAngle + scapulaAngle
ulnaRadius2 = ulnaRadius.duplicate
humerus2~ulnaRadius2 = 8 ~ 12, 50
frontFoot2 = frontFoot.duplicate
ulnaRadius2~frontFoot2 = average(4, 5) ~ average(0, 1), 155


//sections start
head = cranium, mandible
head.scale(headSize, headSize)

neck = cervicalLast, cervicalMiddle, cervicalFirst
neck.scale(neckLength, 1)

tail = tailFirst, tailMiddle, tailLast
tail.scale(tailLength, 1)

body = dorsalSpine, dorsalRibs
body.scale(bodyLength, 1)

shoulder = scapula, coracoid, sternalPlate
shoulder.scale(shoulderSize, shoulderSize)

armWithoutHand = humerus, ulnaRadius
armWithoutHand.scale(armLength, 1)

armWithoutHand2 = humerus2, ulnaRadius2
armWithoutHand2.scale(armLength, 1)

arm = humerus, ulnaRadius, frontFoot
arm.scale(1, armWidth)

arm2 = humerus2, ulnaRadius2, frontFoot2
arm2.scale(1, armWidth)
