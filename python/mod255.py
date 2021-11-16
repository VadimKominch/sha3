def mod255(a):
	a = (a >> 16) + (a & 0xFFFF)
	a = (a >> 8) + (a & 0xFF)
	if(a < 255):
		return a
	if(a<2*255):
		return a - 255
	return a-2*255
