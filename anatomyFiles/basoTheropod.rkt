#lang anatomy

//baso-theropod based on Herrerasaurus ischiguanlastensis
//"The classic achaidc theropod"

Parameters = {
	test: 0.2 > < 1.8 = 0.43
}


//hips start

illium = [-104, 127], [39, 140], [63, 113], [54, 103], [40, 99], [35, 84], [52, 67], [67, 60], [55, 27], [-4, 50], [-21, 47], [-32, 33], [-58, 28], [-72, 53], [-106, 61], [-114, 72]

pubis = [-214, -17], [-183, 2], [-151, -5], [-103, -40], [-40, -70], [4, -88], [55, -82], [71, -108], [38, -154], [-9, -187], [-28, -197], [-34, -185], [-34, -162], [-89, -82], [-115, -67], [-135, -59], [-147, -90], [-162, -86], [-187, -84], [-213, -55]
illium ~ pubis = [55, 44] ~ [-212, -40], 70

ischium = [-17, -50], [-3, -82], [-27, -88], [-54, -71], [-71, -84], [-93, -82], [-112, -91], [-122, -99], [-135, -89], [-165, -73], [-200, -77], [-230, -85], [-241, -66], [-193, -55], [-146, -55], [-105, -62], [-93, -36], [-85, -19], [-55, -29], [-37, -18], [-21, -35]
illium ~ ischium = [-12, 44] ~ [-39, -27], -40





//back leg start

femur = [-48, -61], [-50, -73], [-48, -88], [-67, -92], [-83, -82], [-87, -64], [-98, -67], [-107, -75], [-165, -79], [-226, -77], [-278, -73], [-331, -60], [-359, -54], [-385, -37], [-383, -12], [-360, 3], [-339, 16], [-321, 5], [-322, -8], [-280, -29], [-230, -39], [-191, -39], [-176, -21], [-130, -20], [-115, -29], [-76, -25], [-61, -15], [-44, -19], [-40, -30], [-45, -48]
illium ~ femur = [6, 33] ~ [-58, -53], -90

//TODO change connection point to make rotate correctly
tibia = [-20, -18], [-11, -75], [-29, -98], [-60, -95], [-104, -77], [-164, -71], [-243, -65], [-278, -64], [-305, -73], [-321, -45], [-308, -33], [-277, -30], [-199, -39], [-108, -38], [-44, -13], [-21, -17], [-17, -48]
femur ~ tibia = [-361, 2] ~ [-16, -47], 63

fibula = [-22, -24], [-11, -62], [-25, -71], [-54, -66], [-70, -57], [-167, -58], [-261, -59], [-289, -66], [-296, -40], [-287, -30], [-267, -42], [-188, -41], [-102, -41], [-44, -31], [-32, -26]
tibia ~ fibula = [-16, -47] ~ [-16, -47], 0

tarsi = [0, 0], [4, -11], [-11, -11], [-24, -3], [-25, 4], [-15, 19], [-4, 17]
tibia ~ tarsi = [-294, -53] ~ [0, 0], 0

metatarsals = [0, 0], [2, -15], [-24, -25], [-58, -43], [-116, -92], [-121, -79], [-130, -63], [-89, -35], [-22, 5], [-15, 11], [-7, 11]
tarsi ~ metatarsals = [-24, -1] ~ [0, 0], 0

//TODO break into smaller bones? Probably need to to get the correct rotation
smallPedalPhalange = [0, 0], [-10, -5], [-34, -12], [-54, -16], [-72, -10], [-84, 2], [-66, -1], [-51, -3], [-34, 1], [-16, 4]
metatarsals ~ smallPedalPhalange = [-83, -33] ~ [0, 0], 0

mediumPedalPhalange = [6, -9], [-14, -16], [-33, -27], [-51, -46], [-59, -66], [-58, -87], [-54, -111], [-68, -130], [-69, -113], [-73, -95], [-78, -73], [-70, -42], [-48, -19], [-42, -11], [-25, -6], [-14, 6], [-3, 9]
metatarsals ~ mediumPedalPhalange = [-127, -72] ~ [0, 0], 0

largePhalange = [-1, -3], [-4, -8], [-19, -14], [-31, -21], [-41, -41], [-41, -70], [-23, -91], [-4, -104], [8, -133], [-3, -122], [-22, -110], [-45, -101], [-63, -73], [-61, -37], [-34, -8], [-7, 3]
metatarsals ~ largePhalange = [-122, -89] ~ [0, 0], 0


//second leg

femurBack = femur.duplicate
illium ~ femurBack = [6, 33] ~ [-58, -53], -143

