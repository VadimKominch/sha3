import sys

from sha3 import Sha3Block
from gui import createWindow

def main():
	print(sys.argv)
	encoder = Sha3Block()
	if(len(sys.argv) >1):
		msg = sys.argv[1]
		expected = msg
	else:
		createWindow(encoder)
		msg = "Hello"
	actual = encoder.sha3_256(msg)

#Add test for cases with underlying
def testOne():
	pass
#Add test for cases with overlyning
def testTwo():
	pass

main()
