def convertVHDLfileToStateArray(file):
	stateArray = [[0,0,0,0,0],[0,0,0,0,0],[0,0,0,0,0],[0,0,0,0,0],[0,0,0,0,0]]
	with open(file) as f:
		for l in f:
			stateArray[int(l.split()[0],2)][int(l.split()[1],2)] = int(l.split()[2],16)
	return stateArray

def printState(A):
	print("Current value of state:")
	for y in range(5):
		line=[]
		for x in range(5):
			line.append(hex(A[x][y]))
		print('\t%s' % line)
		
state = convertVHDLfileToStateArray("output_results.txt")
printState(state)