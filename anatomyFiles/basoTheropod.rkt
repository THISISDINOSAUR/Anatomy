#lang anatomy

//baso-theropod based on Herrerasaurus ischiguanlastensis
//"The classic achaidc theropod"

Parameters = {
	test: 0.2 > < 1.8 = 0.43
}

//hips start
illium = [-104, 127], [39, 140], [63, 113], [54, 103], [40, 99], [35, 84], [52, 67], [67, 60], [55, 27], [-4, 50], [-21, 47], [-32, 33], [-58, 28], [-72, 53], [-106, 61], [-114, 72]

pubis = [-214, -17], [-183, 2], [-151, -5], [-103, -40], [-40, -70], [4, -88], [55, -82], [71, -108], [38, -154], [-9, -187], [-28, -197], [-34, -185], [-34, -162], [-89, -82], [-115, -67], [-135, -59], [-147, -90], [-162, -86], [-187, -84], [-213, -55]
//illium~pubis = [55, 44] ~ [-212, -40], 70

ischium = [-17, -50], [-3, -82], [-27, -88], [-54, -71], [-71, -84], [-93, -82], [-112, -91], [-122, -99], [-135, -89], [-165, -73], [-200, -77], [-230, -85], [-241, -66], [-193, -55], [-146, -55], [-105, -62], [-93, -36], [-85, -19], [-55, -29], [-37, -18], [-21, -35]
//illium~ischium = [-12, 44] ~ [-39, -27], -40

//back leg start
femur = [-48, -61], [-50, -73], [-48, -88], [-67, -92], [-83, -82], [-87, -64], [-98, -67], [-107, -75], [-165, -79], [-226, -77], [-278, -73], [-331, -60], [-359, -54], [-385, -37], [-383, -12], [-360, 3], [-339, 16], [-321, 5], [-322, -8], [-280, -29], [-230, -39], [-191, -39], [-176, -21], [-130, -20], [-115, -29], [-76, -25], [-61, -15], [-44, -19], [-40, -30], [-45, -48]
illium~femur = [6, 33] ~ [-58, -53], -90

tibia = [-20, -18], [-11, -75], [-29, -98], [-60, -95], [-104, -77], [-164, -71], [-243, -65], [-278, -64], [-305, -73], [-321, -45], [-308, -33], [-277, -30], [-199, -39], [-108, -38], [-44, -13], [-21, -17], [-17, -48]
femur~tibia = [-361, 2] ~ [-16, -47], 63

fibula = [-22, -24], [-11, -62], [-25, -71], [-54, -66], [-70, -57], [-167, -58], [-261, -59], [-289, -66], [-296, -40], [-287, -30], [-267, -42], [-188, -41], [-102, -41], [-44, -31], [-32, -26]
tibia~fibula = [-16, -47] ~ [-16, -47], 0

tarsi = [2, -1], [3, 21], [10, 36], [-8, 38], [-21, 30], [-19, 6], [-14, 1]
tibia~tarsi = [-295, -51] ~ [2, 18], -15


backFoot = [-79, 0], [-153, -7], [-137, -32], [-139, -74], [-68, -74], [-5, -68], [-23, -42], [-54, -37]
//tarsi~backFoot = 6 ~ average(0,1), 90
//back leg end

//spine start
sacrum = [-7, 0], [-127, -2], [-107, -162], [-109, -166], [-2, -178]
//illium~sacrum = average(0,1,2,3) ~ average(all), -22

dorsalSpine = [-9, -9], [-336, -3], [-643, -71], [-555, -215], [-307, -139], [0, -139]
sacrum~dorsalSpine = average(0, last) ~ average(2,3), 22

dorsalRibs = [-17, -28], [-137, -10], [-278, -6], [-536, -63], [-515, -193], [-411, -331], [-275, -375], [-42, -304], [0, -173]
//dorsalSpine~dorsalRibs = [-276, 13] ~ 2, 0

scapula = [-146.22, -38.765, 0], [-178.84, -23.12, 0], [-197.22, -23.12, 0], [-218.283, -55.085, 0], [-203.322, -91.81, 0], [-165.922, -91.12, 0], [-153.68, -82.28, 0], [-61.88, -80.92, 0], [-25.843, -90.441, 0], [-2.72, -117.641, 0], [12.922, -113.56, 0], [28.562, -87.04, 0], [17.0, -38.085, 0], [17.68, -24.48, 0], [-3.4004, -6.801, 0], [-30.6, -3.4004, 0], [-57.804, -21.76, 0], [-56.445, -36.04, 0], [-61.2, -43.52, 0]
dorsalSpine~scapula = [-194.5, -94] ~ average(1,4), 46.84

