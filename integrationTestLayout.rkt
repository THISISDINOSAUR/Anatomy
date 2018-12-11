#lang anatomy

Parameters = {
	scapulaLength: 0.5 > < 1.5 = 1
	}

scapula = [0, 0], [204, 2], [209, 63], [132, 113]
testVar = 20

scapula[0:3].x -= (-90 * scapulaLength)