tibiaBack = tibia.duplicate
femurBack ~ tibiaBack = [-361, 2] ~ [-16, -47], 123

fibulaBack = fibula.duplicate
tibiaBack ~ fibulaBack = [-16, -47] ~ [-16, -47], 0

tarsiBack = tarsi.duplicate
tibiaBack ~ tarsiBack = [-294, -53] ~ [0, 0], 0

metatarsalsBack = metatarsals.duplicate
tarsiBack ~ metatarsalsBack = [-24, -1] ~ [0, 0], -80

smallPedalPhalangeBack = smallPedalPhalange.duplicate
metatarsalsBack ~ smallPedalPhalangeBack = [-83, -33] ~ [0, 0], 0

mediumPedalPhalangeBack = mediumPedalPhalange.duplicate
metatarsalsBack ~ mediumPedalPhalangeBack = [-127, -72] ~ [0, 0], 0

largePhalangeBack = largePhalange.duplicate
metatarsalsBack ~ largePhalangeBack = [-122, -89] ~ [0, 0], 0




// spine start
sacrum = [-83, 57], [71, 63], [94, -52], [-71, -71]
illium ~ sacrum = [-21, 88] ~ [0, 0], 0

dorsalSpine = [-8, 49], [100, 56], [233, 54], [331, 41], [443, 15], [523, 0], [583, 12], [650, 54], [716, 89], [803, 119], [863, 118], [856, 85], [807, 63], [740, 37], [693, 11], [648, -23], [594, -43], [520, -52], [423, -45], [328, -43], [218, -40], [133, -40], [48, -47], [7, -54]
sacrum ~ dorsalSpine = [82, 8] ~ [0, 0], 0

ribs = [-21, 15], [111, -6], [231, -20], [318, -18], [300, -45], [223, -86], [114, -197], [35, -200], [-46, -182], [-165, -110], [-228, -69], [-251, -49], [-238, 17], [-123, 25]
dorsalSpine ~ ribs = [278, 7] ~ [0, 0], 0

//body end


// front leg
scapula = [-4, 30], [12, 22], [14, 3], [81, -84], [106, -92], [108, -77], [123, -81], [152, -108], [155, -127], [143, -157], [113, -177], [99, -171], [97, -148], [75, -149], [75, -113], [44, -79], [17, -39], [-28, 3]
dorsalSpine ~ scapula = [367, -9] ~ [0, 0], 0

humerus = [11, 11], [11, 1], [4, -7], [4, -30], [-8, -55], [-22, -62], [-40, -57], [-62, -62], [-83, -76], [-92, -94], [-113, -98], [-123, -84], [-110, -73], [-58, -43], [-25, -23], [-14, -1], [-8, 15]
scapula ~ humerus = [84, -162] ~ [0, 0], 0

radius = [7, -2], [21, -18], [37, -37], [64, -58], [95, -89], [104, -100], [100, -106], [90, -106], [63, -74], [40, -56], [12, -28], [-2, -11], [-1, -2]
humerus ~ radius = [-99, -94] ~ [0, 0], 0

ulna = [-1, -1], [18, -18], [43, -47], [69, -70], [95, -98], [104, -110], [101, -117], [91, -119], [69, -90], [41, -63], [13, -36], [-12, -16], [-18, -1], [-16, 10], [-7, 8]
humerus ~ ulna = [-118, -91] ~ [0, 0], 0


// Hand
// From a pracical stand point, for now I've just modeled the carpals as one bone.
// Maybe we need bones that can have multiple parts, are bones that can be joined to form one unit?
carpals = [4, -1], [13, 3], [22, -10], [8, -19], [-5, -22], [-19, -26], [-22, -16], [-13, -13], [-2, -10]
radius ~ carpals = [96, -107] ~ [0, 0], 0

anteriorMetacarpal = [8, 5], [11, -11], [17, -22], [24, -29], [23, -37], [13, -41], [7, -40], [4, -25], [-6, -14], [-7, -4], [0, -2]
carpals ~ anteriorMetacarpal = [16, -14] ~ [0, 0], 0

anteriorProximalPhalange = [7, 4], [18, -10], [28, -19], [29, -26], [19, -32], [12, -23], [4, -13], [-6, -9], [-6, -2], [0, 0]
anteriorMetacarpal ~ anteriorProximalPhalange = [19, -40] ~ [0, 0], 0

anteriorDistalPhalange = [5, 4], [18, -18], [26, -28], [30, -43], [12, -26], [-8, -6]
anteriorProximalPhalange ~ anteriorDistalPhalange = [26, -29] ~ [0, 0], 0


