#lang anatomy

Parameters = {
	scapulaLength: 0.5 > < 1.5 = 1,
        bodyAngle: 0 > < 20 = 10,
        test: 0 > < 20 = 1
	}

scapula = [0, 0], [204, 2], [209, 63], [132, 113]
testVar = 20

scapula[1:last] = [(-90 * scapulaLength), 10]
print scapula
//scapula.scale(2,2)
