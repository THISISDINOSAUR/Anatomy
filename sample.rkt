#lang anatomy

//todo indexing, ranges, etc

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
var test = -1 + 2 - 3 * (4 + 5) / 6 ^ 7 + 8 mod 9
var test2 = test * 10.0 + 2
illium = [0, 0], [115, 24, 5], [81, -89], [-40, -135], [-90, -111], [-100, -75], [-28, -48], [-84, -14]
test3 = [0, 20] + [1, 2]
test5 = [20, 0, 0] - [100, 100]
test7 = [10, 10] / 4 + [5, 0]
test6 = 4 * [10, 10] / 2.0 + 5 + 6 * [10, 10] //[130, 130] expected

point test4 = [10, 20]
bone = test4 * 3, [20, 20]

print illium


pubis = [22, 4], [53,26], [156, 30], [204, 2], [209, 63], [132, 113], [102, 67], [35, 60], [10, 86]
//illium~pubis = [0, 0] ~ [120, 50], -70

print illium

scapula = [156, 30], [204, 2], [209, 63], [132, 113]
illium~scapula = last ~ 1, 40

print illium
illium~pubis = average(1,last) ~ 1, -70
print illium