coracoid = [-10.21, -1.36, 0], [-67.321, -3.44, 0], [-93.161, -36.04, 0], [-59.164, -60.52, 0], [-19.043, -51.1, 0], [-1.36, -12.24, 0]
scapula~coracoid = [23.8, -68.0, 0] ~ average(0,1), -90

sternalPlate = [-2.72, -5.44, 0], [-73.441, -2.72, 0], [-95.2, -8.16, 0], [-128.52, -8.16, 0], [-102.68, -20.42, 0], [-48.28, -29.92, 0], [-6.81, -26.523, 0]
coracoid~sternalPlate = 2 ~ last, 15
//body end

//neck start
cervicalLastEndHeight = distanceBetween(dorsalSpine[0], dorsalSpine[last])
cervicalFirstStartHeight = 87
neckHeightDifference = cervicalLastEndHeight - cervicalFirstStartHeight

cervicalLastStartHeight = cervicalLastEndHeight - neckHeightDifference * 0.42
cervicalLastLength = 129 
cervicalLast = trapesium(-cervicalLastLength, -cervicalLastLength, cervicalLastStartHeight, cervicalLastEndHeight)
//dorsalSpine~cervicalLast = average(0, last) ~ average(1, 2), -7.776

cervicalMiddleStartHeight = cervicalLastStartHeight - neckHeightDifference * 0.42
cervicalMiddleLength = 215
cervicalMiddle = trapesium(-cervicalMiddleLength, -cervicalMiddleLength, cervicalMiddleStartHeight, cervicalLastStartHeight)
cervicalLast~cervicalMiddle = average(0, last) ~ average(1, 2), -31.1

cervicalFirstLength = 90.3 
cervicalFirst = trapesium(-cervicalFirstLength, -cervicalFirstLength, cervicalFirstStartHeight, cervicalMiddleStartHeight)
cervicalMiddle~cervicalFirst = average(0, last) ~ average(1, 2), 31.1
//neck end

//head start
cranium = [-310, -21], [-351, -75], [-340, -141], [-354, -166], [-381, -179], [-374, -194], [-243, -150], [-212, -131], [-111, -142], [-14, -122], [29, -116], [26, -52], [3, -20], [-33, -5], [-221, -20], [-244, 0], [-279, -16], [-295, -20]
//cervicalFirst~cranium = average(0, last) ~ average(0, 1), 27.77

mandible = [-274, -12], [-296, -20], [-291, -42], [-260, -65], [-192, -118], [-90, -150], [37, -175], [62, -164], [66, -154], [24, -137], [-26, -124], [-109, -93], [-157, -55], [-188, -52], [-203, -39], [-266, -41]
//cranium~mandible = average(3, 4) ~ average(0, 1), 0
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
//tailFirst~tailMiddle = average(1, 2) ~ average(0, last), -3.6

tailLastEndHeight = 5
tailLastLength = 680
tailLast = trapesium(-tailLastLength, -tailLastLength, tailMiddleEndHeight, tailLastEndHeight)
//tailMiddle~tailLast = average(1, 2) ~ average(0, last), -8.6
//tail end


//front leg start
humerus = [-22.008, -5, 0], [-39.05, -2, 0], [-51.12, -16, 0], [-95.85, -26, 0], [-137.738, -21, 0], [-167.56, -14, 0], [-176.79, -36, 0], [-171.10, -54, 0], [-168.98, -70, 0], [-158.328, -89, 0], [-142.0, -79, 0], [-109.33, -68, 0], [-75.25, -74, 0], [-46.86, -86, 0], [-29.82, -86, 0], [-18.46, -85, 0], [-8.52, -65, 0], [-0.71, -49, 0], [-2.13, -43, 0]
//scapula~humerus = scapula[11] + [-10, -15] ~ last, -91.84

ulnaRadius = [-9.94, -3, 0], [-51.12, -16, 0], [-85.1, -21, 0], [-117.86, -13, 0], [-124.96, -21, 0], [-119.99, -59, 0], [-114.30, -67, 0], [-99.3, -64, 0], [-54.665, -68, 0], [-29.82, -78, 0], [-17.75, -83, 0], [-10.64, -77, 0], [-12.07, -62, 0], [-2.84, -19, 0]
//humerus~ulnaRadius = 8 ~ 12, -30

frontFoot = [2, -49], [6, -99], [42, -95], [79, -110], [89, -64], [74, -4]
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
//scapula~humerus2 = scapula[11] + [10, -15] ~ last, -121.84

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

//illium.scale(5, 2)
//scapula[7] += [900, 900]

print illium
print dorsalSpine
render illium