intermediateMetacarpal = [1, 0], [9, 1], [20, -24], [30, -47], [28, -55], [23, -59], [16, -62], [10, -35], [-1, -15], [-5, -10], [-5, -2]
carpals ~ intermediateMetacarpal = [4, -22] ~ [0, 0], 0

intermediateProximalPhalange = [10, -1], [10, -15], [16, -25], [21, -35], [8, -36], [5, -41], [1, -25], [-8, -6], [0, -5]
intermediateMetacarpal ~ intermediateProximalPhalange = [23, -58] ~ [0, 0], 0

intermediateIntermediatePhalange = [8, 2], [11, -11], [19, -23], [20, -32], [13, -34], [6, -38], [3, -26], [-3, -14], [-10, -2], [0, -1]
intermediateProximalPhalange ~ intermediateIntermediatePhalange = [12, -36] ~ [0, 0], 0

intermediateDistalPhalange = [7, 0], [14, -21], [25, -39], [35, -53], [13, -38], [-3, -15], [-8, -3], [-1, -3]
intermediateIntermediatePhalange ~ intermediateDistalPhalange = [15, -34] ~ [0, 0], 0


intermediate2Metacarpal = [10, -3], [15, -21], [16, -41], [27, -59], [32, -68], [20, -67], [9, -73], [8, -51], [5, -32], [-1, -18], [-3, -3]
carpals ~ intermediate2Metacarpal = [-8, -24] ~ [0, 0], 0

intermediate2ProximalPhalange = [10, -2], [9, -13], [15, -26], [17, -33], [7, -33], [-4, -33], [-3, -20], [-8, -7], [3, -5]
intermediate2Metacarpal ~ intermediate2ProximalPhalange = [19, -67] ~ [0, 0], 0

intermediate2intermediatePhalange = [10, -3], [10, -17], [13, -26], [1, -28], [-9, -3], [1, -4]
intermediate2ProximalPhalange ~ intermediate2intermediatePhalange = [8, -33] ~ [0, 0], 0

intermediate2Intermediate2Phalange = [7, -1], [8, -13], [14, -29], [8, -29], [1, -31], [-5, -11], [-7, 0], [0, -1]
intermediate2intermediatePhalange ~ intermediate2Intermediate2Phalange = [7, -28] ~ [0, 0], 0

intermediate2DistalPhalange = [8, -3], [8, -22], [15, -51], [0, -29], [-8, -11], [-7, -3], [0, -4]
intermediate2Intermediate2Phalange ~ intermediate2DistalPhalange = [7, -30] ~ [0, 0], 0


posteriorMetacarpal = [0, 0], [7, 0], [8, -18], [15, -44], [7, -47], [0, -26], [-5, -17], [-5, -1]
carpals ~ posteriorMetacarpal = [-18, -26] ~ [0, 0], 0


neckTemp = [26, 21], [44, 22], [43, -10], [21, -8]
dorsalSpine ~ neckTemp = [833, 98] ~ [0, 0], 0

cranium = [4, 15], [21, 32], [50, 27], [65, 20], [80, 19], [91, 18], [105, 8], [117, -1], [170, -25], [213, -45], [240, -53], [257, -73], [263, -93], [261, -110], [253, -124], [233, -113], [207, -110], [181, -104], [159, -99], [121, -85], [95, -74], [78, -68], [42, -65], [17, -61], [-14, -52], [-55, -48], [-55, -39], [-26, -39], [-13, -9], [-13, 12], [-4, 19]
neckTemp ~ cranium = [34, 8] ~ [0, 0], 0

mandible = [3, 0], [8, -7], [38, -22], [61, -32], [82, -54], [106, -86], [123, -115], [146, -151], [174, -177], [194, -193], [200, -205], [183, -210], [165, -200], [132, -168], [97, -136], [71, -121], [53, -104], [32, -77], [15, -53], [1, -28], [-11, -12], [-9, 4], [-1, 12], [5, 9]
cranium ~ mandible = [-39, -45] ~ [0, 0], 0


tail = [0, 9], [0, -51], [-42, -105], [-86, -133], [-260, -121], [-488, -98], [-670, -81], [-837, -67], [-988, -67], [-1158, -65], [-1328, -93], [-1458, -137], [-1558, -170], [-1575, -170], [-1530, -144], [-1414, -100], [-1282, -60], [-1130, -30], [-958, -19], [-819, -7], [-672, -5], [-472, 16], [-305, 28], [-149, 40], [-58, 53], [-16, 65]
sacrum ~ tail = [-79, -10] ~ [0, 0], 0


print illium
print dorsalSpine
render illium

// Gastralium not connected to other bones. not sure what to do with that
// maybe do the points in the same way as soft tissue?
// I suppose technically they should be positioned relative to the soft tissue