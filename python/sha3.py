import copy
import binascii
import logging
from string import Template
from functools import reduce

class Sha3Block:
    def __init__(self):
        logging.basicConfig(filename="journal.log",format='%(asctime)s %(message)s',filemode='w')
        self.logger = logging.getLogger()
        self.logger.setLevel(logging.INFO)
        self.state = [[0,0,0,0,0],[0,0,0,0,0],[0,0,0,0,0],[0,0,0,0,0],[0,0,0,0,0]]

    def msgToHexString(self,msg):
        hexString = msg.encode().hex()
        return hexString
        

    def byteArrayToMsg(self,byteArray):
        msg = ""
        for i in byteArray:
            msg.append()

    def fromLaneToHexString(self,lane):
        """Convert a lane value to a string of bytes written in hexadecimal"""

        laneHexBE = (("%%0%dX" % 16) % lane)
        #Perform the modification
        temp=''
        nrBytes=len(laneHexBE)//2
        for i in range(nrBytes):
            offset=(nrBytes-i-1)*2
            temp+=laneHexBE[offset:offset+2]
        return temp.upper()    
            
    #function which convert big endian string to lottle endian number(lane)
    def hexStringToLane(self,hexString):
        temp=''
        nrBytes = len(hexString)//2
        for i in range(nrBytes):
            offset = (nrBytes-i-1)*2
            temp+=hexString[offset:offset+2]
        return int(temp,16)
        
    def convertStringToState(self,hexString):
        state = [[0,0,0,0,0],[0,0,0,0,0],[0,0,0,0,0],[0,0,0,0,0],[0,0,0,0,0]]
        for x in range(5):
            for y in range(5):
                offset=(5*y+x)*16
                state[x][y]=self.hexStringToLane(hexString[offset:offset+16])
        return state
            
    def convertStatetoHexString(self,state):
        output=['']*25
        for x in range(5):
            for y in range(5):
                output[5*y+x]=self.fromLaneToHexString(state[x][y])
        output =''.join(output).upper()
        return output


    #64 bit word
    def convertEndian(self,word):
        return sum([int(word[i],16)<<(4*i) for i in range(16)])


    def rc(self,t):
        if(t % 255 == 0):
            return 1
        r = 128
        for i in range(0,t%255):
            r = r^((r&1)<<8)
            r = r^((r&1)<<4)
            r = r^((r&1)<<3)
            r = r^((r&1)<<2)
            r = r>>1
        return r>>7

        
    def i_count(self,A,ir):
        a = 0
        for i in range(0,7):
            a = a ^ rc(i+7*ir)<<((2**i)-1)
            A = A^ (rc(i+7*ir) << ((2**i)-1))
        return A


    def rc_vector(self,ir):
        RC=[0x0000000000000001,
            0x0000000000008082,
            0x800000000000808A,
            0x8000000080008000,
            0x000000000000808B,
            0x0000000080000001,
            0x8000000080008081,
            0x8000000000008009,
            0x000000000000008A,
            0x0000000000000088,
            0x0000000080008009,
            0x000000008000000A,
            0x000000008000808B,
            0x800000000000008B,
            0x8000000000008089,
            0x8000000000008003,
            0x8000000000008002,
            0x8000000000000080,
            0x000000000000800A,
            0x800000008000000A,
            0x8000000080008081,
            0x8000000000008080,
            0x0000000080000001,
            0x8000000080008008]
        return RC[ir]


    def i(self,A,ir):
        A[0][0] = A[0][0] ^ self.rc_vector(ir)
        return A


    def psi(self,A):
        A1 = copy.deepcopy(A)
        for i in range(0,5):
            for j in range(0,5):
                A1[i][j] = A[i][j]^((~A[(i+1)%5][j]) & A[(i+2)%5][j] )
        return A1

    def p(self,A):
        x,y = 1,0
        for t in range(24):
            shift = (t+1)*(t+2)//2 % 64
            A[x][y] = self.rotateshiftright(A[x][y],shift)
            x,y = y,(2*x+3*y)%5
        return A

    def pi(self,A):
        A1 = copy.deepcopy(A)
        for x in range(0,5):
            for y in range(0,5):
                A1[x][y] = A[(x+3*y)%5][x]
        return A1

    def combinedpi(self,A):
        A1 = copy.deepcopy(A)
        x,y = 1,0
        current = A[x][y]
        for t in range(24):
            shift = (t+1)*(t+2)//2 % 64
            (x, y) = (y, (2*x+3*y)%5)
            (current, A[x][y]) = (A[x][y], self.rotateshiftright(current,shift))
        return A
        
        
    def teta(self,A):
        c = [0,0,0,0,0]
        for x in range(0,5):
            c[x] = A[x][0] ^ A[x][1] ^A[x][2] ^A[x][3] ^A[x][4]
        for x in range(0,5):
            for y in range(0,5):
                A[x][y] = A[x][y] ^ c[(x-1)%5] ^ self.rotateshiftright(c[(x+1)%5],1)
        
        return A
    #shift should always be less or equal to bit length or result will be incorrect
    def rotateshiftright(self,num,shift,bitlength=64):
        return (num >> (bitlength-shift) | num << shift ) % (1<<bitlength)

    def printState(self,A):
        print("Current value of state:")
        for y in range(5):
            line=[]
            for x in range(5):
                line.append(hex(A[x][y]))
            print('\t%s' % line)
        
    def Keccak(self,A):
        for j in range(24):
            A = self.i(self.psi(self.pi(self.p(self.teta(A)))),j)    
        return A

    def wtfKeccak(self,A):
        for j in range(24):
            A = self.i(self.psi(self.combinedpi(self.teta(A))),j)
        return A

    def appendBit(self, M, bit):
        """Append a bit to M

        M: message pair (length in bits, string of hex characters ('9AFC...'))
        bit: 0 or 1
        Example: appendBit([7, '30'],1) returns [8,'B0']
        Example: appendBit([8, '30'],1) returns [9,'3001']
        """
        [my_string_length, my_string]=M
        if ((my_string_length%8) == 0):
            my_string = my_string[0:my_string_length//8*2] + "%02X" % bit
            my_string_length = my_string_length + 1
        else:
            nr_bytes_filled = my_string_length//8
            nbr_bits_filled = my_string_length%8
            my_byte = int(my_string[nr_bytes_filled*2:nr_bytes_filled*2+2],16)
            my_byte = my_byte + bit*(2**(nbr_bits_filled))
            my_byte = "%02X" % my_byte
            my_string = my_string[0:nr_bytes_filled*2] + my_byte
            my_string_length = my_string_length + 1
        return [my_string_length, my_string]

    def appendDelimitedSuffix(self, M, suffix):
        """Append a delimited suffix to M

        M: message pair (length in bits, string of hex characters ('9AFC...'))
        suffix: integer coding a string of 0 to 7 bits, from LSB to MSB, delimited by a bit 1 at MSB
        Example: appendDelimitedSuffix([3, '00'], 0x06) returns [5, '10']
        Example: appendDelimitedSuffix([3, '00'], 0x1F) returns [7, '78']
        Example: appendDelimitedSuffix([8, '00'], 0x06) returns [10, '0002']
        Example: appendDelimitedSuffix([8, '00'], 0x1F) returns [12, '000F']
        """
        while(suffix != 1):
            M = self.appendBit(M, suffix%2)
            suffix = suffix//2
        return M

    def delimitedSuffixInBinary(self,delimitedSuffix):
        binary = ''
        while(delimitedSuffix != 1):
            binary = binary + ('%d' % (delimitedSuffix%2))
            delimitedSuffix = delimitedSuffix//2
        return binary

    ### Padding rule

    def pad10star1(self, M, n):
        """Pad M with the pad10*1 padding rule to reach a length multiple of r bits

        M: message pair (length in bits, string of hex characters ('9AFC...')
        n: length in bits (must be a multiple of 8)
        Example: pad10star1([60, 'BA594E0FB9EBBD03'],8) returns 'BA594E0FB9EBBD93'
        """

        [my_string_length, my_string]=M



        nr_bytes_filled=my_string_length//8
        nbr_bits_filled=my_string_length%8
        l = my_string_length % n
        if ((n-8) <= l <= (n-2)):
            if (nbr_bits_filled == 0):
                my_byte = 0
            else:
                my_byte=int(my_string[nr_bytes_filled*2:nr_bytes_filled*2+2],16)
            my_byte=my_byte+2**(nbr_bits_filled)+2**7
            my_byte="%02X" % my_byte
            my_string=my_string[0:nr_bytes_filled*2]+my_byte
        else:
            if (nbr_bits_filled == 0):
                my_byte = 0
            else:
                my_byte=int(my_string[nr_bytes_filled*2:nr_bytes_filled*2+2],16)
            my_byte=my_byte+2**(nbr_bits_filled)
            my_byte="%02X" % my_byte
            my_string=my_string[0:nr_bytes_filled*2]+my_byte
            while((8*len(my_string)//2)%n < (n-8)):
                my_string=my_string+'00'
            my_string = my_string+'80'

        return my_string


    def sha3_256(self,string,b = 1600,w = 64, r = 1088):
        hexString  = self.msgToHexString(string)
        if(len(hexString) == 0):
            M = [0,hexString]
        else:
            M = [len(hexString)*4,hexString]
        #append 01 for byteArray
        c = b - r
        M = self.appendDelimitedSuffix(M, 0x06)
        #Padding of messages
        P = self.pad10star1(M, r)

        digitsNumber = r//4 #number of hex digits
        chunksAmount = len(P)//digitsNumber
        S = [[0,0,0,0,0],[0,0,0,0,0],[0,0,0,0,0],[0,0,0,0,0],[0,0,0,0,0]]
        
        #pad message
        #Absorb phase
        for i in range(chunksAmount):
            P = P[digitsNumber*i:digitsNumber*(i+1)]
            concatedP = P+'0'*(c//4)  # concat c bits of zeros to current state
            pstate = self.convertStringToState(concatedP)
            for x in range(5):
                for y in range(5):
                    S[x][y] = S[x][y] ^ pstate[x][y]
        S = self.Keccak(S)    
        #Squeeze phase
        stateString = self.convertStatetoHexString(S)
        Z = stateString[:digitsNumber]
        while len(Z) < 64:
            S = Keccak(S)
            Z = Z + self.convertStatetoHexString(S)[:digitsNumber]
        t = Template('Hash value of $msg is $hash')
        self.logger.info(t.substitute({'msg':string,'hash':Z[:64]}))
        return Z[:64]