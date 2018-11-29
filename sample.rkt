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
test = -1 + 2 - 3 * (4 + 5) / 6 ^ 7 + 8 mod 9
test2 = test * 10.0 + 2
illium = [0, 0], [115, 24, 5], [81, -89], [-40, -135], [-90, -111], [-100, -75], [-28, -48], [-84, -14]
test3 = [0, 20] + [1, 2]
test5 = [20, 0, 0] - [100, 100]
test7 = [10, 10] / 4 + [5, 0]
test6 = 4 * [10, 10] / 2.0 + 5 + 6 * [10, 10] //[130, 130] expected

test4 = [10, 20]
bone = test4 * 3, [20, 20]

print illium


pubis = [22, 4], [53,26], [156, 30], [204, 2], [209, 63], [132, 113], [102, 67], [35, 60], [10, 86]
//illium~pubis = [0, 0] ~ [120, 50], -70

print illium

scapula = [156, 30], [204, 2], [209, 63], [132, 113]
illium~scapula = last ~ 1 + 2, 40

print illium
illium~pubis = average([10,2],[0,0] + [20, 4], last) ~ average(all), -70
print illium

steve = pubis[2]

//scapula[1:3].x -= (-90 * scapulaLength)
scapula[1:3].x += min(1,2,-3,4,5)
print scapula

scapula = trapesium(1, 2, 3, 4)
print scapula

section = illium, pubis
print section
//section.scale(2,1)
pubis.scale(1000,2)
print pubis

duplicateOfIllium = illium.duplicate
print duplicateOfIllium

var = mag([-10,10])
print var